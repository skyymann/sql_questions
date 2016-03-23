require 'byebug'
require_relative 'questions_database'

class Question
  include Enumerable

  # debugger
  def self.all
    QuestionsDatabase.instance.execute('SELECT * FROM questions')
    data.map { | datum | Question.new(datum)}
  end

  attr_accessor :id, :title, :body, :author_id
  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end


  def self.find_by_id(target_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, target_id)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.id = ? ;
    SQL

    result.map { |result| Question.new(result) }
  end

  def self.find_by_author_id(target_author_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, target_author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.author_id = ? ;
    SQL

    result.map { |result| Question.new(result) }
  end

  def self.find_by_keyword_in_body(target_keyword)
    target_keyword = "%#{target_keyword}%"
    result = QuestionsDatabase.instance.execute(<<-SQL, target_keyword)
      SELECT
        *
      FROM
        questions
      WHERE
        body LIKE ?
    SQL

    result.map { |result| Question.new(result) }
  end

  def self.find_by_title(target_title)
    target_title = "%#{target_title}%"
    result = QuestionsDatabase.instance.execute(<<-SQL, target_title)
      SELECT
        *
      FROM
        questions
      WHERE
        title LIKE ?
    SQL

    result.map { |result| Question.new(result) }
  end

  def author
    result = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        users.id, users.fname, users.lname
      FROM
        questions
        JOIN users
        ON questions.author_id = users.id
      WHERE
        questions.id = @id
    SQL

    result.map { |result| User.new(result) }
  end

  def replies
    Reply.find_by_user_id(@author_id)
  end

  def followers
    Question.followers_for_question_id(@id)
  end

  def save
    if @id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @author_id)

      INSERT INTO
        questions(title, body, author_id)
      VALUES
        (?, ?, ?)

      SQL

      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @author_id)

      UPDATE
        questions
      SET
        (title = :title, body = :body, author_id = :author_id)
      WHERE
        id = :id

      SQL
    end
  end

end
