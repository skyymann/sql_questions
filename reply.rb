#
# CREATE TABLE replies (
#   id INTEGER PRIMARY KEY,
#   subject_question VARCHAR(255) NOT NULL,
#   parent_reply VARCHAR(255) NOT NULL,
#   user_id INTEGER NOT NULL,
#   question_body VARCHAR(255) NOT NULL,


require_relative 'questions_database'

class Replies
  include Enumerable

  def self.all
    QuestionsDatabase.instance.execute('SELECT * FROM replies')
    data.map { | datum | Reply.new(datum)}
  end

  attr_accessor :id, :subject_question, :parent_reply, :author_id, :question_body

  def initialize(options)
    @id = options['id']
    @subject_question = options['subject_question']
    @parent_reply = options['parent_reply']
    @author_id = options['user_id']
    @question_body = options['question_body']
  end

  def self.find_by_id(target_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, target_id)
      SELECT
        *
      FROM
        reply
      WHERE
        reply.id = ? ;
    SQL

    result.map { |result| Reply.new(result) }
  end

  def self.find_by_subject_question(target_subject)
    target_subject = "%#{target_subject}%"
    result = QuestionsDatabase.instance.execute(<<-SQL, target_subject)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.subject_question LIKE ? ;
    SQL

    result.map { |result| Reply.new(result) }
  end

  def self.find_by_parent_reply(target_parent_reply)
    target_parent_reply = "%#{target_parent_reply}%"
    result = QuestionsDatabase.instance.execute(<<-SQL, target_parent_reply)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.parent_reply = ? ;
    SQL

    result.map { |result| Reply.new(result) }
  end

  def self.find_by_author_id(target_author_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, target_author_id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.author_id = ? ;
    SQL

    result.map { |result| Reply.new(result) }
  end

  def self.find_by_question_body(target_question_body)
    target_question_body = "%#{target_question_body}%"
    result = QuestionsDatabase.instance.execute(<<-SQL, target_question_body)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.question_body = ? ;
    SQL

    result.map { |result| Reply.new(result) }
  end

  def author
    result = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        users.id, users.fname, users.lname
      FROM
        replies
        JOIN users
        ON replies.author_id = users.id
      WHERE
        replies.id = @id
    SQL

    result.map { |result| User.new(result) }
  end

  def question
    result = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        questions.id, questions.title, questions.body, questions.author_id
      FROM
        replies
        JOIN questions
        ON replies.question_body = questions.question_body
      WHERE
        replies.question_body = @question_body;
    SQL

    result.map { |result| Reply.new(result) }
  end

  def child_replies
    Reply.find_by_parent_reply(self.id)
  end

  def save
    if @id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, @subject_question, @parent_reply, @author_id, @question_body)

      INSERT INTO
        replies(subject_question, parent_reply, author_id, question_body)
      VALUES
        (?, ?, ?, ?)

      SQL

      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      QuestionsDatabase.instance.execute(<<-SQL, @subject_question, @parent_reply, @author_id, @question_body)

      UPDATE
        replies
      SET
        (subject_question = :subject_question, parent_reply = :parent_reply,
           author_id = :author_id, question_body = :question_body)
      WHERE
        id = :id

      SQL
    end
  end


end

# @subject_question = options['subject_question']
# @parent_reply = options['parent_reply']
# @author_id = options['user_id']
# @question_body = options['question_body']
