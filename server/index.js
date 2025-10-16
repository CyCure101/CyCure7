


// Authentication endpoints


// GET /api/me
app.get('/api/me', (req, res) => {
    if (!req.session.userId) {
        return res.status(401).json({
            success: false,
            message: 'Not logged in'
        });
    }

    const userQuery = 'SELECT id, username, email FROM users WHERE id = ?';
    db.query(userQuery, [req.session.userId], (err, results) => {
        if (err) {
            return res.status(500).json({
                success: false,
                message: 'Database error'
            });
        }

        if (results.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        res.json({
            success: true,
            user: results[0]
        });
    });
});

// GET /api/users (for testing - remove in production)
app.get('/api/users', (req, res) => {
    const usersQuery = 'SELECT id, username, email, created_at FROM users ORDER BY created_at DESC';
    db.query(usersQuery, (err, results) => {
        if (err) {
            return res.status(500).json({
                success: false,
                message: 'Database error'
            });
        }

        res.json({
            success: true,
            users: results
        });
    });
});

// Quiz endpoints

// GET /api/quizzes - Get all available quizzes
app.get('/api/quizzes', (req, res) => {
    const quizzesQuery = 'SELECT id, module_type, title, description, total_questions FROM quizzes ORDER BY module_type, id';
    db.query(quizzesQuery, (err, results) => {
        if (err) {
            return res.status(500).json({
                success: false,
                message: 'Database error'
            });
        }

        res.json({
            success: true,
            quizzes: results
        });
    });
});

// GET /api/quizzes/:id - Get specific quiz details
app.get('/api/quizzes/:id', (req, res) => {
    const quizId = req.params.id;
    const quizQuery = 'SELECT id, module_type, title, description, total_questions FROM quizzes WHERE id = ?';

    db.query(quizQuery, [quizId], (err, results) => {
        if (err) {
            return res.status(500).json({
                success: false,
                message: 'Database error'
            });
        }

        if (results.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Quiz not found'
            });
        }

        res.json({
            success: true,
            quiz: results[0]
        });
    });
});

// GET /api/quizzes/:id/questions - Get questions for a specific quiz
app.get('/api/quizzes/:id/questions', (req, res) => {
    const quizId = req.params.id;

    // First check if quiz exists
    const quizCheckQuery = 'SELECT id FROM quizzes WHERE id = ?';
    db.query(quizCheckQuery, [quizId], (err, quizResults) => {
        if (err) {
            return res.status(500).json({
                success: false,
                message: 'Database error'
            });
        }

        if (quizResults.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Quiz not found'
            });
        }

        // Get questions with their answers
        const questionsQuery = `
            SELECT q.id as question_id,
                   q.question_text,
                   q.question_type,
                   a.id as answer_id,
                   a.answer_text,
                   a.is_correct,
                   a.answer_order
            FROM questions q
                     LEFT JOIN answers a ON q.id = a.question_id
            WHERE q.quiz_id = ?
            ORDER BY q.id, a.answer_order
        `;

        db.query(questionsQuery, [quizId], (err, results) => {
            if (err) {
                return res.status(500).json({
                    success: false,
                    message: 'Database error'
                });
            }

            // Group answers by question
            const questionsMap = {};
            results.forEach(row => {
                if (!questionsMap[row.question_id]) {
                    questionsMap[row.question_id] = {
                        id: row.question_id,
                        question_text: row.question_text,
                        question_type: row.question_type,
                        answers: []
                    };
                }

                if (row.answer_id) {
                    questionsMap[row.question_id].answers.push({
                        id: row.answer_id,
                        answer_text: row.answer_text,
                        is_correct: row.is_correct,
                        answer_order: row.answer_order
                    });
                }
            });

            const questions = Object.values(questionsMap);

            res.json({
                success: true,
                questions: questions
            });
        });
    });
});


// GET /api/users/:id/attempts - Fetch attempts for the logged-in user
app.get('/api/users/:id/attempts', (req, res) => {
    // Require login
    if (!req.session.userId) {
        return res.status(401).json({success: false, message: 'Not logged in'});
    }

    const requestedUserId = parseInt(req.params.id, 10);
    if (!Number.isInteger(requestedUserId)) {
        return res.status(400).json({success: false, message: 'Invalid user id'});
    }

    // Authorization: user can only access their own attempts
    if (requestedUserId !== req.session.userId) {
        return res.status(403).json({success: false, message: 'Forbidden'});
    }

    const attemptsQuery = `
        SELECT ua.id   AS attempt_id,
               ua.user_id,
               ua.quiz_id,
               q.title AS quiz_title,
               q.module_type,
               ua.score,
               ua.total_questions,
               ua.completed_at
        FROM user_attempts ua
                 JOIN quizzes q ON q.id = ua.quiz_id
        WHERE ua.user_id = ?
        ORDER BY ua.completed_at DESC, ua.id DESC
    `;

    db.query(attemptsQuery, [requestedUserId], (err, results) => {
        if (err) {
            return res.status(500).json({success: false, message: 'Database error'});
        }

        return res.json({success: true, attempts: results});
    });
});

// Basic route to test server
app.get('/', (req, res) => {
    res.json({
        message: 'CyCure Server is running!',
        status: 'success',
        port: PORT
    });
});


// Start server
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
