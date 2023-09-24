class Question {
  var id, question, answer, options;

  var questionList;

  Question(
      {this.id, this.question, this.answer, this.options, this.questionList});
}

Question question = Question();

List sample_data = question.questionList ?? [];
