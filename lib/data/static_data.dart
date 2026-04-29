class StaticData {
  static const List<Map<String, dynamic>> vocabulary = [
    {
      "word_id": 1,
      "word": "apple",
      "translation": "manzana",
      "language_code": "es",
      "part_of_speech": "noun",
      "difficulty_level": 1,
      "category": "food",
      "example_sentence": "I eat an apple",
    },
    {
      "word_id": 2,
      "word": "water",
      "translation": "agua",
      "language_code": "es",
      "part_of_speech": "noun",
      "difficulty_level": 1,
      "category": "food",
      "example_sentence": "I drink water",
    },
    {
      "word_id": 3,
      "word": "run",
      "translation": "correr",
      "language_code": "es",
      "part_of_speech": "verb",
      "difficulty_level": 1,
      "category": "action",
      "example_sentence": "I want to run",
    },
    {
      "word_id": 4,
      "word": "book",
      "translation": "libro",
      "language_code": "es",
      "part_of_speech": "noun",
      "difficulty_level": 1,
      "category": "education",
      "example_sentence": "I read a book",
    },
    {
      "word_id": 5,
      "word": "fast",
      "translation": "rápido",
      "language_code": "es",
      "part_of_speech": "adjective",
      "difficulty_level": 2,
      "category": "description",
      "example_sentence": "The car is fast",
    },
  ];

  static const List<Map<String, dynamic>> grammarRules = [
    {
      "rule_id": 1,
      "rule_name": "Present Tense",
      "pattern_template": "Subject + Verb(base)",
      "difficulty_level": 1,
    },
    {
      "rule_id": 2,
      "rule_name": "Adjective Placement",
      "pattern_template": "Noun + Adjective",
      "difficulty_level": 2,
    },
  ];

  static const List<Map<String, dynamic>> sentenceTemplates = [
    {
      "template_id": 1,
      "rule_id": 1,
      "template_text": "I eat an ___",
      "slot_count": 1,
      "answer": "apple",
    },
    {
      "template_id": 2,
      "rule_id": 1,
      "template_text": "I drink ___",
      "slot_count": 1,
      "answer": "water",
    },
    {
      "template_id": 3,
      "rule_id": 1,
      "template_text": "I read a ___",
      "slot_count": 1,
      "answer": "book",
    },
  ];

  // For translation matches
  static const List<Map<String, dynamic>> translations = [
    {
      "template_id": 1,
      "english": "I eat an apple",
      "spanish": "Yo como una manzana",
    },
    {"template_id": 2, "english": "I drink water", "spanish": "Yo bebo agua"},
    {
      "template_id": 3,
      "english": "I read a book",
      "spanish": "Yo leo un libro",
    },
  ];
  // Learning Section Data for LessonScreen mapping
  static const List<Map<String, String>> wordsLesson = [
    {"english": "Apple", "spanish": "Manzana"},
    {"english": "Water", "spanish": "Agua"},
    {"english": "Book", "spanish": "Libro"},
    {"english": "House", "spanish": "Casa"},
    {"english": "Car", "spanish": "Coche"},
    {"english": "Hello", "spanish": "Hola"},
    {"english": "My", "spanish": "Mi"},
    {"english": "Name", "spanish": "Nombre"},
    {"english": "Is", "spanish": "Es"},
    {"english": "Nice", "spanish": "Encantado"},
    {"english": "Meet", "spanish": "Conocer"},
    {"english": "You", "spanish": "Tú"},
    {"english": "Where", "spanish": "Dónde"},
    {"english": "From", "spanish": "De"},
    {"english": "I", "spanish": "Yo"},
    {"english": "Am", "spanish": "Soy/Estoy"},
    {"english": "Spain", "spanish": "España"},
    {"english": "Good", "spanish": "Buenos"},
    {"english": "Morning", "spanish": "Días"},
    {"english": "How", "spanish": "Cómo"},
    {"english": "Are", "spanish": "Estás"},
    {"english": "Eat", "spanish": "Como"},
    {"english": "Want", "spanish": "Quiero"},
    {"english": "She", "spanish": "Ella"},
    {"english": "Reads", "spanish": "Lee"},
    {"english": "Fast", "spanish": "Rápido"},
    {"english": "He", "spanish": "Él"},
    {"english": "Has", "spanish": "Tiene"},
    {"english": "Dog", "spanish": "Perro"},
    {"english": "We", "spanish": "Nosotros"},
    {"english": "Happy", "spanish": "Felices"},
    {"english": "The", "spanish": "El/La"},
    {"english": "Yesterday", "spanish": "Ayer"},
    {"english": "Went", "spanish": "Fui"},
    {"english": "Store", "spanish": "Tienda"},
    {"english": "Buy", "spanish": "Comprar"},
    {"english": "Fresh", "spanish": "Frescos"},
    {"english": "Groceries", "spanish": "Alimentos"},
    {"english": "Dinner", "spanish": "Cena"},
    {"english": "If", "spanish": "Si"},
    {"english": "Study", "spanish": "Estudias"},
    {"english": "Hard", "spanish": "Mucho"},
    {"english": "Every", "spanish": "Todos"},
    {"english": "Day", "spanish": "Días"},
    {"english": "Learn", "spanish": "Aprenderás/Aprender"},
    {"english": "Rules", "spanish": "Reglas"},
    {"english": "Language", "spanish": "Idioma"},
    {"english": "Love", "spanish": "Encantaría"},
    {"english": "Travel", "spanish": "Viajar"},
    {"english": "Next", "spanish": "Viene"},
    {"english": "Year", "spanish": "Año"},
    {"english": "See", "spanish": "Ver"},
    {"english": "Beautiful", "spanish": "Hermosa"},
    {"english": "Architecture", "spanish": "Arquitectura"},
    {"english": "Weather", "spanish": "Clima"},
    {"english": "Very", "spanish": "Muy"},
    {"english": "Nice", "spanish": "Agradable"},
    {"english": "Today", "spanish": "Hoy"},
    {"english": "Should", "spanish": "Deberíamos"},
    {"english": "Go", "spanish": "Ir"},
    {"english": "Park", "spanish": "Parque"},
    {"english": "More", "spanish": "Más"},
    {"english": "Words", "spanish": "Palabras"},
    {"english": "Because", "spanish": "Porque"},
    {"english": "Fun", "spanish": "Divertidos"},
  ];

  static const List<Map<String, String>> introLesson = [
    {
      "english": "Hello, my name is Alex.",
      "spanish": "Hola, mi nombre es Alex.",
    },
    {"english": "Nice to meet you.", "spanish": "Encantado de conocerte."},
    {"english": "Where are you from?", "spanish": "¿De dónde eres?"},
    {"english": "I am from Spain.", "spanish": "Soy de España."},
    {"english": "Good morning.", "spanish": "Buenos días."},
    {"english": "How are you?", "spanish": "¿Cómo estás?"},
  ];

  static const List<Map<String, String>> smallSentencesLesson = [
    {"english": "I eat an apple.", "spanish": "Yo como una manzana."},
    {"english": "I want water.", "spanish": "Yo quiero agua."},
    {"english": "She reads a book.", "spanish": "Ella lee un libro."},
    {"english": "The car is fast.", "spanish": "El coche es rápido."},
    {"english": "He has a dog.", "spanish": "Él tiene un perro."},
    {"english": "We are happy.", "spanish": "Nosotros estamos felices."},
  ];

  static const List<Map<String, String>> largeSentencesLesson = [
    {
      "english":
          "Yesterday, I went to the store to buy some fresh groceries for dinner.",
      "spanish":
          "Ayer fui a la tienda a comprar alimentos frescos para la cena.",
    },
    {
      "english":
          "If you study hard every single day, you will learn the rules of the language.",
      "spanish":
          "Si estudias mucho todos los días, aprenderás las reglas del idioma.",
    },
    {
      "english":
          "I would love to travel to Madrid next year and see the beautiful architecture.",
      "spanish":
          "Me encantaría viajar a Madrid el año que viene y ver la hermosa arquitectura.",
    },
    {
      "english": "The weather is very nice today, we should go to the park.",
      "spanish": "El clima está muy agradable hoy, deberíamos ir al parque.",
    },
    {
      "english": "I want to learn more words because languages are fun.",
      "spanish":
          "Quiero aprender más palabras porque los idiomas son divertidos.",
    },
  ];
}
