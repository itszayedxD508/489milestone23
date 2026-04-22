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
}
