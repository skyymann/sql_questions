# CREATE TABLE question_follows (
#   id INTEGER PRIMARY KEY,
#   question_id INTEGER NOT NULL,
#   user_id INTEGER NOT NULL,
#
#   FOREIGN KEY(question_id) REFERENCES questions(id),
#   FOREIGN KEY(user_id) REFERENCES users(id)
# );
require_relative 'questions_database'

class QuestionFollow
  include Enumerable

  def self.all
    QuestionsDatabase.instance.execute('SELECT * FROM question_follows')
    data.map { | datum | QuestionFollow.new(datum)}
  end

  attr_accessor :id, :question_id, :user_id

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

  def self.find_by_id(target_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, target_id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        question_follows.id = ? ;
    SQL

    result.map { |result| QuestionFollow.new(result) }
  end

  def self.find_by_question_id(target_question_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, target_question_id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        question_follows.question_id = ? ;
    SQL

    result.map { |result| QuestionFollow.new(result) }
  end

  def self.find_by_user_id(target_user_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, target_user_id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        question_follows.user_id = ? ;
    SQL

    result.map { |result| QuestionFollow.new(result) }
  end

  def self.followers_for_question_id(question_id)
  result = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.id, users.fname, users.lname
      FROM
        question_follows
        JOIN users
        ON question_follows.user_id = users.id
      WHERE
        question_follows.user_id = ? ;
    SQL

    result.map { |result| User.new(result) }
  end


  def self.followed_questions_for_user_id(user_id)
  result = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.id, questions.title, questions.body, questions.author_id
      FROM
        question_follows
        JOIN questions
        ON question_follows.question_id= questions.id
      WHERE
        question_follows.user_id = ? ;
    SQL

    result.map { |result| Question.new(result) }
  end

  def self.most_followed_questions(n)
  result = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.id, questions.title, questions.body, questions.author_id
      FROM
        question_follows
        JOIN questions
        ON question_follows.question_id= questions.id
        JOIN users
        ON users.id = question_follows.user_id
      WHERE
        question_follows.user_id
      ORDER BY COUNT(question_follows) DESC
      LIMIT n;
    SQL
    result.map { |result| Question.new(result) }
  end

  def save
    if @id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, @question_id, @user_id)

      INSERT INTO
        question_follows(question_id, user_id)
      VALUES
        (?, ?)

      SQL

      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      QuestionsDatabase.instance.execute(<<-SQL, @question_id, @user_id))

      UPDATE
        question_follows
      SET
        (question_id = :question_id, user_id = :user_id)
      WHERE
        id = :id

      SQL
    end
  end

end
