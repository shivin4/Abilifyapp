import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/config.dart';

class VideoSessionPage extends StatefulWidget {
  final String channelName;
  const VideoSessionPage({super.key, required this.channelName});

  @override
  State<VideoSessionPage> createState() => _VideoSessionPageState();
}

class _VideoSessionPageState extends State<VideoSessionPage> {
  int? _remoteUid;
  int? _localUid;
  bool _localUserJoined = false;
  String? _error;
  RtcEngine? _engine;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    final appId = dotenv.env['AGORA_APP_ID'];
    if (appId == null || appId.isEmpty) {
      setState(() => _error = 'AGORA_APP_ID missing in .env');
      return;
    }

    final engine = createAgoraRtcEngine();
    _engine = engine;
    await engine.initialize(RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint('local user ${connection.localUid} joined');
          setState(() {
            _localUserJoined = true;
            _localUid = connection.localUid;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint('remote user $remoteUid joined');
          setState(() => _remoteUid = remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint('remote user $remoteUid left channel');
          setState(() => _remoteUid = null);
        },
        onError: (ErrorCodeType err, String msg) {
          debugPrint('Agora error: $err $msg');
        },
      ),
    );

    await engine.enableVideo();
    await engine.startPreview();

    final baseUrl = await resolveApiBaseUrl();
    String token = '';
    try {
      debugPrint('Requesting Agora token from $baseUrl for channel ${widget.channelName}');
      final uri = Uri.parse('$baseUrl/agora-token?channelName=${Uri.encodeComponent(widget.channelName)}');
      final res = await http.get(uri).timeout(const Duration(seconds: 30));
      debugPrint('Token response status: ${res.statusCode}');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        token = data['token'] as String? ?? '';
      } else {
        setState(() => _error = 'Token server error: ${res.body}');
        return;
      }
    } catch (e) {
      setState(() => _error = _tokenServerErrorMessage(baseUrl, e));
      return;
    }

    if (token.isEmpty) {
      setState(() => _error = 'Empty token from server');
      return;
    }

    await engine.joinChannel(
      token: token,
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(
        autoSubscribeVideo: true,
        autoSubscribeAudio: true,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  String _tokenServerErrorMessage(String baseUrl, Object e) {
    return 'Cannot reach token server at $baseUrl\n\n'
        '$e\n\n'
        'Checklist:\n'
        '• PC: node index.js running in server/\n'
        '• Phone on same Wi‑Fi as PC (not mobile data)\n'
        '• .env API_BASE_URL = PC IP from ipconfig\n'
        '• Phone browser opens: $baseUrl/agora-token?channelName=test\n'
        '• Windows Firewall allows Node on port 3000';
  }

  Future<void> _retry() async {
    setState(() {
      _error = null;
      _localUserJoined = false;
      _localUid = null;
      _remoteUid = null;
    });
    await _dispose();
    await initAgora();
  }

  Future<void> _endCall() async {
    await _dispose();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  Future<void> _dispose() async {
    final engine = _engine;
    if (engine == null) return;
    try {
      await engine.leaveChannel();
      await engine.release();
    } catch (_) {}
    _engine = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Session • ${widget.channelName}'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end, color: Colors.red),
            onPressed: _endCall,
          ),
        ],
      ),
      body: _error != null
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 24),
                    ElevatedButton(onPressed: _retry, child: const Text('Retry')),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                      child: const Text('Go back'),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                Center(child: _remoteVideo()),
                if (_localUserJoined && _localUid != null)
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 120,
                          height: 160,
                          child: AgoraVideoView(
                            controller: VideoViewController(
                              rtcEngine: _engine!,
                              canvas: VideoCanvas(
                                uid: _localUid,
                                renderMode: RenderModeType.renderModeHidden,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine!,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      );
    }
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Text(
        'Waiting for other participant…\n\nBoth users must join the same channel.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70, fontSize: 16),
      ),
    );
  }
}
