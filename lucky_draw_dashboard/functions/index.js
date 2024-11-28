const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.updateUserEmail = functions.https.onCall(async (data, context) => {
  // No authentication check for simplicity (NOT recommended for production)
  const { uid, newEmail } = data;

  try {
    await admin.auth().updateUser(uid, { email: newEmail });
    return { message: `Email updated successfully to ${newEmail}` };
  } catch (error) {
    return { error: error.message };
  }
});

