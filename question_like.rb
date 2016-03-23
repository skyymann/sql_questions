require_relative 'questions_database'

class QuestionLike
  include Enumerable

  def self.all
    QuestionsDatabase.instance.execute('SELECT * FROM question_likes')
    data.map { | datum | QuestionLike.new(datum)}
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
        question_like
      WHERE
        question_like.id = ? ;
    SQL

    result.map { |result| QuestionLike.new(result) }
  end

  def self.find_by_question_id(target_question_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, target_question_id)
      SELECT
        *
      FROM
        question_like
      WHERE
        question_like.question_id = ? ;
    SQL

    result.map { |result| QuestionLike.new(result) }
  end

  def self.find_by_user_id(target_user_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, target_user_id)
      SELECT
        *
      FROM
        question_like
      WHERE
        question_like.user_id = ? ;
    SQL

    result.map { |result| QuestionLike.new(result) }
  end

  def save
    if @id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, @question_id, @user_id)

      INSERT INTO
        question_likes(question_id, user_id)
      VALUES
        (?, ?)

      SQL

      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      QuestionsDatabase.instance.execute(<<-SQL, @question_id, @user_id))

      UPDATE
        question_likes
      SET
        (question_id = :question_id, user_id = :user_id)
      WHERE
        id = :id
      SQL
    end
  end

end
# CREATE TABLE question_likes (
#   id INTEGER PRIMARY KEY,
#   user_id INTEGER NOT NULL,
#   question_id INTEGER NOT NULL,
#
#   FOREIGN KEY (user_id) REFERENCES users(id),
#   FOREIGN KEY (question_id) REFERENCES question(id)
# );
