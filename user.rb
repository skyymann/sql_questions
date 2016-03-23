require_relative 'questions_database'

class User
include Enumerable

  def self.all
    QuestionsDatabase.instance.execute('SELECT * FROM users')
    data.map { | datum | User.new(datum)}
  end


  attr_accessor :id, :fname, :lname

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end


  def self.find_by_id(target_id)
    result = QuestionsDatabase.instance.execute(<<-SQL, target_id)
      SELECT
        *
      FROM
        users
      WHERE
        users.id = ? ;
    SQL

    result.map { |result| User.new(result) }
  end

  def self.find_by_name(target_fname, target_lname) #TODO: accept first, last, or both
    result = QuestionsDatabase.instance.execute(<<-SQL, target_fname, target_lname)
      SELECT
        *
      FROM
        users
      WHERE
        users.fname = ? AND users.lname = ? ;
    SQL

    result.map { |result| User.new(result) }
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_author_id(@id)
  end

  def followed_questions
    Question.followed_questions_for_user_id(@id)
  end

  def save
    if @id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)

      INSERT INTO
        users(fname, lname)
      VALUES
        (?, ?)

      SQL

      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)

      UPDATE
        users
      SET
        (fname = :fname, lname = :lname)
      WHERE
        id = :id

      SQL
    end
  end

end
