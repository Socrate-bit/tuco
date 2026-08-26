/// Static articulation tips for common IPA phonemes, shown next to a phoneme
/// the learner mispronounced. Azure doesn't provide coaching text, so these are
/// hardcoded. English (IPA) focused — other locales fall back to no tip.
const Map<String, String> kPhonemeTips = {
  // Consonants
  'k': 'Stop the air completely, then release: press the back of your tongue '
      'against the roof of your mouth.',
  'g': 'Like /k/ but voiced — add your voice as the back of the tongue '
      'releases.',
  't': 'Tap the tip of your tongue behind your top teeth, then release '
      'sharply.',
  'd': 'Like /t/ but voiced — tongue tip behind the top teeth, with your '
      'voice on.',
  'p': 'Press both lips together and release with a small puff of air.',
  'b': 'Like /p/ but voiced — lips together, release with your voice on.',
  'θ': 'Put your tongue tip lightly between your teeth and push air out (as in '
      '"think").',
  'ð': 'Tongue between the teeth like /θ/, but voiced (as in "this").',
  's': 'Keep your tongue close to the ridge behind your teeth and hiss.',
  'z': 'Like /s/ but voiced — add your voice to the hiss.',
  'ʃ': 'Round your lips slightly and push air over a wider tongue (as in '
      '"she").',
  'ʒ': 'Like /ʃ/ but voiced (as in "measure").',
  'tʃ': 'Combine /t/ and /ʃ/ in one quick burst (as in "church").',
  'dʒ': 'Combine /d/ and /ʒ/ in one quick burst (as in "judge").',
  'r': 'Curl the tongue back without touching the roof of your mouth.',
  'l': 'Touch your tongue tip to the ridge behind your top teeth.',
  'n': 'Tongue tip on the ridge behind the teeth, send the sound through your '
      'nose.',
  'm': 'Close your lips and hum the sound through your nose.',
  'ŋ': 'Raise the back of your tongue and send the sound through your nose (as '
      'in "sing").',
  'h': 'Just breathe out gently — no tongue or lip contact.',
  'j': 'Glide quickly from a /i/ shape (as in "yes").',
  'w': 'Round your lips tightly, then glide open (as in "we").',
  'v': 'Rest your top teeth on your lower lip and voice the sound.',
  'f': 'Rest your top teeth on your lower lip and push air out.',
  // Vowels
  'i': 'A long, tense "ee" — smile slightly and keep the tongue high.',
  'ɪ': 'A short, relaxed "i" as in "sit" — lower and looser than /i/.',
  'u': 'A long "oo" — round your lips and keep the tongue back and high.',
  'ʊ': 'A short, relaxed "u" as in "book".',
  'æ': 'Open your mouth wide and drop your jaw (as in "cat").',
  'ə': 'A relaxed, neutral "uh" — the most common English vowel.',
  'ɛ': 'A short "e" as in "bed" — mouth slightly open.',
  'ɑ': 'Open wide with the tongue low and back (as in "father").',
  'ɔ': 'Round the lips a little with the tongue low and back (as in "thought").',
  'oʊ': 'Glide from "o" to "u", rounding the lips (as in "go").',
  'aɪ': 'Glide from "a" to "i" (as in "my").',
  'aʊ': 'Glide from "a" to "u" (as in "now").',
  'eɪ': 'Glide from "e" to "i" (as in "day").',
  'ɔɪ': 'Glide from "o" to "i" (as in "boy").',
  'ɝ': 'An r-colored vowel — curl the tongue as you voice it (as in "bird").',
  'ɚ': 'A relaxed r-colored "er" (as in "butter").',
};

/// Returns an articulation tip for [phoneme], or null when none is known.
String? phonemeTip(String phoneme) => kPhonemeTips[phoneme.trim()];
