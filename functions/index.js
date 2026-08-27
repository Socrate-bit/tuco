const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");

const elevenLabsKey = defineSecret("ELEVENLABS_API_KEY");

const VOICE_ID = "ihKwLOjVUMG4lgUI6meZ";
const MODEL_ID = "eleven_flash_v2_5";

// Proxies ElevenLabs TTS so the API key stays server-side.
// Expects { text, languageCode } and returns { audio } (base64 MP3).
exports.tts = onCall(
  { secrets: [elevenLabsKey], region: "europe-west1" },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign-in required.");
    }
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
