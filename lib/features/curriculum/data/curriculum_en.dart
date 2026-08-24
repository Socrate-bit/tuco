import '../model/curriculum_models.dart';

/// Bundled English curriculum: three levels of lessons plus a bank of extra
/// vocabulary used to fill the "upcoming words" queue.
///
/// Learners of English come from every native language, so each entry pairs
/// the word with a short plain-English gloss instead of a translation; the
/// tutor translates on demand during the call.
const Curriculum englishCurriculum = Curriculum(
  language: 'en',
  levels: [
    // ------------------------------------------------------------------
    // BEGINNER
    // ------------------------------------------------------------------
    Level(
      id: 'beginner',
      lessons: [
        Lesson(
          id: 'en-greetings',
          title: 'Greetings',
          description: 'Learn to greet people and say goodbye.',
          icon: 'wave',
          color: 0xFFF45B3D,
          vocab: [
            VocabWord(
              word: 'hello',
              translation: 'a greeting when you meet someone',
            ),
            VocabWord(
              word: 'goodbye',
              translation: 'what you say when you leave',
            ),
            VocabWord(
              word: 'good morning',
              translation: 'a greeting before noon',
            ),
            VocabWord(
              word: 'good night',
              translation: 'a greeting before sleeping',
            ),
            VocabWord(
              word: 'thank you',
              translation: 'words to show gratitude',
            ),
            VocabWord(
              word: 'how are you?',
              translation: 'asking about someone\'s day',
            ),
            VocabWord(
              word: 'nice to meet you',
              translation: 'said at a first meeting',
            ),
          ],
          grammarPoints: [
            'Greetings as fixed expressions',
            'Contractions: I am / I\'m',
          ],
        ),
        Lesson(
          id: 'en-introductions-1',
          title: 'Introductions I',
          description: 'Learn to introduce yourself in a basic way.',
          icon: 'flag',
          color: 0xFF16C4C4,
          vocab: [
            VocabWord(
              word: 'where are you from?',
              translation: 'asking about someone\'s country',
            ),
            VocabWord(
              word: 'I\'m from',
              translation: 'naming your country or city',
            ),
            VocabWord(word: 'my name is', translation: 'introducing yourself'),
            VocabWord(
              word: 'what\'s your name?',
              translation: 'asking for someone\'s name',
            ),
            VocabWord(
              word: 'this is',
              translation: 'introducing another person',
            ),
            VocabWord(
              word: 'to spell',
              translation: 'to say the letters of a word',
            ),
          ],
          grammarPoints: [
            'The verb "to be" in the present',
            'Subject pronouns I / you / he / she',
          ],
        ),
        Lesson(
          id: 'en-introductions-2',
          title: 'Introductions II',
          description: 'Share more details about yourself and where you live.',
          icon: 'chat',
          color: 0xFFA159E5,
          vocab: [
            VocabWord(
              word: 'I am ... years old',
              translation: 'saying your age',
            ),
            VocabWord(word: 'I live in', translation: 'naming where you live'),
            VocabWord(
              word: 'I speak',
              translation: 'naming a language you use',
            ),
            VocabWord(word: 'a little', translation: 'a small amount'),
            VocabWord(
              word: 'the language',
              translation: 'a system of words people speak',
            ),
            VocabWord(
              word: 'the country',
              translation: 'a nation such as Spain',
            ),
            VocabWord(word: 'the city', translation: 'a large town'),
            VocabWord(
              word: 'the neighbour',
              translation: 'a person living next to you',
            ),
          ],
          grammarPoints: [
            'Present simple with I / you / we',
            'Prepositions in / at for places',
          ],
        ),
        Lesson(
          id: 'en-at-the-cafe',
          title: 'At The Café',
          description: 'Order drinks politely at a café.',
          icon: 'food',
          color: 0xFF6EC53E,
          vocab: [
            VocabWord(
              word: 'the waiter',
              translation: 'the person serving you',
            ),
            VocabWord(
              word: 'the coffee',
              translation: 'a hot drink made from beans',
            ),
            VocabWord(
              word: 'the tea',
              translation: 'a hot drink made from leaves',
            ),
            VocabWord(word: 'the milk', translation: 'a white drink from cows'),
            VocabWord(word: 'the sugar', translation: 'sweet white grains'),
            VocabWord(
              word: 'I would like',
              translation: 'a polite way to order',
            ),
            VocabWord(
              word: 'the bill',
              translation: 'the paper showing what you owe',
            ),
            VocabWord(word: 'please', translation: 'a polite word in requests'),
          ],
          grammarPoints: [
            'Polite requests: "Could I have…?"',
            'Countable and uncountable nouns',
          ],
        ),
        Lesson(
          id: 'en-numbers',
          title: 'Numbers',
          description: 'Count from one to ten in English.',
          icon: 'numbers',
          color: 0xFFF2A93B,
          vocab: [
            VocabWord(word: 'one', translation: 'the number 1'),
            VocabWord(word: 'two', translation: 'the number 2'),
            VocabWord(word: 'three', translation: 'the number 3'),
            VocabWord(word: 'four', translation: 'the number 4'),
            VocabWord(word: 'five', translation: 'the number 5'),
            VocabWord(word: 'six', translation: 'the number 6'),
            VocabWord(word: 'seven', translation: 'the number 7'),
            VocabWord(word: 'eight', translation: 'the number 8'),
            VocabWord(word: 'nine', translation: 'the number 9'),
            VocabWord(word: 'ten', translation: 'the number 10'),
          ],
          grammarPoints: ['Cardinal numbers 1-10', 'Plural nouns with -s'],
        ),
        Lesson(
          id: 'en-family',
          title: 'Family',
          description: 'Talk about your close family members.',
          icon: 'family',
          color: 0xFF3F9FFF,
          vocab: [
            VocabWord(word: 'the mother', translation: 'your female parent'),
            VocabWord(word: 'the father', translation: 'your male parent'),
            VocabWord(word: 'the brother', translation: 'a male sibling'),
            VocabWord(word: 'the sister', translation: 'a female sibling'),
            VocabWord(
              word: 'the parents',
              translation: 'your mother and father',
            ),
            VocabWord(word: 'the son', translation: 'a male child'),
            VocabWord(word: 'the daughter', translation: 'a female child'),
            VocabWord(
              word: 'the grandparents',
              translation: 'your parents\' parents',
            ),
          ],
          grammarPoints: [
            'Possessive adjectives my / your / his / her',
            'Possessive \'s (my sister\'s house)',
          ],
        ),
        Lesson(
          id: 'en-at-the-restaurant',
          title: 'At The Restaurant',
          description: 'Order a full meal at a restaurant.',
          icon: 'restaurant',
          color: 0xFFFF6FA5,
          vocab: [
            VocabWord(word: 'the menu', translation: 'the list of dishes'),
            VocabWord(word: 'the starter', translation: 'the first small dish'),
            VocabWord(
              word: 'the main course',
              translation: 'the biggest dish of a meal',
            ),
            VocabWord(
              word: 'the dessert',
              translation: 'the sweet dish at the end',
            ),
            VocabWord(word: 'the meat', translation: 'food from animals'),
            VocabWord(
              word: 'the fish',
              translation: 'food from the sea or rivers',
            ),
            VocabWord(
              word: 'the vegetables',
              translation: 'plants you eat, like carrots',
            ),
            VocabWord(
              word: 'to book a table',
              translation: 'to reserve a place',
            ),
          ],
          grammarPoints: ['Some / any with food', 'Would like vs want'],
        ),
        Lesson(
          id: 'en-directions',
          title: 'Directions',
          description: 'Ask for and understand simple directions.',
          icon: 'directions',
          color: 0xFF8A6FE8,
          vocab: [
            VocabWord(
              word: 'on the left',
              translation: 'the side of your left hand',
            ),
            VocabWord(
              word: 'on the right',
              translation: 'the side of your right hand',
            ),
            VocabWord(
              word: 'straight ahead',
              translation: 'directly in front of you',
            ),
            VocabWord(word: 'the street', translation: 'a road in a town'),
            VocabWord(
              word: 'the corner',
              translation: 'where two streets meet',
            ),
            VocabWord(word: 'near', translation: 'a short distance away'),
            VocabWord(word: 'far from', translation: 'a long distance away'),
            VocabWord(word: 'to turn', translation: 'to change direction'),
          ],
          grammarPoints: [
            'Imperatives for directions (turn, go, take)',
            'Prepositions of place',
          ],
        ),
        Lesson(
          id: 'en-shopping',
          title: 'Shopping',
          description: 'Shop for things and talk about prices.',
          icon: 'shopping',
          color: 0xFFF45B3D,
          vocab: [
            VocabWord(
              word: 'the shop',
              translation: 'a place where you buy things',
            ),
            VocabWord(
              word: 'the market',
              translation: 'an open place with many sellers',
            ),
            VocabWord(word: 'how much is it?', translation: 'asking the price'),
            VocabWord(word: 'expensive', translation: 'costing a lot of money'),
            VocabWord(word: 'cheap', translation: 'costing little money'),
            VocabWord(word: 'the size', translation: 'how big something is'),
            VocabWord(
              word: 'to try on',
              translation: 'to put on clothes before buying',
            ),
            VocabWord(
              word: 'the checkout',
              translation: 'where you pay in a shop',
            ),
          ],
          grammarPoints: [
            'How much / how many',
            'Demonstratives this / that / these / those',
          ],
        ),
        Lesson(
          id: 'en-the-weather',
          title: 'The Weather',
          description: 'Describe the weather in any season.',
          icon: 'weather',
          color: 0xFF16C4C4,
          vocab: [
            VocabWord(word: 'sunny', translation: 'with a lot of sun'),
            VocabWord(
              word: 'to rain',
              translation: 'water falling from the sky',
            ),
            VocabWord(
              word: 'to snow',
              translation: 'white flakes falling from the sky',
            ),
            VocabWord(word: 'cold', translation: 'at a low temperature'),
            VocabWord(word: 'hot', translation: 'at a high temperature'),
            VocabWord(word: 'the wind', translation: 'moving air'),
            VocabWord(
              word: 'the cloud',
              translation: 'white or grey shape in the sky',
            ),
            VocabWord(
              word: 'the season',
              translation: 'spring, summer, autumn or winter',
            ),
          ],
          grammarPoints: [
            'Impersonal "it" for weather',
            'Present continuous (it is raining)',
          ],
        ),
        Lesson(
          id: 'en-daily-routine',
          title: 'My Daily Routine',
          description: 'Describe your daily routine from morning to night.',
          icon: 'routine',
          color: 0xFFA159E5,
          vocab: [
            VocabWord(word: 'to wake up', translation: 'to stop sleeping'),
            VocabWord(word: 'to get up', translation: 'to leave your bed'),
            VocabWord(
              word: 'to have breakfast',
              translation: 'to eat the first meal',
            ),
            VocabWord(
              word: 'to go to work',
              translation: 'to travel to your job',
            ),
            VocabWord(
              word: 'to have lunch',
              translation: 'to eat the midday meal',
            ),
            VocabWord(
              word: 'to come home',
              translation: 'to return to your house',
            ),
            VocabWord(
              word: 'to have dinner',
              translation: 'to eat the evening meal',
            ),
            VocabWord(word: 'to go to bed', translation: 'to go and sleep'),
          ],
          grammarPoints: [
            'Present simple with he / she / it (-s)',
            'Adverbs of frequency (always, often, never)',
          ],
        ),
        Lesson(
          id: 'en-good-friends',
          title: 'Good Friends',
          description: 'Talk about friendship and spending time together.',
          icon: 'friends',
          color: 0xFF6EC53E,
          vocab: [
            VocabWord(
              word: 'the friend',
              translation: 'a person you like and know well',
            ),
            VocabWord(
              word: 'to meet up',
              translation: 'to see each other on purpose',
            ),
            VocabWord(word: 'to go out', translation: 'to leave home for fun'),
            VocabWord(word: 'to laugh', translation: 'to make a happy sound'),
            VocabWord(
              word: 'to trust',
              translation: 'to believe someone is honest',
            ),
            VocabWord(word: 'together', translation: 'with each other'),
            VocabWord(
              word: 'to hang out',
              translation: 'to spend relaxed time together',
            ),
          ],
          grammarPoints: [
            'Object pronouns me / him / her / them',
            'Let\'s + verb for suggestions',
          ],
        ),
        Lesson(
          id: 'en-celebrations',
          title: 'Celebrations',
          description: 'Celebrate birthdays, holidays and festivals.',
          icon: 'celebration',
          color: 0xFFF2A93B,
          vocab: [
            VocabWord(word: 'the party', translation: 'a social event for fun'),
            VocabWord(
              word: 'the birthday',
              translation: 'the day you were born',
            ),
            VocabWord(
              word: 'Christmas',
              translation: 'the holiday on 25 December',
            ),
            VocabWord(word: 'New Year', translation: 'the start of a new year'),
            VocabWord(
              word: 'the gift',
              translation: 'something you give someone',
            ),
            VocabWord(word: 'the cake', translation: 'a sweet baked dessert'),
            VocabWord(
              word: 'to celebrate',
              translation: 'to do something special for an event',
            ),
            VocabWord(word: 'to invite', translation: 'to ask someone to come'),
          ],
          grammarPoints: [
            'Going to for plans',
            'Prepositions of time in / on / at',
          ],
        ),
        Lesson(
          id: 'en-opinions',
          title: 'Giving Opinions',
          description: 'Give simple opinions and agree or disagree.',
          icon: 'opinions',
          color: 0xFF3F9FFF,
          vocab: [
            VocabWord(
              word: 'I think that',
              translation: 'introducing your view',
            ),
            VocabWord(word: 'in my opinion', translation: 'the way you see it'),
            VocabWord(word: 'I agree', translation: 'you have the same view'),
            VocabWord(
              word: 'I disagree',
              translation: 'you have a different view',
            ),
            VocabWord(word: 'maybe', translation: 'possibly, not sure'),
            VocabWord(word: 'of course', translation: 'certainly, clearly'),
            VocabWord(
              word: 'it depends',
              translation: 'the answer changes with the situation',
            ),
            VocabWord(word: 'to prefer', translation: 'to like one thing more'),
          ],
          grammarPoints: [
            'I think / I don\'t think + clause',
            'Negation with don\'t / doesn\'t',
          ],
        ),
      ],
    ),
    // ------------------------------------------------------------------
    // INTERMEDIATE
    // ------------------------------------------------------------------
    Level(
      id: 'intermediate',
      lessons: [
        Lesson(
          id: 'en-childrens-activities',
          title: 'Children\'s Activities',
          description: 'Talk about games and activities children enjoy.',
          icon: 'toys',
          color: 0xFFF45B3D,
          vocab: [
            VocabWord(
              word: 'the toy',
              translation: 'an object children play with',
            ),
            VocabWord(
              word: 'the doll',
              translation: 'a small model of a person',
            ),
            VocabWord(
              word: 'the swing',
              translation: 'a seat hanging on ropes',
            ),
            VocabWord(
              word: 'hide and seek',
              translation: 'a game of hiding and finding',
            ),
            VocabWord(
              word: 'the playground',
              translation: 'an outdoor place for children to play',
            ),
            VocabWord(
              word: 'the ball',
              translation: 'a round object used in games',
            ),
            VocabWord(
              word: 'to draw',
              translation: 'to make a picture with a pen',
            ),
            VocabWord(
              word: 'the board game',
              translation: 'a game played on a board',
            ),
          ],
          grammarPoints: [
            'Used to for past habits',
            'Past simple of regular verbs',
          ],
        ),
        Lesson(
          id: 'en-digital-technology',
          title: 'Digital Technology',
          description: 'Talk about computers, apps and life online.',
          icon: 'tech',
          color: 0xFF16C4C4,
          vocab: [
            VocabWord(
              word: 'the computer',
              translation: 'a machine for work and internet',
            ),
            VocabWord(
              word: 'the mobile phone',
              translation: 'a phone you carry with you',
            ),
            VocabWord(word: 'the app', translation: 'a program on a phone'),
            VocabWord(
              word: 'social media',
              translation: 'online places to share and chat',
            ),
            VocabWord(
              word: 'to download',
              translation: 'to copy a file to your device',
            ),
            VocabWord(
              word: 'the password',
              translation: 'a secret word to log in',
            ),
            VocabWord(
              word: 'the screen',
              translation: 'the flat display you look at',
            ),
            VocabWord(word: 'online', translation: 'connected to the internet'),
          ],
          grammarPoints: [
            'Phrasal verbs (log in, sign up, turn off)',
            'Present perfect for recent actions',
          ],
        ),
        Lesson(
          id: 'en-gifts',
          title: 'Gifts',
          description: 'Give and receive gifts for special occasions.',
          icon: 'gift',
          color: 0xFFA159E5,
          vocab: [
            VocabWord(word: 'to wrap', translation: 'to cover a gift in paper'),
            VocabWord(
              word: 'the card',
              translation: 'folded paper with a message',
            ),
            VocabWord(
              word: 'the surprise',
              translation: 'something unexpected',
            ),
            VocabWord(
              word: 'to thank',
              translation: 'to show you are grateful',
            ),
            VocabWord(
              word: 'the ribbon',
              translation: 'a thin strip for decoration',
            ),
            VocabWord(
              word: 'the wish list',
              translation: 'things you would like to receive',
            ),
            VocabWord(
              word: 'to receive',
              translation: 'to get something from someone',
            ),
          ],
          grammarPoints: [
            'Indirect objects (give her a gift)',
            'Verbs give / get / send',
          ],
        ),
        Lesson(
          id: 'en-work',
          title: 'Work',
          description: 'Discuss jobs, interviews and office life.',
          icon: 'work',
          color: 0xFF6EC53E,
          vocab: [
            VocabWord(
              word: 'the interview',
              translation: 'a meeting to get a job',
            ),
            VocabWord(
              word: 'the résumé',
              translation: 'a document listing your experience',
            ),
            VocabWord(
              word: 'the colleague',
              translation: 'a person you work with',
            ),
            VocabWord(
              word: 'the meeting',
              translation: 'people gathering to discuss work',
            ),
            VocabWord(word: 'the salary', translation: 'the money you earn'),
            VocabWord(
              word: 'the office',
              translation: 'the place where you work',
            ),
            VocabWord(
              word: 'the company',
              translation: 'a business organization',
            ),
            VocabWord(
              word: 'to apply',
              translation: 'to ask formally for a job',
            ),
          ],
          grammarPoints: [
            'Present perfect with for / since',
            'Modal verbs can / must / have to',
          ],
        ),
        Lesson(
          id: 'en-air-travel',
          title: 'Air Travel',
          description: 'Navigate airports and flights with confidence.',
          icon: 'plane',
          color: 0xFFF2A93B,
          vocab: [
            VocabWord(
              word: 'the airport',
              translation: 'where planes take off and land',
            ),
            VocabWord(word: 'the flight', translation: 'a journey by plane'),
            VocabWord(
              word: 'the boarding pass',
              translation: 'the ticket to get on the plane',
            ),
            VocabWord(
              word: 'the luggage',
              translation: 'the bags you travel with',
            ),
            VocabWord(
              word: 'the passport',
              translation: 'your travel identity document',
            ),
            VocabWord(
              word: 'to take off',
              translation: 'when a plane leaves the ground',
            ),
            VocabWord(
              word: 'to land',
              translation: 'when a plane touches the ground',
            ),
            VocabWord(
              word: 'the delay',
              translation: 'when something happens later than planned',
            ),
          ],
          grammarPoints: [
            'Past simple of irregular verbs',
            'Prepositions of movement to / from / via',
          ],
        ),
        Lesson(
          id: 'en-health',
          title: 'Health',
          description: 'Explain symptoms and visit the doctor.',
          icon: 'health',
          color: 0xFF3F9FFF,
          vocab: [
            VocabWord(
              word: 'the doctor',
              translation: 'a person who treats illness',
            ),
            VocabWord(
              word: 'the pain',
              translation: 'an unpleasant feeling in the body',
            ),
            VocabWord(
              word: 'the fever',
              translation: 'a high body temperature',
            ),
            VocabWord(
              word: 'the cold',
              translation: 'a mild illness with a runny nose',
            ),
            VocabWord(
              word: 'the medicine',
              translation: 'what you take to feel better',
            ),
            VocabWord(
              word: 'the prescription',
              translation: 'a doctor\'s note for medicine',
            ),
            VocabWord(
              word: 'the pharmacy',
              translation: 'the shop selling medicine',
            ),
            VocabWord(word: 'to rest', translation: 'to stop and relax'),
          ],
          grammarPoints: [
            '"I have a…" for symptoms',
            'Should / shouldn\'t for advice',
          ],
        ),
        Lesson(
          id: 'en-the-environment',
          title: 'The Environment',
          description: 'Discuss nature, recycling and climate change.',
          icon: 'nature',
          color: 0xFFFF6FA5,
          vocab: [
            VocabWord(word: 'recycling', translation: 'using materials again'),
            VocabWord(
              word: 'the waste',
              translation: 'things people throw away',
            ),
            VocabWord(
              word: 'the pollution',
              translation: 'dirt and gases harming nature',
            ),
            VocabWord(
              word: 'the climate',
              translation: 'the usual weather of a region',
            ),
            VocabWord(
              word: 'the energy',
              translation: 'power for light, heat and machines',
            ),
            VocabWord(word: 'the forest', translation: 'a large area of trees'),
            VocabWord(
              word: 'to protect',
              translation: 'to keep something safe',
            ),
            VocabWord(
              word: 'global warming',
              translation: 'the rise of Earth\'s temperature',
            ),
          ],
          grammarPoints: [
            'Comparatives and superlatives',
            'Passive voice in the present',
          ],
        ),
        Lesson(
          id: 'en-future-plans',
          title: 'Future Plans',
          description: 'Talk about goals, dreams and future plans.',
          icon: 'future',
          color: 0xFF8A6FE8,
          vocab: [
            VocabWord(
              word: 'the dream',
              translation: 'something you hope to achieve',
            ),
            VocabWord(word: 'the goal', translation: 'a result you aim for'),
            VocabWord(
              word: 'the hope',
              translation: 'the wish for a good outcome',
            ),
            VocabWord(word: 'to succeed', translation: 'to reach your goal'),
            VocabWord(
              word: 'to move house',
              translation: 'to go and live somewhere else',
            ),
            VocabWord(
              word: 'to save money',
              translation: 'to keep money for later',
            ),
            VocabWord(
              word: 'the career',
              translation: 'your long-term working life',
            ),
            VocabWord(
              word: 'in five years',
              translation: 'a point in the future',
            ),
          ],
          grammarPoints: [
            'Will vs going to',
            'First conditional (if + present, will)',
          ],
        ),
        Lesson(
          id: 'en-childhood-memories',
          title: 'Childhood Memories',
          description: 'Share memories from when you were a child.',
          icon: 'memories',
          color: 0xFFF45B3D,
          vocab: [
            VocabWord(
              word: 'the memory',
              translation: 'something you remember',
            ),
            VocabWord(
              word: 'the childhood',
              translation: 'the time when you were a child',
            ),
            VocabWord(
              word: 'when I was little',
              translation: 'in your early years',
            ),
            VocabWord(
              word: 'primary school',
              translation: 'the first school for children',
            ),
            VocabWord(
              word: 'the holidays',
              translation: 'time away from school or work',
            ),
            VocabWord(word: 'to grow up', translation: 'to become an adult'),
            VocabWord(
              word: 'back then',
              translation: 'at that time in the past',
            ),
          ],
          grammarPoints: [
            'Past simple vs past continuous',
            'Used to and would for the past',
          ],
        ),
        Lesson(
          id: 'en-british-cooking',
          title: 'Cooking And Food',
          description: 'Cook and talk about classic English-speaking dishes.',
          icon: 'cooking',
          color: 0xFF16C4C4,
          vocab: [
            VocabWord(
              word: 'the recipe',
              translation: 'instructions for making a dish',
            ),
            VocabWord(
              word: 'the ingredient',
              translation: 'one item used in a dish',
            ),
            VocabWord(word: 'to bake', translation: 'to cook in an oven'),
            VocabWord(
              word: 'to boil',
              translation: 'to cook in very hot water',
            ),
            VocabWord(word: 'to fry', translation: 'to cook in hot oil'),
            VocabWord(word: 'the pan', translation: 'a flat pot for cooking'),
            VocabWord(word: 'the oven', translation: 'the box that bakes food'),
            VocabWord(
              word: 'the sauce',
              translation: 'a thick liquid served with food',
            ),
          ],
          grammarPoints: [
            'Imperatives in recipes',
            'Quantifiers a lot of / a few / a little',
          ],
        ),
        Lesson(
          id: 'en-sports-and-exercise',
          title: 'Sports And Exercise',
          description: 'Talk about sports, training and staying fit.',
          icon: 'sports',
          color: 0xFFA159E5,
          vocab: [
            VocabWord(
              word: 'the training',
              translation: 'practice to get better',
            ),
            VocabWord(
              word: 'the match',
              translation: 'a game between two sides',
            ),
            VocabWord(
              word: 'the team',
              translation: 'a group playing together',
            ),
            VocabWord(word: 'to run', translation: 'to move fast on foot'),
            VocabWord(
              word: 'the gym',
              translation: 'a place with exercise machines',
            ),
            VocabWord(word: 'to win', translation: 'to finish first'),
            VocabWord(word: 'to lose', translation: 'to not win'),
            VocabWord(
              word: 'to warm up',
              translation: 'to prepare your body before sport',
            ),
          ],
          grammarPoints: [
            'Play / do / go with sports',
            'Present continuous for current activity',
          ],
        ),
        Lesson(
          id: 'en-the-news',
          title: 'The News',
          description: 'Understand headlines and talk about current events.',
          icon: 'news',
          color: 0xFF6EC53E,
          vocab: [
            VocabWord(word: 'the newspaper', translation: 'printed daily news'),
            VocabWord(
              word: 'the headline',
              translation: 'the title of a news story',
            ),
            VocabWord(word: 'the article', translation: 'a written news piece'),
            VocabWord(
              word: 'the journalist',
              translation: 'a person who reports news',
            ),
            VocabWord(word: 'the event', translation: 'something that happens'),
            VocabWord(
              word: 'the source',
              translation: 'where information comes from',
            ),
            VocabWord(
              word: 'the channel',
              translation: 'a TV or radio station',
            ),
            VocabWord(word: 'to happen', translation: 'to take place'),
          ],
          grammarPoints: [
            'Reported speech basics',
            'Passive voice in the past',
          ],
        ),
      ],
    ),
    // ------------------------------------------------------------------
    // ADVANCED
    // ------------------------------------------------------------------
    Level(
      id: 'advanced',
      lessons: [
        Lesson(
          id: 'en-debates',
          title: 'Debates And Arguments',
          description: 'Defend your point of view in a structured debate.',
          icon: 'debate',
          color: 0xFFF45B3D,
          vocab: [
            VocabWord(
              word: 'the argument',
              translation: 'a reason supporting a view',
            ),
            VocabWord(
              word: 'the evidence',
              translation: 'facts that prove something',
            ),
            VocabWord(
              word: 'however',
              translation: 'a word introducing a contrast',
            ),
            VocabWord(
              word: 'on the other hand',
              translation: 'introducing the opposite side',
            ),
            VocabWord(word: 'to support', translation: 'to back up a claim'),
            VocabWord(
              word: 'to refute',
              translation: 'to prove something wrong',
            ),
            VocabWord(
              word: 'the nuance',
              translation: 'a small but important difference',
            ),
            VocabWord(
              word: 'to convince',
              translation: 'to make someone believe you',
            ),
          ],
          grammarPoints: [
            'Concessive clauses (although, even though)',
            'Hedging language (tend to, arguably)',
          ],
        ),
        Lesson(
          id: 'en-idioms',
          title: 'Idioms And Sayings',
          description: 'Master common English idioms and sayings.',
          icon: 'idioms',
          color: 0xFF16C4C4,
          vocab: [
            VocabWord(
              word: 'to cost an arm and a leg',
              translation: 'to be very expensive',
            ),
            VocabWord(
              word: 'under the weather',
              translation: 'feeling slightly ill',
            ),
            VocabWord(
              word: 'to break the ice',
              translation: 'to start a conversation',
            ),
            VocabWord(
              word: 'a piece of cake',
              translation: 'something very easy',
            ),
            VocabWord(word: 'to hit the books', translation: 'to study hard'),
            VocabWord(
              word: 'to call it a day',
              translation: 'to stop working for now',
            ),
            VocabWord(word: 'once in a blue moon', translation: 'very rarely'),
            VocabWord(
              word: 'to be on the same page',
              translation: 'to agree and understand each other',
            ),
          ],
          grammarPoints: [
            'Fixed idiomatic expressions',
            'Register: formal vs informal',
          ],
        ),
        Lesson(
          id: 'en-business',
          title: 'The Business World',
          description: 'Negotiate and do business in English.',
          icon: 'business',
          color: 0xFFA159E5,
          vocab: [
            VocabWord(
              word: 'the revenue',
              translation: 'the money a business takes in',
            ),
            VocabWord(
              word: 'the negotiation',
              translation: 'a discussion to reach a deal',
            ),
            VocabWord(
              word: 'the contract',
              translation: 'a legal written agreement',
            ),
            VocabWord(
              word: 'the investment',
              translation: 'money put in to gain more',
            ),
            VocabWord(
              word: 'the market',
              translation: 'buyers and sellers of a product',
            ),
            VocabWord(
              word: 'the profit',
              translation: 'money left after costs',
            ),
            VocabWord(
              word: 'the stakeholder',
              translation: 'someone affected by a decision',
            ),
            VocabWord(
              word: 'the quote',
              translation: 'a stated price for work',
            ),
          ],
          grammarPoints: [
            'Polite conditionals in negotiation',
            'Formal email register',
          ],
        ),
        Lesson(
          id: 'en-culture-and-history',
          title: 'Culture And History',
          description: 'Explore the history of the English-speaking world.',
          icon: 'culture',
          color: 0xFF6EC53E,
          vocab: [
            VocabWord(
              word: 'the revolution',
              translation: 'a great political change',
            ),
            VocabWord(
              word: 'the century',
              translation: 'a period of one hundred years',
            ),
            VocabWord(
              word: 'the heritage',
              translation: 'traditions passed down',
            ),
            VocabWord(
              word: 'the monarchy',
              translation: 'rule by a king or queen',
            ),
            VocabWord(
              word: 'the empire',
              translation: 'a group of ruled territories',
            ),
            VocabWord(
              word: 'the era',
              translation: 'a distinct period of time',
            ),
            VocabWord(
              word: 'the war',
              translation: 'armed conflict between states',
            ),
          ],
          grammarPoints: [
            'Past perfect for earlier events',
            'Dates and centuries',
          ],
        ),
        Lesson(
          id: 'en-literature',
          title: 'English Literature',
          description: 'Read and discuss literature in English.',
          icon: 'book',
          color: 0xFFF2A93B,
          vocab: [
            VocabWord(word: 'the novel', translation: 'a long fictional story'),
            VocabWord(word: 'the poetry', translation: 'writing in verse'),
            VocabWord(
              word: 'the author',
              translation: 'the person who wrote it',
            ),
            VocabWord(
              word: 'the character',
              translation: 'a person in a story',
            ),
            VocabWord(word: 'the plot', translation: 'the events of a story'),
            VocabWord(
              word: 'the metaphor',
              translation: 'an image standing for something else',
            ),
            VocabWord(word: 'the chapter', translation: 'one part of a book'),
          ],
          grammarPoints: [
            'Narrative tenses',
            'Relative clauses (who, which, whose)',
          ],
        ),
        Lesson(
          id: 'en-music-and-traditions',
          title: 'Music And Traditions',
          description: 'Dive into genres, rhythms and musical culture.',
          icon: 'music',
          color: 0xFF3F9FFF,
          vocab: [
            VocabWord(
              word: 'the song',
              translation: 'a short piece of music with words',
            ),
            VocabWord(
              word: 'the chorus',
              translation: 'the repeated part of a song',
            ),
            VocabWord(word: 'the melody', translation: 'the main tune'),
            VocabWord(word: 'the singer', translation: 'a person who sings'),
            VocabWord(word: 'the band', translation: 'a group of musicians'),
            VocabWord(word: 'the festival', translation: 'a large music event'),
            VocabWord(word: 'the lyrics', translation: 'the words of a song'),
          ],
          grammarPoints: ['Superlatives in reviews', 'Vocabulary of the arts'],
        ),
        Lesson(
          id: 'en-city-life',
          title: 'City Life',
          description: 'Discuss urban life, housing and city problems.',
          icon: 'city',
          color: 0xFFFF6FA5,
          vocab: [
            VocabWord(
              word: 'the neighbourhood',
              translation: 'the area where you live',
            ),
            VocabWord(
              word: 'the rent',
              translation: 'money paid to live somewhere',
            ),
            VocabWord(
              word: 'public transport',
              translation: 'buses, trains and metros',
            ),
            VocabWord(
              word: 'the traffic jam',
              translation: 'a long line of stopped cars',
            ),
            VocabWord(
              word: 'the suburbs',
              translation: 'residential areas outside the centre',
            ),
            VocabWord(
              word: 'the pavement',
              translation: 'the path beside a road',
            ),
            VocabWord(
              word: 'the flat',
              translation: 'a home inside a building',
            ),
            VocabWord(
              word: 'the town hall',
              translation: 'the local government building',
            ),
          ],
          grammarPoints: [
            'Second conditional for hypotheses',
            'There is / there are with quantities',
          ],
        ),
        Lesson(
          id: 'en-love-and-relationships',
          title: 'Love And Relationships',
          description: 'Talk about love, dating and long-term relationships.',
          icon: 'heart',
          color: 0xFF8A6FE8,
          vocab: [
            VocabWord(
              word: 'to fall in love',
              translation: 'to start loving someone',
            ),
            VocabWord(
              word: 'the couple',
              translation: 'two people in a relationship',
            ),
            VocabWord(
              word: 'the trust',
              translation: 'belief in someone\'s honesty',
            ),
            VocabWord(word: 'to argue', translation: 'to disagree loudly'),
            VocabWord(
              word: 'to make up',
              translation: 'to become friendly again',
            ),
            VocabWord(
              word: 'the commitment',
              translation: 'a promise to stay involved',
            ),
            VocabWord(
              word: 'the break-up',
              translation: 'the end of a relationship',
            ),
            VocabWord(
              word: 'to get married',
              translation: 'to become husband and wife',
            ),
          ],
          grammarPoints: [
            'Third conditional for regrets',
            'Reciprocal pronouns (each other)',
          ],
        ),
        Lesson(
          id: 'en-media-and-journalism',
          title: 'Media And Journalism',
          description: 'Analyze the press, media bias and free speech.',
          icon: 'news',
          color: 0xFFF45B3D,
          vocab: [
            VocabWord(
              word: 'the press',
              translation: 'newspapers and news media',
            ),
            VocabWord(
              word: 'freedom of speech',
              translation: 'the right to say your views',
            ),
            VocabWord(
              word: 'the censorship',
              translation: 'blocking information',
            ),
            VocabWord(
              word: 'the audience',
              translation: 'the people watching or reading',
            ),
            VocabWord(
              word: 'the coverage',
              translation: 'how a story is reported',
            ),
            VocabWord(
              word: 'the bias',
              translation: 'unfair preference for one side',
            ),
            VocabWord(
              word: 'the newsroom',
              translation: 'where journalists work',
            ),
            VocabWord(
              word: 'the editorial',
              translation: 'an opinion piece by the editors',
            ),
          ],
          grammarPoints: [
            'Reporting verbs (claim, deny, admit)',
            'Formal written register',
          ],
        ),
        Lesson(
          id: 'en-everyday-slang',
          title: 'Everyday Slang',
          description: 'Sound natural with everyday spoken English.',
          icon: 'chat',
          color: 0xFF16C4C4,
          vocab: [
            VocabWord(word: 'awesome', translation: 'very good (informal)'),
            VocabWord(word: 'a mate', translation: 'a friend (informal)'),
            VocabWord(word: 'to chill', translation: 'to relax'),
            VocabWord(
              word: 'no worries',
              translation: 'that\'s fine, no problem',
            ),
            VocabWord(word: 'kind of', translation: 'more or less, a bit'),
            VocabWord(word: 'to be broke', translation: 'to have no money'),
            VocabWord(word: 'to hang on', translation: 'to wait a moment'),
            VocabWord(
              word: 'that sucks',
              translation: 'that is bad (informal)',
            ),
          ],
          grammarPoints: [
            'Contractions and reduced forms (gonna, wanna)',
            'Informal question tags',
          ],
        ),
      ],
    ),
  ],
  extraVocabulary: [
    // ---------------- Colors ----------------
    VocabWord(word: 'red', translation: 'the colour of blood'),
    VocabWord(word: 'blue', translation: 'the colour of the sky'),
    VocabWord(word: 'green', translation: 'the colour of grass'),
    VocabWord(word: 'yellow', translation: 'the colour of the sun'),
    VocabWord(word: 'black', translation: 'the darkest colour'),
    VocabWord(word: 'white', translation: 'the lightest colour'),
    VocabWord(word: 'grey', translation: 'between black and white'),
    VocabWord(word: 'purple', translation: 'a mix of red and blue'),
    VocabWord(word: 'pink', translation: 'a light red colour'),
    VocabWord(word: 'brown', translation: 'the colour of wood'),

    // ---------------- Numbers ----------------
    VocabWord(word: 'eleven', translation: 'the number 11'),
    VocabWord(word: 'twelve', translation: 'the number 12'),
    VocabWord(word: 'thirteen', translation: 'the number 13'),
    VocabWord(word: 'fifteen', translation: 'the number 15'),
    VocabWord(word: 'twenty', translation: 'the number 20'),
    VocabWord(word: 'thirty', translation: 'the number 30'),
    VocabWord(word: 'fifty', translation: 'the number 50'),
    VocabWord(word: 'a hundred', translation: 'the number 100'),
    VocabWord(word: 'a thousand', translation: 'the number 1000'),
    VocabWord(word: 'first', translation: 'number one in order'),
    VocabWord(word: 'second', translation: 'number two in order'),

    // ---------------- Days & time ----------------
    VocabWord(word: 'Monday', translation: 'the first weekday'),
    VocabWord(word: 'Tuesday', translation: 'the second weekday'),
    VocabWord(word: 'Wednesday', translation: 'the third weekday'),
    VocabWord(word: 'Thursday', translation: 'the fourth weekday'),
    VocabWord(word: 'Friday', translation: 'the last weekday'),
    VocabWord(word: 'Saturday', translation: 'the first weekend day'),
    VocabWord(word: 'Sunday', translation: 'the second weekend day'),
    VocabWord(word: 'today', translation: 'this day'),
    VocabWord(word: 'tomorrow', translation: 'the day after today'),
    VocabWord(word: 'yesterday', translation: 'the day before today'),
    VocabWord(word: 'the morning', translation: 'the early part of the day'),
    VocabWord(word: 'the afternoon', translation: 'the part after midday'),
    VocabWord(word: 'the evening', translation: 'the end of the day'),
    VocabWord(word: 'the week', translation: 'seven days'),
    VocabWord(word: 'the month', translation: 'about thirty days'),
    VocabWord(word: 'the year', translation: 'twelve months'),

    // ---------------- Body ----------------
    VocabWord(word: 'the head', translation: 'the top part of your body'),
    VocabWord(word: 'the hand', translation: 'the part with fingers'),
    VocabWord(word: 'the foot', translation: 'what you stand on'),
    VocabWord(word: 'the arm', translation: 'between shoulder and hand'),
    VocabWord(word: 'the leg', translation: 'between hip and foot'),
    VocabWord(word: 'the eyes', translation: 'what you see with'),
    VocabWord(word: 'the mouth', translation: 'what you speak and eat with'),
    VocabWord(word: 'the nose', translation: 'what you smell with'),
    VocabWord(word: 'the ear', translation: 'what you hear with'),
    VocabWord(word: 'the back', translation: 'the rear of your body'),
    VocabWord(word: 'the heart', translation: 'the organ pumping blood'),
    VocabWord(word: 'the hair', translation: 'what grows on your head'),

    // ---------------- House ----------------
    VocabWord(word: 'the house', translation: 'a building people live in'),
    VocabWord(word: 'the bedroom', translation: 'the room where you sleep'),
    VocabWord(word: 'the kitchen', translation: 'the room where you cook'),
    VocabWord(word: 'the bathroom', translation: 'the room with a shower'),
    VocabWord(word: 'the living room', translation: 'the room where you relax'),
    VocabWord(word: 'the door', translation: 'what you open to enter'),
    VocabWord(word: 'the window', translation: 'the glass opening in a wall'),
    VocabWord(word: 'the table', translation: 'a flat surface on legs'),
    VocabWord(word: 'the chair', translation: 'a seat for one person'),
    VocabWord(word: 'the bed', translation: 'furniture for sleeping'),
    VocabWord(word: 'the sofa', translation: 'a long soft seat'),
    VocabWord(word: 'the garden', translation: 'the green area by a house'),
    VocabWord(word: 'the stairs', translation: 'steps between floors'),

    // ---------------- Food & drink ----------------
    VocabWord(word: 'the bread', translation: 'baked food made from flour'),
    VocabWord(word: 'the butter', translation: 'a yellow fat for bread'),
    VocabWord(word: 'the egg', translation: 'oval food from a hen'),
    VocabWord(word: 'the apple', translation: 'a round red or green fruit'),
    VocabWord(word: 'the banana', translation: 'a long yellow fruit'),
    VocabWord(word: 'the tomato', translation: 'a red salad vegetable'),
    VocabWord(word: 'the potato', translation: 'a starchy root vegetable'),
    VocabWord(word: 'the rice', translation: 'small white grains'),
    VocabWord(word: 'the pasta', translation: 'Italian food like spaghetti'),
    VocabWord(word: 'the chicken', translation: 'meat from a hen'),
    VocabWord(word: 'the salt', translation: 'white grains that add flavour'),
    VocabWord(word: 'the water', translation: 'the clear drink you need daily'),
    VocabWord(word: 'the juice', translation: 'a drink made from fruit'),
    VocabWord(word: 'the wine', translation: 'an alcoholic drink from grapes'),
    VocabWord(word: 'the chocolate', translation: 'a sweet made from cocoa'),

    // ---------------- Common verbs ----------------
    VocabWord(word: 'to be', translation: 'to exist or to have a quality'),
    VocabWord(word: 'to have', translation: 'to own or hold'),
    VocabWord(word: 'to do', translation: 'to perform an action'),
    VocabWord(word: 'to go', translation: 'to move somewhere'),
    VocabWord(word: 'to come', translation: 'to move here'),
    VocabWord(word: 'to want', translation: 'to wish for something'),
    VocabWord(word: 'to need', translation: 'to require something'),
    VocabWord(word: 'to know', translation: 'to have information'),
    VocabWord(word: 'to say', translation: 'to speak words'),
    VocabWord(word: 'to see', translation: 'to notice with your eyes'),
    VocabWord(word: 'to hear', translation: 'to notice with your ears'),
    VocabWord(word: 'to speak', translation: 'to use your voice'),
    VocabWord(word: 'to listen', translation: 'to pay attention to sound'),
    VocabWord(word: 'to read', translation: 'to look at words and understand'),
    VocabWord(word: 'to write', translation: 'to put words on paper'),
    VocabWord(word: 'to eat', translation: 'to take food into your body'),
    VocabWord(word: 'to drink', translation: 'to take liquid into your body'),
    VocabWord(word: 'to sleep', translation: 'to rest with your eyes closed'),
    VocabWord(word: 'to work', translation: 'to do a job'),
    VocabWord(word: 'to buy', translation: 'to get something for money'),
    VocabWord(word: 'to sell', translation: 'to give something for money'),
    VocabWord(word: 'to wait', translation: 'to stay until something happens'),
    VocabWord(word: 'to find', translation: 'to discover where something is'),
    VocabWord(word: 'to open', translation: 'to make something not closed'),
    VocabWord(word: 'to close', translation: 'to shut something'),
    VocabWord(word: 'to start', translation: 'to begin'),
    VocabWord(word: 'to finish', translation: 'to bring to an end'),
    VocabWord(word: 'to learn', translation: 'to gain knowledge'),
    VocabWord(word: 'to understand', translation: 'to get the meaning'),
    VocabWord(
      word: 'to help',
      translation: 'to make things easier for someone',
    ),
    VocabWord(word: 'to forget', translation: 'to fail to remember'),
    VocabWord(word: 'to remember', translation: 'to keep in mind'),

    // ---------------- Adjectives ----------------
    VocabWord(word: 'big', translation: 'large in size'),
    VocabWord(word: 'small', translation: 'little in size'),
    VocabWord(word: 'new', translation: 'recently made'),
    VocabWord(word: 'old', translation: 'from long ago'),
    VocabWord(word: 'young', translation: 'not old'),
    VocabWord(word: 'beautiful', translation: 'very pleasant to look at'),
    VocabWord(word: 'easy', translation: 'not difficult'),
    VocabWord(word: 'difficult', translation: 'hard to do'),
    VocabWord(word: 'fast', translation: 'moving quickly'),
    VocabWord(word: 'slow', translation: 'not fast'),
    VocabWord(word: 'strong', translation: 'having power'),
    VocabWord(word: 'happy', translation: 'feeling good'),
    VocabWord(word: 'sad', translation: 'feeling unhappy'),
    VocabWord(word: 'tired', translation: 'needing rest'),
    VocabWord(word: 'sick', translation: 'not healthy'),
    VocabWord(word: 'clean', translation: 'without dirt'),
    VocabWord(word: 'dirty', translation: 'not clean'),
    VocabWord(word: 'busy', translation: 'having a lot to do'),

    // ---------------- People ----------------
    VocabWord(word: 'the uncle', translation: 'your parent\'s brother'),
    VocabWord(word: 'the aunt', translation: 'your parent\'s sister'),
    VocabWord(
      word: 'the cousin',
      translation: 'your uncle\'s or aunt\'s child',
    ),
    VocabWord(word: 'the husband', translation: 'a married man'),
    VocabWord(word: 'the wife', translation: 'a married woman'),
    VocabWord(word: 'the baby', translation: 'a very young child'),
    VocabWord(word: 'the child', translation: 'a young person'),
    VocabWord(word: 'the man', translation: 'an adult male'),
    VocabWord(word: 'the woman', translation: 'an adult female'),
    VocabWord(word: 'the teacher', translation: 'a person who teaches'),
    VocabWord(word: 'the student', translation: 'a person who studies'),

    // ---------------- Prepositions & positions ----------------
    VocabWord(word: 'in', translation: 'inside something'),
    VocabWord(word: 'with', translation: 'together with'),
    VocabWord(word: 'without', translation: 'not having'),
    VocabWord(word: 'on', translation: 'on top of a surface'),
    VocabWord(word: 'under', translation: 'below something'),
    VocabWord(word: 'in front of', translation: 'before something'),
    VocabWord(word: 'behind', translation: 'at the back of'),
    VocabWord(word: 'between', translation: 'in the middle of two things'),
    VocabWord(word: 'next to', translation: 'at the side of'),
    VocabWord(word: 'inside', translation: 'within'),
    VocabWord(word: 'outside', translation: 'not inside'),
    VocabWord(word: 'towards', translation: 'in the direction of'),
    VocabWord(word: 'until', translation: 'up to a moment in time'),
    VocabWord(word: 'during', translation: 'in the course of'),
    VocabWord(word: 'against', translation: 'opposed to'),
  ],
);
