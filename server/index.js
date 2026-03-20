const express = require('express');
const cors = require('cors');
const { RtcTokenBuilder, RtcRole } = require('agora-access-token');
const admin = require('firebase-admin');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// Initialize Firebase Admin for Push Notifications/Firestore Hooks
// NOTE: You must provide your own firebase-adminsdk service account JSON
// admin.initializeApp({
//   credential: admin.credential.cert(require('./firebaseServiceAccount.json')),
// });

app.get('/', (req, res) => {
  res.send('Abilify backend running!');
});

// Endpoint to generate Agora RTC Token
app.get('/agora-token', (req, res) => {
  res.header('Access-Control-Allow-Origin', '*');
  
  const channelName = req.query.channelName;
  console.log(`Token requested for channel: ${channelName}`);

  if (!channelName) {
    return res.status(500).json({ 'error': 'channelName is required' });
  }

  // Use uid = 0 to allow Agora to auto-assign a UID, or pass it explicitly
  let uid = req.query.uid;
  if (!uid || uid === '') {
    uid = 0;
  }
  
  const role = RtcRole.PUBLISHER;

  // Token valid for 2 hours
  const expireTime = 3600 * 2;
  const currentTime = Math.floor(Date.now() / 1000);
  const privilegeExpireTime = currentTime + expireTime;

  const appID = process.env.AGORA_APP_ID;
  const appCertificate = process.env.AGORA_APP_CERTIFICATE;

  if (!appID || !appCertificate) {
    return res.status(500).json({ 'error': 'Agora App ID or Certificate missing' });
  }

  try {
    const token = RtcTokenBuilder.buildTokenWithUid(
      appID,
      appCertificate,
      channelName,
      uid,
      role,
      privilegeExpireTime
    );
    return res.json({ 'token': token, 'channel': channelName });
  } catch (err) {
    console.error("Error generating token:", err);
    return res.status(500).json({ 'error': err.message });
  }
});

// Future endpoint for triggering push notifications via FCM
app.post('/notify', async (req, res) => {
  /*
  const { token, title, body } = req.body;
  const message = {
    notification: { title, body },
    token: token
  };
  try {
    await admin.messaging().send(message);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
  */
  res.json({ message: "Not implemented yet" });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Abilify backend server listening on http://0.0.0.0:${PORT}`);
  console.log('LAN: use your PC IPv4 in API_BASE_URL for physical phones');
});
