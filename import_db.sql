-- DROP TABLE IF EXISTS users;
-- DROP TABLE IF EXISTS questions;
-- DROP TABLE IF EXISTS question_follows;
-- DROP TABLE IF EXISTS replies;
-- DROP TABLE IF EXISTS question_likes;


CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body VARCHAR(255) NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY(author_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY(question_id) REFERENCES questions(id),
  FOREIGN KEY(user_id) REFERENCES users(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  subject_question VARCHAR(255) NOT NULL,
  parent_reply VARCHAR(255) NOT NULL,
  user_id INTEGER NOT NULL,
  question_body VARCHAR(255) NOT NULL,

  FOREIGN KEY (subject_question) REFERENCES questions(title),
  FOREIGN KEY (parent_reply) REFERENCES replies(subject_question),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_body) REFERENCES questions(body)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES question(id)
);


INSERT INTO
  users(fname, lname)
VALUES
  ('Kellam', 'Bartley'),
  ('Emily', 'Westfall');

INSERT INTO
  questions(title, body, author_id)
VALUES
  ('Chicken question', 'Why did the chicken cross the road?', 1);

INSERT INTO
  question_follows(user_id, question_id)
VALUES
  (2, 1);

INSERT INTO
  question_likes(user_id, question_id)
VALUES
  (2, 1);

INSERT INTO
  replies(subject_question, parent_reply, user_id, question_body)
  VALUES
  ('Chicken question', 'Chicken question', 2, 'Why did the chicken cross the road?');

    --
    -- FOREIGN KEY (subject_question) REFERENCES questions(title),
    -- FOREIGN KEY (parent_reply) REFERENCES replies(subject_question),
    -- FOREIGN KEY (user_id) REFERENCES users(id),
    -- FOREIGN KEY (question_body) REFERENCES questions(body)
