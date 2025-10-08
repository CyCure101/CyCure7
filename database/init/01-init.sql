USE cycure_quiz;

CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS quizzes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    module_type ENUM('Customer Service', 'IT-Security', 'General') NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    total_questions INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS questions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    quiz_id INT NOT NULL,
    question_text TEXT NOT NULL,
    question_type ENUM('multiple_choice') DEFAULT 'multiple_choice',
    FOREIGN KEY (quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS answers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    question_id INT NOT NULL,
    answer_text TEXT NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    answer_order INT NOT NULL CHECK (answer_order BETWEEN 1 AND 4),
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS user_attempts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    quiz_id INT NOT NULL,
    score INT DEFAULT 0,
    total_questions INT DEFAULT 0,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS user_responses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    attempt_id INT NOT NULL,
    question_id INT NOT NULL,
    selected_answer_id INT NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (attempt_id) REFERENCES user_attempts(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    FOREIGN KEY (selected_answer_id) REFERENCES answers(id) ON DELETE CASCADE
);

INSERT INTO quizzes (module_type, title, description, total_questions) VALUES
('Customer Service', 'Basic Customer Service Quiz', 'Test your customer service knowledge', 5),
('IT-Security', 'Cybersecurity Fundamentals', 'Basic cybersecurity concepts and best practices', 5),
('General', 'General Security Awareness', 'General security awareness questions', 5);

INSERT INTO questions (quiz_id, question_text) VALUES
(1, 'What is the most important aspect of customer service?'),
(1, 'How should you handle an angry customer?'),
(1, 'What is active listening in customer service?'),
(1, 'When should you escalate a customer complaint?'),
(1, 'What is the golden rule of customer service?');

INSERT INTO answers (question_id, answer_text, is_correct, answer_order) VALUES
(1, 'Being polite and respectful', TRUE, 1),
(1, 'Selling more products', FALSE, 2),
(1, 'Getting the job done quickly', FALSE, 3),
(1, 'Following company policies', FALSE, 4),
(2, 'Listen actively and empathize', TRUE, 1),
(2, 'Argue with the customer', FALSE, 2),
(2, 'Ignore their complaints', FALSE, 3),
(2, 'Transfer them immediately', FALSE, 4),
(3, 'Listening to understand, not just to respond', TRUE, 1),
(3, 'Speaking loudly and clearly', FALSE, 2),
(3, 'Taking detailed notes', FALSE, 3),
(3, 'Asking many questions', FALSE, 4),
(4, 'When you cannot resolve the issue yourself', TRUE, 1),
(4, 'Always escalate immediately', FALSE, 2),
(4, 'Never escalate', FALSE, 3),
(4, 'Only for VIP customers', FALSE, 4),
(5, 'Treat customers as you would like to be treated', TRUE, 1),
(5, 'The customer is always right', FALSE, 2),
(5, 'Follow company policies strictly', FALSE, 3),
(5, 'Maximize company profits', FALSE, 4);

UPDATE quizzes SET total_questions = 5 WHERE id = 1;
