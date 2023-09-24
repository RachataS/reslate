class Question {
  var id, question, answer, options;

  var questionList;

  Question(
      {this.id, this.question, this.answer, this.options, this.questionList});
}

Question question = Question();

List sample_data = question.questionList ??
    [
      {
        "id": 1,
        "question": "apple",
        "options": ['แอปเปิ้ล', 'พระเจ้า', 'มะม่วง', 'แมว'],
        "answer_index": 0,
      },
      {
        "id": 2,
        "question": "god",
        "options": ['แมว', 'พระเจ้า', 'คน', 'เชื่อมต่อ'],
        "answer_index": 1
      },
      {
        "id": 3,
        "question": "connect",
        "options": ['ผู้ชาย', 'หมา', 'เครื่องใช้ไฟฟ้า', 'เชื่อมต่อ'],
        "answer_index": 4,
      },
      {
        "id": 4,
        "question": "jar",
        "options": ['ไห', 'แก้ว', 'แว่น', 'แป้นพิมพ์'],
        "answer_index": 0,
      },
    ];
