const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const crypto = require("crypto");

initializeApp();
const db = getFirestore();

// External AI provider credentials. Stored in Cloud Secret Manager and only
// ever read inside these functions — never shipped in the app binary.
const azureSpeechKey = defineSecret("AZURE_SPEECH_KEY");
const speechSuperAppKey = defineSecret("SPEECHSUPER_APP_KEY");
const speechSuperSecretKey = defineSecret("SPEECHSUPER_SECRET_KEY");

const REGION = "europe-west1";

// Every AI call is billed, so all functions require a signed-in caller.
function requireAuth(request) {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign-in required.");
  }
  return request.auth.uid;
}

// --------------------------------------------------------- Azure AI Speech

// Dragon HD Omni preview voice. The region is part of the endpoint host and
// must be one where Omni is available (eastus/westeurope/swedencentral/
// southeastasia).
const AZURE_REGION = "eastus";
const AZURE_VOICE = "en-us-jelly:DragonHDOmniLatestNeural";
const AZURE_OUTPUT_FORMAT = "audio-24khz-96kbitrate-mono-mp3";

// App language code → BCP-47 tag for the SSML <lang> element. Omni does
// auto-detect the language, but it guesses English for short Spanish inputs
// ("murciélago" comes out as "Mercia Lago"), so the language is always stated
// explicitly. Mapped here rather than taken from the client so nothing
// caller-controlled reaches the SSML. Adding a language is one row.
const SPEECH_LOCALES = {
  es: "es-ES",
  fr: "fr-FR",
  zh: "zh-CN",
  en: "en-US",
};

// The text comes from Gemini and goes inside an SSML document, so any XML
// metacharacter would break the request.
function escapeXml(text) {
  return text
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&apos;");
}

// Proxies Azure AI Speech synthesis so the API key stays server-side.
// Expects { text, languageCode } and returns { audio } (base64 MP3).
exports.tts = onCall(
  { secrets: [azureSpeechKey], region: REGION, timeoutSeconds: 30 },
  async (request) => {
    requireAuth(request);
    const text = request.data?.text;
    if (typeof text !== "string" || !text.trim() || text.length > 2000) {
      throw new HttpsError("invalid-argument", "text is required (max 2000 chars).");
    }
    const locale =
      SPEECH_LOCALES[request.data?.languageCode] || SPEECH_LOCALES.en;

    const ssml =
      '<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" ' +
      `xml:lang="${locale}"><voice name="${AZURE_VOICE}">` +
      `<lang xml:lang="${locale}">${escapeXml(text)}</lang>` +
      "</voice></speak>";

    const response = await fetch(
      `https://${AZURE_REGION}.tts.speech.microsoft.com/cognitiveservices/v1`,
      {
        method: "POST",
        headers: {
          "Ocp-Apim-Subscription-Key": azureSpeechKey.value(),
          "Content-Type": "application/ssml+xml",
          "X-Microsoft-OutputFormat": AZURE_OUTPUT_FORMAT,
          "User-Agent": "tuco",
        },
        body: ssml,
      }
    );
    if (!response.ok) {
      const body = await response.text();
      console.error(`[tts] Azure Speech error ${response.status}: ${body}`);
      throw new HttpsError("internal", "TTS synthesis failed.");
    }
    const audio = Buffer.from(await response.arrayBuffer()).toString("base64");
    return { audio };
  }
);

// --------------------------------------------------------------- SpeechSuper

const SPEECHSUPER_HOST = "https://api.speechsuper.com";

// App language code → (word coreType, sentence coreType). SpeechSuper's names
// are non-uniform per language, so map them explicitly — adding a language is
// one row. The coreType is also the URL path, so it lives here with the keys.
const CORE_TYPES = {
  es: ["word.eval.sp", "sent.eval.sp"],
  fr: ["word.eval.fr", "sent.eval.fr"],
  zh: ["word.eval.cn", "sent.eval.cn"],
  en: ["word.eval.promax", "sent.eval.promax"],
};

// ~5 MB of base64 ≈ 2 min of 16 kHz mono WAV — well past any single utterance,
// and under the callable request limit.
const MAX_AUDIO_BASE64 = 5 * 1024 * 1024;

// Proxies SpeechSuper's scripted pronunciation assessment so the app key,
// secret key and sha1 signing stay server-side.
// Expects { audio (base64 WAV, 16 kHz mono), referenceText, languageCode,
// granularity ('word' | 'sentence') } and returns { assessment } — the raw
// SpeechSuper JSON as a string, parsed by PronunciationResult on the client.
exports.assessPronunciation = onCall(
  {
    secrets: [speechSuperAppKey, speechSuperSecretKey],
    region: REGION,
    memory: "512MiB",
    timeoutSeconds: 60,
  },
  async (request) => {
    const userId = requireAuth(request);

    const referenceText = request.data?.referenceText;
    if (typeof referenceText !== "string" || !referenceText.trim()) {
      throw new HttpsError("invalid-argument", "referenceText is required.");
    }
    const audioBase64 = request.data?.audio;
    if (typeof audioBase64 !== "string" || !audioBase64) {
      throw new HttpsError("invalid-argument", "audio is required (base64 WAV).");
    }
    if (audioBase64.length > MAX_AUDIO_BASE64) {
      throw new HttpsError("invalid-argument", "audio is too long.");
    }

    const languageCode = request.data?.languageCode || "en";
    const pair = CORE_TYPES[languageCode];
    if (!pair) {
      console.warn(
        `[assessPronunciation] No coreType for "${languageCode}"; using English.`
      );
    }
    const [word, sentence] = pair || CORE_TYPES.en;
    const coreType = request.data?.granularity === "word" ? word : sentence;

    const appKey = speechSuperAppKey.value();
    const secretKey = speechSuperSecretKey.value();
    const timestamp = Date.now().toString();
    // Signatures: sha1 over appKey+timestamp(+userId)+secretKey.
    const sign = (data) =>
      crypto.createHash("sha1").update(data, "utf8").digest("hex");

    const params = {
      connect: {
        cmd: "connect",
        param: {
          sdk: { version: 16777472, source: 9, protocol: 2 },
          app: {
            applicationId: appKey,
            sig: sign(`${appKey}${timestamp}${secretKey}`),
            timestamp,
          },
        },
      },
      start: {
        cmd: "start",
        param: {
          app: {
            applicationId: appKey,
            sig: sign(`${appKey}${timestamp}${userId}${secretKey}`),
            userId,
            timestamp,
          },
          audio: {
            audioType: "wav",
            sampleRate: 16000,
            channel: 1,
            sampleBytes: 2,
          },
          request: {
            coreType,
            refText: referenceText.trim(),
            tokenId: timestamp,
            phoneme_output: 1, // request phoneme-level scores
          },
        },
      },
    };

    const form = new FormData();
    form.append("text", JSON.stringify(params));
    form.append(
      "audio",
      new Blob([Buffer.from(audioBase64, "base64")], { type: "audio/wav" }),
      "audio.wav"
    );

    const response = await fetch(`${SPEECHSUPER_HOST}/${coreType}`, {
      method: "POST",
      headers: { "Request-Index": "0" },
      body: form,
    });
    const body = await response.text();
    if (!response.ok) {
      console.error(
        `[assessPronunciation] SpeechSuper error ${response.status}: ${body}`
      );
      throw new HttpsError("internal", "Pronunciation assessment failed.");
    }
    console.log(`[assessPronunciation] Scored "${coreType}" for ${userId}`);
    return { assessment: body };
  }
);

// ------------------------------------------------------------ Promo codes

// Atomically redeems a promo code:
// 1. Validates the code exists with the required fields (type, num_use, max_use)
// 2. Checks the code is not exhausted (num_use < max_use)
// 3. Checks the caller hasn't already used this code
// 4. Increments num_use and appends the uid to usedBy
// 5. Sets user_type on the user document
// Expects { code } and returns { user_type }.
exports.redeemPromoCode = onCall({ region: REGION }, async (request) => {
  const uid = requireAuth(request);
  const code = request.data?.code;
  if (typeof code !== "string" || code.trim().length === 0) {
    throw new HttpsError("invalid-argument", "A promo code is required.");
  }

  const codeRef = db.collection("promoCodes").doc(code.trim());
  const userRef = db.collection("users").doc(uid);

  const userType = await db.runTransaction(async (tx) => {
    const codeSnap = await tx.get(codeRef);
    if (!codeSnap.exists) {
      throw new HttpsError("not-found", "Promo code does not exist.");
    }
    const data = codeSnap.data();
    const type = data.type;
    const numUse = data.num_use;
    const maxUse = data.max_use;

    if (type === undefined || numUse === undefined || maxUse === undefined) {
      throw new HttpsError("failed-precondition", "Invalid promo code.");
    }
    if (numUse >= maxUse) {
      throw new HttpsError(
        "resource-exhausted",
        "This code has reached its usage limit."
      );
    }
    const usedBy = data.usedBy || [];
    if (usedBy.includes(uid)) {
      throw new HttpsError("already-exists", "You have already used this code.");
    }

    tx.update(codeRef, {
      num_use: FieldValue.increment(1),
      usedBy: FieldValue.arrayUnion(uid),
    });
    tx.set(userRef, { user_type: type }, { merge: true });

    return type;
  });

  console.log(`[redeemPromoCode] ${uid} redeemed "${code.trim()}" → ${userType}`);
  return { user_type: userType };
});
