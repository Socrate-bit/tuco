const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const crypto = require("crypto");

// External AI provider credentials. Stored in Cloud Secret Manager and only
// ever read inside these functions — never shipped in the app binary.
const elevenLabsKey = defineSecret("ELEVENLABS_API_KEY");
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

// ---------------------------------------------------------------- ElevenLabs

const VOICE_ID = "ihKwLOjVUMG4lgUI6meZ";
const MODEL_ID = "eleven_flash_v2_5";

// Proxies ElevenLabs TTS so the API key stays server-side.
// Expects { text, languageCode } and returns { audio } (base64 MP3).
exports.tts = onCall(
  { secrets: [elevenLabsKey], region: REGION },
  async (request) => {
    requireAuth(request);
    const text = request.data?.text;
    if (typeof text !== "string" || !text.trim() || text.length > 2000) {
      throw new HttpsError("invalid-argument", "text is required (max 2000 chars).");
    }
    // Always enforce a language so short inputs (single words) aren't left to
    // the model's auto-detection, which mispronounces them with the voice's
    // native accent. Falls back to English when the client omits it.
    const languageCode = request.data?.languageCode || "en";

    const response = await fetch(
      `https://api.elevenlabs.io/v1/text-to-speech/${VOICE_ID}?output_format=mp3_44100_128`,
      {
        method: "POST",
        headers: {
          "xi-api-key": elevenLabsKey.value(),
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          text,
          model_id: MODEL_ID,
          language_code: languageCode,
        }),
      }
    );
    if (!response.ok) {
      const body = await response.text();
      console.error(`[tts] ElevenLabs error ${response.status}: ${body}`);
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
