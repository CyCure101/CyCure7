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

-- Add 5 more Customer Service questions (quiz_id = 1)
INSERT INTO questions (quiz_id, question_text) VALUES
(1, 'What is the best way to handle a customer complaint about a product defect?'),
(1, 'How should you respond when a customer asks for a refund?'),
(1, 'What is the most important factor in building customer loyalty?'),
(1, 'What should you do when a customer is speaking loudly and causing a scene?'),
(1, 'How do you handle a customer who is asking for something outside of company policy?');

-- Add answers for the new Customer Service questions
INSERT INTO answers (question_id, answer_text, is_correct, answer_order) VALUES
-- Question 6: Product defect complaint (question_id = 6)
(6, 'Apologize sincerely, document the issue, and offer a solution', TRUE, 1),
(6, 'Blame the customer for not reading instructions', FALSE, 2),
(6, 'Ignore the complaint and hope it goes away', FALSE, 3),
(6, 'Transfer them to another department immediately', FALSE, 4),

-- Question 7: Refund request (question_id = 7)
(7, 'Listen to their reason, check policy, and process if appropriate', TRUE, 1),
(7, 'Always say no to refunds', FALSE, 2),
(7, 'Give refunds to everyone without questions', FALSE, 3),
(7, 'Make them wait for a manager', FALSE, 4),

-- Question 8: Customer loyalty (question_id = 8)
(8, 'Consistent quality service and genuine care for their needs', TRUE, 1),
(8, 'Offering the lowest prices', FALSE, 2),
(8, 'Having the most products available', FALSE, 3),
(8, 'Being the fastest service', FALSE, 4),

-- Question 9: Loud customer scene (question_id = 9)
(9, 'Remain calm, speak softly, and try to move to a private area', TRUE, 1),
(9, 'Speak louder to match their volume', FALSE, 2),
(9, 'Ignore them until they calm down', FALSE, 3),
(9, 'Call security immediately', FALSE, 4),

-- Question 10: Outside policy request (question_id = 10)
(10, 'Explain the policy clearly and offer alternative solutions', TRUE, 1),
(10, 'Always say yes to keep the customer happy', FALSE, 2),
(10, 'Refuse without explanation', FALSE, 3),
(10, 'Transfer them to a manager immediately', FALSE, 4);

UPDATE quizzes SET total_questions = 10 WHERE id = 1;

-- Add IT-Security quiz questions (quiz_id = 2)
INSERT INTO questions (quiz_id, question_text) VALUES
(2, 'What is the primary purpose of a firewall in network security?'),
(2, 'Which of the following is considered the strongest password?'),
(2, 'What does "phishing" refer to in cybersecurity?'),
(2, 'What is two-factor authentication (2FA)?'),
(2, 'What should you do if you receive a suspicious email with an attachment?'),
(2, 'What is the purpose of encryption in data security?'),
(2, 'Which of the following is a common sign of malware infection?'),
(2, 'What is a VPN and why is it important for security?'),
(2, 'What does "social engineering" mean in cybersecurity?'),
(2, 'What is the best practice for handling sensitive data?'),
(2, 'What is the difference between a virus and a worm?'),
(2, 'What does HTTPS stand for and why is it important?'),
(2, 'What is the purpose of a security patch or update?'),
(2, 'What is the principle of least privilege in cybersecurity?'),
(2, 'What should you do if you suspect your computer has been compromised?');

-- Add IT-Security quiz answers
INSERT INTO answers (question_id, answer_text, is_correct, answer_order) VALUES
-- Question 1: Firewall purpose (question_id = 11)
(11, 'To monitor and control incoming and outgoing network traffic', TRUE, 1),
(11, 'To store user passwords securely', FALSE, 2),
(11, 'To encrypt all data transmissions', FALSE, 3),
(11, 'To backup important files automatically', FALSE, 4),

-- Question 2: Strongest password (question_id = 12)
(12, 'MyP@ssw0rd!2024', TRUE, 1),
(12, 'password123', FALSE, 2),
(12, '12345678', FALSE, 3),
(12, 'qwerty', FALSE, 4),

-- Question 3: Phishing definition (question_id = 13)
(13, 'A cyber attack that uses deceptive emails or websites to steal sensitive information', TRUE, 1),
(13, 'A type of computer virus', FALSE, 2),
(13, 'A method of encrypting data', FALSE, 3),
(13, 'A network security protocol', FALSE, 4),

-- Question 4: Two-factor authentication (question_id = 14)
(14, 'A security method that requires two different forms of verification', TRUE, 1),
(14, 'Using two different passwords', FALSE, 2),
(14, 'Logging in from two different devices', FALSE, 3),
(14, 'Having two user accounts', FALSE, 4),

-- Question 5: Suspicious email handling (question_id = 15)
(15, 'Delete the email without opening the attachment', TRUE, 1),
(15, 'Open the attachment to see what it contains', FALSE, 2),
(15, 'Forward it to colleagues to warn them', FALSE, 3),
(15, 'Reply to the sender asking for clarification', FALSE, 4),

-- Question 6: Encryption purpose (question_id = 16)
(16, 'To convert data into a coded form that can only be read with a key', TRUE, 1),
(16, 'To compress files to save storage space', FALSE, 2),
(16, 'To organize files in folders', FALSE, 3),
(16, 'To backup data automatically', FALSE, 4),

-- Question 7: Malware infection signs (question_id = 17)
(17, 'Slow computer performance and unexpected pop-ups', TRUE, 1),
(17, 'Faster internet connection', FALSE, 2),
(17, 'More available storage space', FALSE, 3),
(17, 'Better screen resolution', FALSE, 4),

-- Question 8: VPN purpose (question_id = 18)
(18, 'A secure connection that encrypts internet traffic and hides your location', TRUE, 1),
(18, 'A type of antivirus software', FALSE, 2),
(18, 'A method to increase internet speed', FALSE, 3),
(18, 'A tool to organize files', FALSE, 4),

-- Question 9: Social engineering (question_id = 19)
(19, 'Manipulating people to reveal confidential information', TRUE, 1),
(19, 'A type of computer programming', FALSE, 2),
(19, 'A method of data encryption', FALSE, 3),
(19, 'A network security protocol', FALSE, 4),

-- Question 10: Handling sensitive data (question_id = 20)
(20, 'Encrypt it, limit access, and follow data protection policies', TRUE, 1),
(20, 'Store it in a shared folder for easy access', FALSE, 2),
(20, 'Email it to yourself for backup', FALSE, 3),
(20, 'Print it out and keep physical copies', FALSE, 4),

-- Question 11: Virus vs Worm (question_id = 21)
(21, 'A virus needs a host file to spread, while a worm can spread independently', TRUE, 1),
(21, 'A virus is more dangerous than a worm', FALSE, 2),
(21, 'A worm needs a host file to spread, while a virus can spread independently', FALSE, 3),
(21, 'There is no difference between them', FALSE, 4),

-- Question 12: HTTPS (question_id = 22)
(22, 'HyperText Transfer Protocol Secure - encrypts data between browser and server', TRUE, 1),
(22, 'HyperText Transfer Protocol Standard - faster than HTTP', FALSE, 2),
(22, 'HyperText Transfer Protocol Simple - easier to use than HTTP', FALSE, 3),
(22, 'HyperText Transfer Protocol Safe - prevents all cyber attacks', FALSE, 4),

-- Question 13: Security patches (question_id = 23)
(23, 'To fix vulnerabilities and security flaws in software', TRUE, 1),
(23, 'To add new features to software', FALSE, 2),
(23, 'To make software run faster', FALSE, 3),
(23, 'To change the software interface', FALSE, 4),

-- Question 14: Principle of least privilege (question_id = 24)
(24, 'Users should only have the minimum access rights necessary to perform their job', TRUE, 1),
(24, 'Users should have access to all systems for convenience', FALSE, 2),
(24, 'Only administrators should have access to systems', FALSE, 3),
(24, 'Users should share passwords for better collaboration', FALSE, 4),

-- Question 15: Computer compromise response (question_id = 25)
(25, 'Disconnect from internet, run antivirus scan, change passwords, notify IT', TRUE, 1),
(25, 'Continue using the computer normally', FALSE, 2),
(25, 'Restart the computer and hope it fixes itself', FALSE, 3),
(25, 'Delete all files to remove the threat', FALSE, 4);

-- Update IT-Security quiz total questions count
UPDATE quizzes SET total_questions = 15 WHERE id = 2;