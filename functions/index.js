const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

// Cấu hình email service (ví dụ với Gmail)
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: functions.config().email.user,
    pass: functions.config().email.pass,
  },
});

exports.sendVerificationEmail = functions.firestore
  .document("email_queue/{documentId}")
  .onCreate(async (snap, context) => {
    const emailData = snap.data();

    try {
      // Gửi email
      await transporter.sendMail({
        from: functions.config().email.user,
        to: emailData.to,
        subject: emailData.subject,
        text: emailData.body,
        html: emailData.body.replace(/\n/g, "<br>"),
      });

      // Cập nhật trạng thái email đã gửi
      await snap.ref.update({
        status: "sent",
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log("Email sent successfully");
    } catch (error) {
      console.error("Error sending email:", error);
      // Cập nhật trạng thái lỗi
      await snap.ref.update({
        status: "error",
        error: error.message,
      });
    }
  });
