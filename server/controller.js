// POST /api/register
app.post('/api/register', (req, res) => {
    const {username, email, password} = req.body;

    if (!username || !email || !password) {
        return res.status(400).json({
            success: false,
            message: 'Username, email, and password are required'
        });
    }

    const checkUserQuery = 'SELECT id FROM users WHERE username = ? OR email = ?';
    db.query(checkUserQuery, [username, email], (err, results) => {
        if (err) {
            return res.status(500).json({
                success: false,
                message: 'Database error'
            });
        }

        if (results.length > 0) {
            return res.status(400).json({
                success: false,
                message: 'Username or email already exists'
            });
        }

        const insertUserQuery = 'INSERT INTO users (username, email, password) VALUES (?, ?, ?)';
        db.query(insertUserQuery, [username, email, password], (err, result) => {
            if (err) {
                return res.status(500).json({
                    success: false,
                    message: 'Failed to create user'
                });
            }

            req.session.userId = result.insertId;
            req.session.username = username;

            res.json({
                success: true,
                message: 'User registered successfully',
                user: {id: result.insertId, username, email}
            });
        });
    });
});

// POST /api/login
app.post('/api/login', (req, res) => {
    const {email, password} = req.body;

    if (!email || !password) {
        return res.status(400).json({
            success: false,
            message: 'Email and password are required'
        });
    }

    const loginQuery = 'SELECT id, username, email FROM users WHERE email = ? AND password = ?';
    db.query(loginQuery, [email, password], (err, results) => {
        if (err) {
            return res.status(500).json({
                success: false,
                message: 'Database error'
            });
        }

        if (results.length === 0) {
            return res.status(401).json({
                success: false,
                message: 'Invalid email or password'
            });
        }

        const user = results[0];
        req.session.userId = user.id;
        req.session.username = user.username;

        res.json({
            success: true,
            message: 'Login successful',
            user: {id: user.id, username: user.username, email: user.email}
        });
    });
});

// POST /api/logout
app.post('/api/logout', (req, res) => {
    req.session.destroy((err) => {
        if (err) {
            return res.status(500).json({
                success: false,
                message: 'Failed to logout'
            });
        }

        res.json({
            success: true,
            message: 'Logout successful'
        });
    });
});

// POST /api/quizzes/:id/submit - Submit answers, grade, and store results
app.post('/api/quizzes/:id/submit', (req, res) => {
    // Require login
    if (!req.session.userId) {
        return res.status(401).json({success: false, message: 'Not logged in'});
    }

    const quizId = req.params.id;
    const {answers} = req.body || {};

    if (!Array.isArray(answers) || answers.length === 0) {
        return res.status(400).json({success: false, message: 'Answers are required'});
    }

    // Validate quiz exists
    const quizCheckQuery = 'SELECT id, total_questions FROM quizzes WHERE id = ?';
    db.query(quizCheckQuery, [quizId], (err, quizResults) => {
        if (err) {
            return res.status(500).json({success: false, message: 'Database error'});
        }

        if (quizResults.length === 0) {
            return res.status(404).json({success: false, message: 'Quiz not found'});
        }

        // Fetch correct answers for the questions of this quiz
        const questionIds = answers.map(a => a.questionId);
        if (questionIds.length === 0) {
            return res.status(400).json({success: false, message: 'No question answers provided'});
        }

        const placeholders = questionIds.map(() => '?').join(',');
        const correctQuery = `
            SELECT q.id AS question_id, a.id AS answer_id, a.is_correct
            FROM questions q
                     JOIN answers a ON a.question_id = q.id
            WHERE q.quiz_id = ?
              AND q.id IN (${placeholders})
        `;

        db.query(correctQuery, [quizId, ...questionIds], (err, rows) => {
            if (err) {
                return res.status(500).json({success: false, message: 'Database error'});
            }

            // Build maps for quick lookup
            const correctByQuestion = new Map(); // question_id -> Set(correct answer ids)
            rows.forEach(r => {
                if (r.is_correct) {
                    if (!correctByQuestion.has(r.question_id)) correctByQuestion.set(r.question_id, new Set());
                    correctByQuestion.get(r.question_id).add(r.answer_id);
                }
            });

            // Grade (only for questions that belong to this quiz)
            const validQuestionIds = new Set(rows.map(r => r.question_id));
            let correctCount = 0;
            const graded = [];
            for (const a of answers) {
                if (!validQuestionIds.has(a.questionId)) {
                    continue; // skip answers to questions not in this quiz
                }
                const correctSet = correctByQuestion.get(a.questionId) || new Set();
                const isCorrect = correctSet.has(a.selectedAnswerId) ? 1 : 0;
                if (isCorrect) correctCount += 1;
                graded.push({questionId: a.questionId, selectedAnswerId: a.selectedAnswerId, isCorrect});
            }

            const totalQuestions = graded.length; // count of answered questions that belong to this quiz

            // Insert attempt
            const insertAttempt = 'INSERT INTO user_attempts (user_id, quiz_id, score, total_questions) VALUES (?, ?, ?, ?)';
            db.query(insertAttempt, [req.session.userId, quizId, correctCount, totalQuestions], (err, result) => {
                if (err) {
                    return res.status(500).json({success: false, message: 'Failed to save attempt'});
                }

                const attemptId = result.insertId;

                // Insert responses (bulk)
                if (graded.length === 0) {
                    return res.json({
                        success: true,
                        results: {attemptId, score: correctCount, totalQuestions, correctCount}
                    });
                }

                const values = graded.map(g => [attemptId, g.questionId, g.selectedAnswerId, g.isCorrect]);
                const insertResponses = 'INSERT INTO user_responses (attempt_id, question_id, selected_answer_id, is_correct) VALUES ?';

                // mysql2 supports bulk insert via query with array of arrays as second param when using the special [values]
                db.query(insertResponses, [values], (err) => {
                    if (err) {
                        return res.status(500).json({success: false, message: 'Failed to save responses'});
                    }

                    res.json({
                        success: true,
                        results: {
                            attemptId,
                            score: correctCount,
                            totalQuestions,
                            correctCount
                        }
                    });
                });
            });
        });
    });
});