USE cycure_quiz;

    -- USERS TABLE
CREATE TABLE IF NOT EXISTS users
(
    id         INT PRIMARY KEY AUTO_INCREMENT,
    username   VARCHAR(50) UNIQUE  NOT NULL,
    email      VARCHAR(100) UNIQUE NOT NULL,
    password   VARCHAR(255)        NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

-- QUIZZES TABLE
CREATE TABLE IF NOT EXISTS quizzes
(
    id              INT PRIMARY KEY AUTO_INCREMENT,
    module_type     ENUM ('Customer Service', 'IT-Security', 'General') NOT NULL,
    title           VARCHAR(200)                                        NOT NULL,
    description     TEXT,
    total_questions INT       DEFAULT 0,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

-- QUESTIONS TABLE
CREATE TABLE IF NOT EXISTS questions
(
    id            INT PRIMARY KEY AUTO_INCREMENT,
    quiz_id       INT  NOT NULL,
    question_text TEXT NOT NULL,
    question_type ENUM ('multiple_choice') DEFAULT 'multiple_choice',
    FOREIGN KEY (quiz_id) REFERENCES quizzes (id) ON DELETE CASCADE
    );

-- ANSWERS TABLE
CREATE TABLE IF NOT EXISTS answers
(
    id           INT PRIMARY KEY AUTO_INCREMENT,
    question_id  INT  NOT NULL,
    answer_text  TEXT NOT NULL,
    is_correct   BOOLEAN DEFAULT FALSE,
    answer_order INT  NOT NULL CHECK (answer_order BETWEEN 1 AND 4),
    FOREIGN KEY (question_id) REFERENCES questions (id) ON DELETE CASCADE
    );

-- USER ATTEMPTS TABLE
CREATE TABLE IF NOT EXISTS user_attempts
(
    id              INT PRIMARY KEY AUTO_INCREMENT,
    user_id         INT NOT NULL,
    quiz_id         INT NOT NULL,
    score           INT       DEFAULT 0,
    total_questions INT       DEFAULT 0,
    completed_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (quiz_id) REFERENCES quizzes (id) ON DELETE CASCADE
    );

-- USER RESPONSES TABLE
CREATE TABLE IF NOT EXISTS user_responses
(
    id                 INT PRIMARY KEY AUTO_INCREMENT,
    attempt_id         INT NOT NULL,
    question_id        INT NOT NULL,
    selected_answer_id INT NOT NULL,
    is_correct         BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (attempt_id) REFERENCES user_attempts (id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions (id) ON DELETE CASCADE,
    FOREIGN KEY (selected_answer_id) REFERENCES answers (id) ON DELETE CASCADE
    );

-- QUIZZES
INSERT INTO quizzes (module_type, title, description, total_questions)
VALUES
    ('Customer Service', 'Basic Customer Service Quiz', 'Test your customer service knowledge', 15),
    ('IT-Security', 'Cybersecurity Fundamentals', 'Basic cybersecurity concepts and best practices', 15),
    ('General', 'General Security Awareness', 'General security awareness questions', 15);

-- QUESTIONS (ENGLISH)
INSERT INTO questions (quiz_id, question_text)
VALUES
    -- Customer Service (15)
    (1, 'What is important to consider when handling customers\' personal data?'),
    (1, 'Which of the following is an example of strong authentication?'),
    (1, 'How should you act if a customer asks you to share their password?'),
    (1, 'What is the main purpose of the GDPR?'),
    (1, 'How should you handle a suspicious phishing email from a customer?'),
    (1, 'What kind of information should you avoid writing in an open support ticket?'),
    (1, 'What does the term "Need to Know" mean?'),
    (1, 'How do you protect customer data in a shared workspace?'),
    (1, 'What should you do if you suspect a colleague is sharing customer data inappropriately?'),
    (1, 'What is an example of secure online customer interaction?'),
    (1, 'How do you handle customer ID verification securely?'),
    (1, 'What is best practice for closing a support ticket?'),
    (1, 'How can you prevent unauthorized access to the customer system?'),
    (1, 'Which is a sign of social engineering in customer contact?'),
    (1, 'Why is it important to log out from the customer system when finished?'),

    -- IT Security (15)
    (2, 'What is phishing?'),
    (2, 'Which type of malware encrypts your files and demands payment?'),
    (2, 'What is the purpose of a firewall?'),
    (2, 'Which of the following is an example of two-factor authentication?'),
    (2, 'How can you best protect your password?'),
    (2, 'What is a secure way to share files with colleagues?'),
    (2, 'What does a "man-in-the-middle" attack mean?'),
    (2, 'Which protocol is used for secure web traffic?'),
    (2, 'What is a VPN and why is it used?'),
    (2, 'How can you detect a malicious email?'),
    (2, 'What is a brute force attack?'),
    (2, 'What does the principle of least privilege mean?'),
    (2, 'What is ransomware?'),
    (2, 'Which tool can be used to detect intrusions in a network?'),
    (2, 'How often should software and operating systems be updated?'),

    -- General Security Awareness (15)
    (3, 'What is social engineering?'),
    (3, 'Which of the following is a secure password?'),
    (3, 'How can you protect yourself from malicious software?'),
    (3, 'What should you do if you find a USB stick at work?'),
    (3, 'What is a common sign of phishing online?'),
    (3, 'Why should you not use the same password for multiple accounts?'),
    (3, 'How can you protect your mobile device?'),
    (3, 'What is safe browsing behavior on public Wi-Fi networks?'),
    (3, 'How should you handle suspicious email attachments?'),
    (3, 'What is two-step verification?'),
    (3, 'What is best practice for deleting sensitive information?'),
    (3, 'What is important in company password management?'),
    (3, 'Which physical security measure is important in the office?'),
    (3, 'How can you recognize a secure website?'),
    (3, 'What is a sign of an insider threat in the company?');

    -- ANSWERS (ENGLISH)
    INSERT INTO answers (question_id, answer_text, is_correct, answer_order)
    VALUES
    -- Customer Service (1–15)
    (1, 'Share only when necessary and according to policy', TRUE, 1),
    (1, 'Save on your desktop for easy access', FALSE, 2),
    (1, 'Send via unencrypted email', FALSE, 3),
    (1, 'Store in personal notes', FALSE, 4),

    (2, 'Two-factor authentication (2FA)', TRUE, 1),
    (2, 'Username only', FALSE, 2),
    (2, 'Using your birthdate as password', FALSE, 3),
    (2, 'Shared account', FALSE, 4),

    (3, 'Inform the customer that passwords are confidential', TRUE, 1),
    (3, 'Store the password for them', FALSE, 2),
    (3, 'Send it via SMS', FALSE, 3),
    (3, 'Write it in the customer record', FALSE, 4),

    (4, 'Protect individuals\' personal data', TRUE, 1),
    (4, 'Ban advertisements', FALSE, 2),
    (4, 'Increase internal sales', FALSE, 3),
    (4, 'Regulate email communication', FALSE, 4),

    (5, 'Report to IT and do not reply', TRUE, 1),
    (5, 'Open the link to check it', FALSE, 2),
    (5, 'Forward to a colleague', FALSE, 3),
    (5, 'Reply with customer data', FALSE, 4),

    (6, 'Personal identification number', FALSE, 1),
    (6, 'Full credit card number', FALSE, 2),
    (6, 'Internal passwords', FALSE, 3),
    (6, 'All of the above', TRUE, 4),

    (7, 'Access is granted only to those who need it', TRUE, 1),
    (7, 'Everyone can view all data', FALSE, 2),
    (7, 'Sharing increases efficiency', FALSE, 3),
    (7, 'Users decide their own needs', FALSE, 4),

    (8, 'Lock your screen when leaving your desk', TRUE, 1),
    (8, 'Leave customer lists open', FALSE, 2),
    (8, 'Share your computer with others', FALSE, 3),
    (8, 'Use unencrypted USB drives', FALSE, 4),

    (9, 'Report according to internal policy', TRUE, 1),
    (9, 'Ignore the situation', FALSE, 2),
    (9, 'Discuss with the colleague directly', FALSE, 3),
    (9, 'Post it internally', FALSE, 4),

    (10, 'Use secure, verified chat systems', TRUE, 1),
    (10, 'Share customer data with third parties', FALSE, 2),
    (10, 'Use open forums', FALSE, 3),
    (10, 'Avoid ID verification', FALSE, 4),

    (11, 'Request multiple identifying details', TRUE, 1),
    (11, 'Accept only first name', FALSE, 2),
    (11, 'Skip verification', FALSE, 3),
    (11, 'Ask for their password', FALSE, 4),

    (12, 'Confirm resolution and thank the customer', TRUE, 1),
    (12, 'Close without informing the customer', FALSE, 2),
    (12, 'Ignore feedback', FALSE, 3),
    (12, 'Delete ticket history', FALSE, 4),

    (13, 'Use strong authentication', TRUE, 1),
    (13, 'Write passwords on paper', FALSE, 2),
    (13, 'Share accounts', FALSE, 3),
    (13, 'Use public networks', FALSE, 4),

    (14, 'The person pressures you to break policy', TRUE, 1),
    (14, 'Customer thanks you for help', FALSE, 2),
    (14, 'Asks about opening hours', FALSE, 3),
    (14, 'Normal troubleshooting questions', FALSE, 4),

    (15, 'To prevent unauthorized access', TRUE, 1),
    (15, 'To make the computer faster', FALSE, 2),
    (15, 'To save energy', FALSE, 3),
    (15, 'To close programs', FALSE, 4),

    -- IT Security (16–30)
    (16, 'Attempt to trick users into giving sensitive information', TRUE, 1),
    (16, 'A type of antivirus software', FALSE, 2),
    (16, 'A firewall setting', FALSE, 3),
    (16, 'A security certification', FALSE, 4),

    (17, 'Ransomware', TRUE, 1),
    (17, 'Trojan', FALSE, 2),
    (17, 'Adware', FALSE, 3),
    (17, 'Spyware', FALSE, 4),

    (18, 'Block unauthorized traffic and protect networks', TRUE, 1),
    (18, 'Improve hardware performance', FALSE, 2),
    (18, 'Encrypt emails', FALSE, 3),
    (18, 'Monitor user behavior', FALSE, 4),

    (19, 'Password + SMS code', TRUE, 1),
    (19, 'Password only', FALSE, 2),
    (19, 'Username', FALSE, 3),
    (19, 'Email address', FALSE, 4),

    (20, 'Use strong, unique passwords and a password manager', TRUE, 1),
    (20, 'Write passwords on sticky notes', FALSE, 2),
    (20, 'Share with colleagues', FALSE, 3),
    (20, 'Reuse passwords everywhere', FALSE, 4),

    (21, 'Use encryption and secure cloud services', TRUE, 1),
    (21, 'Send via regular email', FALSE, 2),
    (21, 'Upload to public forums', FALSE, 3),
    (21, 'Use USB without a password', FALSE, 4),

    (22, 'Intercepting communication between two parties', TRUE, 1),
    (22, 'Guessing passwords with a program', FALSE, 2),
    (22, 'Installing antivirus', FALSE, 3),
    (22, 'Sending spam emails', FALSE, 4),

    (23, 'HTTPS', TRUE, 1),
    (23, 'HTTP', FALSE, 2),
    (23, 'FTP', FALSE, 3),
    (23, 'SMTP', FALSE, 4),

    (24, 'Creates an encrypted tunnel for secure communication', TRUE, 1),
    (24, 'Blocks malware', FALSE, 2),
    (24, 'Keeps your computer fast', FALSE, 3),
    (24, 'Deletes cookies', FALSE, 4),

    (25, 'Check sender address, spelling errors, and links', TRUE, 1),
    (25, 'Open all attachments', FALSE, 2),
    (25, 'Click all links', FALSE, 3),
    (25, 'Reply with sensitive data', FALSE, 4),

    (26, 'Attempting to guess passwords by repeated tries', TRUE, 1),
    (26, 'Physically stealing the computer', FALSE, 2),
    (26, 'Sending phishing emails', FALSE, 3),
    (26, 'Using antivirus software', FALSE, 4),

    (27, 'Users get only the access they need', TRUE, 1),
    (27, 'Everyone gets full access', FALSE, 2),
    (27, 'Shared access reduces risk', FALSE, 3),
    (27, 'Users decide their own privileges', FALSE, 4),

    (28, 'Malicious software that encrypts files and demands ransom', TRUE, 1),
    (28, 'Firewall', FALSE, 2),
    (28, 'VPN', FALSE, 3),
    (28, 'Antivirus', FALSE, 4),

    (29, 'Intrusion Detection System (IDS)', TRUE, 1),
    (29, 'Word processor', FALSE, 2),
    (29, 'Firewall', FALSE, 3),
    (29, 'VPN', FALSE, 4),

    (30, 'As often as updates are available', TRUE, 1),
    (30, 'Never', FALSE, 2),
    (30, 'Only when problems occur', FALSE, 3),
    (30, 'Once a year', FALSE, 4),

    -- General (31–45)
    (31, 'Manipulating people to gain access to information', TRUE, 1),
    (31, 'An antivirus program', FALSE, 2),
    (31, 'A firewall rule', FALSE, 3),
    (31, 'Password reset', FALSE, 4),

    (32, 'Xy!9@Pq4#', TRUE, 1),
    (32, 'password123', FALSE, 2),
    (32, 'abc123', FALSE, 3),
    (32, '123456', FALSE, 4),

    (33, 'Install up-to-date antivirus and keep systems updated', TRUE, 1),
    (33, 'Click on all links', FALSE, 2),
    (33, 'Share computers with coworkers', FALSE, 3),
    (33, 'Ignore security warnings', FALSE, 4),

    (34, 'Hand it to IT for safe handling', TRUE, 1),
    (34, 'Plug it into your computer', FALSE, 2),
    (34, 'Take it home', FALSE, 3),
    (34, 'Give it to a coworker', FALSE, 4),

    (35, 'Typos, strange links, and unexpected attachments', TRUE, 1),
    (35, 'Known sender', FALSE, 2),
    (35, 'Professional language', FALSE, 3),
    (35, 'Email signature', FALSE, 4),

    (36, 'Prevents one hacked account from compromising others', TRUE, 1),
    (36, 'Makes passwords easier to remember', FALSE, 2),
    (36, 'Saves time', FALSE, 3),
    (36, 'Improves network speed', FALSE, 4),

    (37, 'Use PIN and biometrics, lock the phone', TRUE, 1),
    (37, 'Share your device', FALSE, 2),
    (37, 'Write down your code', FALSE, 3),
    (37, 'Disable your password', FALSE, 4),

    (38, 'Use VPN and avoid logging into sensitive accounts', TRUE, 1),
    (38, 'Use public Wi-Fi without protection', FALSE, 2),
    (38, 'Share passwords over Wi-Fi', FALSE, 3),
    (38, 'Use public computers', FALSE, 4),

    (39, 'Never open suspicious attachments, verify sender', TRUE, 1),
    (39, 'Open immediately', FALSE, 2),
    (39, 'Forward to everyone', FALSE, 3),
    (39, 'Save to desktop', FALSE, 4),

    (40, 'An extra security step beyond the password', TRUE, 1),
    (40, 'A type of virus', FALSE, 2),
    (40, 'Password only', FALSE, 3),
    (40, 'Secure email', FALSE, 4),

    (41, 'Physically destroy or securely erase via software', TRUE, 1),
    (41, 'Throw in the trash', FALSE, 2),
    (41, 'Leave on the desk', FALSE, 3),
    (41, 'Save to USB', FALSE, 4),

    (42, 'Use strong passwords, avoid reuse', TRUE, 1),
    (42, 'Everyone knows all passwords', FALSE, 2),
    (42, 'Write them on paper', FALSE, 3),
    (42, 'Use the same password for all accounts', FALSE, 4),

    (43, 'Lock doors and use access cards', TRUE, 1),
    (43, 'Keep doors open', FALSE, 2),
    (43, 'Share keys with everyone', FALSE, 3),
    (43, 'Leave your desk unattended', FALSE, 4),

    (44, 'HTTPS and padlock icon in the browser', TRUE, 1),
    (44, 'HTTP only', FALSE, 2),
    (44, 'Website colors', FALSE, 3),
    (44, 'Large images', FALSE, 4),

    (45, 'Unusual employee behavior such as data leaks', TRUE, 1),
    (45, 'Employees taking coffee breaks', FALSE, 2),
    (45, 'Normal email signatures', FALSE, 3),
    (45, 'Standard work routines', FALSE, 4);
