"use strict";

// DermIQ payments backend — secure Razorpay flow.
//
//   createRazorpayOrder  → creates a Razorpay order server-side (amount can't be
//                          tampered with on the client) and returns the order id
//                          + the publishable key id for the checkout sheet.
//   verifyRazorpayPayment → recomputes the HMAC signature with the SECRET key and
//                          confirms the payment is genuine before the app trusts it.
//
// Secrets are stored in Secret Manager, never in the repo:
//   firebase functions:secrets:set RAZORPAY_KEY_ID
//   firebase functions:secrets:set RAZORPAY_KEY_SECRET

const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const crypto = require("crypto");
const Razorpay = require("razorpay");
const Anthropic = require("@anthropic-ai/sdk");

const RAZORPAY_KEY_ID = defineSecret("RAZORPAY_KEY_ID");
const RAZORPAY_KEY_SECRET = defineSecret("RAZORPAY_KEY_SECRET");
const ANTHROPIC_API_KEY = defineSecret("ANTHROPIC_API_KEY");

// DermIQ's in-app skincare assistant persona. Educational only — the client
// also shows a visible "not medical advice" disclaimer.
const DERMIQ_SYSTEM_PROMPT = [
  "You are DermIQ's friendly in-app skincare and haircare assistant.",
  "Give clear, practical, evidence-informed guidance on skincare ingredients,",
  "routines, product types, and common concerns (acne, dryness, pigmentation,",
  "hair fall, dandruff, etc.). Keep answers concise (2-4 short paragraphs or a",
  "tight bulleted list) and warm.",
  "",
  "IMPORTANT RULES:",
  "- You are NOT a doctor. Your guidance is educational, not medical advice.",
  "- For severe, painful, rapidly worsening, or persistent conditions, or",
  "  anything that could be a medical issue, recommend seeing a qualified",
  "  dermatologist instead of self-treating.",
  "- Never diagnose conditions or prescribe prescription medication or dosages.",
  "- Don't invent specific DermIQ product names or prices; speak in terms of",
  "  ingredient/product categories unless the user names a product.",
  "- Stay on skincare/haircare/wellness topics; politely redirect otherwise.",
].join("\n");

exports.createRazorpayOrder = onCall(
    {secrets: [RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET], region: "us-central1"},
    async (request) => {
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "Sign in to pay.");
      }
      // amount is in paise (₹1 = 100). Trust the server, not the client total.
      const amount = Number(request.data && request.data.amount);
      if (!Number.isInteger(amount) || amount <= 0) {
        throw new HttpsError(
            "invalid-argument", "amount (paise) must be a positive integer.");
      }

      const rzp = new Razorpay({
        key_id: RAZORPAY_KEY_ID.value(),
        key_secret: RAZORPAY_KEY_SECRET.value(),
      });

      const order = await rzp.orders.create({
        amount: amount,
        currency: "INR",
        receipt: (request.data && request.data.receipt) || `rcpt_${Date.now()}`,
        notes: {uid: request.auth.uid},
      });

      return {
        orderId: order.id,
        amount: order.amount,
        currency: order.currency,
        keyId: RAZORPAY_KEY_ID.value(),
      };
    },
);

exports.verifyRazorpayPayment = onCall(
    {secrets: [RAZORPAY_KEY_SECRET], region: "us-central1"},
    async (request) => {
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "Sign in to pay.");
      }
      const d = request.data || {};
      if (!d.orderId || !d.paymentId || !d.signature) {
        throw new HttpsError(
            "invalid-argument",
            "orderId, paymentId and signature are required.");
      }

      const expected = crypto
          .createHmac("sha256", RAZORPAY_KEY_SECRET.value())
          .update(`${d.orderId}|${d.paymentId}`)
          .digest("hex");

      let verified = false;
      try {
        verified = crypto.timingSafeEqual(
            Buffer.from(expected), Buffer.from(d.signature));
      } catch (_) {
        verified = false; // length mismatch ⇒ not a valid signature
      }
      return {verified};
    },
);

// ── Chat assistant — proxies to the Claude API (key stays server-side) ────────
exports.chatWithDermiq = onCall(
    {secrets: [ANTHROPIC_API_KEY], region: "us-central1"},
    async (request) => {
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "Sign in to chat.");
      }
      const raw = (request.data && request.data.messages) || [];
      // Keep only well-formed user/assistant text turns; cap history length.
      const messages = (Array.isArray(raw) ? raw : [])
          .filter((m) =>
            m &&
            (m.role === "user" || m.role === "assistant") &&
            typeof m.content === "string" &&
            m.content.trim().length > 0)
          .slice(-20)
          .map((m) => ({role: m.role, content: m.content.slice(0, 4000)}));

      if (messages.length === 0 || messages[messages.length - 1].role !== "user") {
        throw new HttpsError(
            "invalid-argument", "A non-empty user message is required.");
      }

      const client = new Anthropic({apiKey: ANTHROPIC_API_KEY.value()});
      const resp = await client.messages.create({
        model: "claude-haiku-4-5",
        max_tokens: 1024,
        system: DERMIQ_SYSTEM_PROMPT,
        messages,
      });

      const reply = resp.content
          .filter((b) => b.type === "text")
          .map((b) => b.text)
          .join("\n")
          .trim();

      return {
        reply: reply ||
          "Sorry, I couldn't generate a response just now. Please try again.",
      };
    },
);
