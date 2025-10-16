const express = require('express');
const router = express.Router();
const db = require('./db');

// ================= AUTH =================

// Register
router.post('/register', (req, res) => {
    const {username, email, password} = req.body;
    if (!username || !email || !password)
        return res.status(400).json({success: false, message: 'Username, email, and password are required'});

    const checkUser = 'SELECT id FROM users WHERE username = ? OR email = ?';
    db.query(checkUser, [username, email], (err, results) => {
        if (err) return res.status(500).json({success: false, message: 'Database error'});
        if (results.length > 0)
            return res.status(400).json({success: false, message: 'Username or email already exists'});

        const insertUser = 'INSERT INTO users (username, email, password) VALUES (?, ?, ?)';
        db.query(insertUser, [username, email, password], (err, result) => {
            if (err) return res.status(500).json({success: false, message: 'Failed to create user'});

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

// Login
router.post('/login', (req, res) => {
    const {email, password} = req.body;
    if (!email || !password)
        return res.status(400).json({success: false, message: 'Email and password are required'});

    const sql = 'SELECT id, username, email FROM users WHERE email = ? AND password = ?';
    db.query(sql, [email, password], (err, results) => {
        if (err) return res.status(500).json({success: false, message: 'Database error'});
        if (results.length === 0)
            return res.status(401).json({success: false, message: 'Invalid email or password'});

        const user = results[0];
        req.session.userId = user.id;
        req.session.username = user.username;
        res.json({success: true, message: 'Login successful', user});
    });
});

// Logout
router.post('/logout', (req, res) => {
    req.session.destroy(err => {
        if (err) return res.status(500).json({success: false, message: 'Failed to logout'});
        res.json({success: true, message: 'Logout successful'});
    });
});

// Current user
router.get('/me', (req, res) => {
    if (!req.session.userId)
        return res.status(401).json({success: false, message: 'Not logged in'});

    const sql = 'SELECT id, username, email FROM users WHERE id = ?';
    db.query(sql, [req.session.userId], (err, results) => {
        if (err) return res.status(500).json({success: false, message: 'Database error'});
        if (results.length === 0)
            return res.status(404).json({success: false, message: 'User not found'});
        res.json({success: true, user: results[0]});
    });
});

// ================= USERS =================
router.get('/users', (req, res) => {
    const sql = 'SELECT id, username, email, created_at FROM users ORDER BY created_at DESC';
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({success: false, message: 'Database error'});
        res.json({success: true, users: results});
    });
});

// ================= QUIZZES =================
router.get('/quizzes', (req, res) => {
    const sql = 'SELECT id, module_type, title, description, total_questions FROM quizzes ORDER BY module_type, id';
    db.query(sql, (err, results) => {
        if (err) return res.status(500).json({success: false, message: 'Database error'});
        res.json({success: true, quizzes: results});
    });
});

router.get('/quizzes/:id', (req, res) => {
    const quizId = req.params.id;
    const sql = 'SELECT id, module_type, title, description, total_questions FROM quizzes WHERE id = ?';
    db.query(sql, [quizId], (err, results) => {
        if (err) return res.status(500).json({success: false, message: 'Database error'});
        if (results.length === 0)
            return res.status(404).json({success: false, message: 'Quiz not found'});
        res.json({success: true, quiz: results[0]});
    });
});

// Questions per quiz
router.get('/quizzes/:id/questions', (req, res) => {
    const quizId = req.params.id;
    const quizCheck = 'SELECT id FROM quizzes WHERE id = ?';
    db.query(quizCheck, [quizId], (err, quizResults) => {
        if (err) return res.status(500).json({success: false, message: 'Database error'});
        if (quizResults.length === 0)
            return res.status(404).json({success: false, message: 'Quiz not found'});

        const qSql = `
            SELECT q.id AS question_id,
                   q.question_text,
                   q.question_type,
                   a.id AS answer_id,
                   a.answer_text,
                   a.is_correct,
                   a.answer_order
            FROM questions q
                     LEFT JOIN answers a ON q.id = a.question_id
            WHERE q.quiz_id = ?
            -- Keep questions stable by q.id, randomize answers per question using MySQL RAND()
            ORDER BY q.id, RAND()
        `;
        db.query(qSql, [quizId], (err, results) => {
            if (err) return res.status(500).json({success: false, message: 'Database error'});

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

            res.json({success: true, questions: Object.values(questionsMap)});
        });
    });
});

// ================= SUBMIT QUIZ =================
router.post('/quizzes/:id/submit', (req, res) => {
    if (!req.session.userId)
        return res.status(401).json({success: false, message: 'Not logged in'});

    const quizId = req.params.id;
    const {answers} = req.body || {};
    if (!Array.isArray(answers) || answers.length === 0)
        return res.status(400).json({success: false, message: 'Answers are required'});

    const quizCheck = 'SELECT id, total_questions FROM quizzes WHERE id = ?';
    db.query(quizCheck, [quizId], (err, quizResults) => {
        if (err) return res.status(500).json({success: false, message: 'Database error'});
        if (quizResults.length === 0)
            return res.status(404).json({success: false, message: 'Quiz not found'});

        const questionIds = answers.map(a => a.questionId);
        const placeholders = questionIds.map(() => '?').join(',');
        const correctSql = `
            SELECT q.id AS question_id, a.id AS answer_id, a.is_correct
            FROM questions q
                     JOIN answers a ON a.question_id = q.id
            WHERE q.quiz_id = ?
              AND q.id IN (${placeholders})
        `;
        db.query(correctSql, [quizId, ...questionIds], (err, rows) => {
            if (err) return res.status(500).json({success: false, message: 'Database error'});

            const correctByQuestion = new Map();
            rows.forEach(r => {
                if (r.is_correct) {
                    if (!correctByQuestion.has(r.question_id)) correctByQuestion.set(r.question_id, new Set());
                    correctByQuestion.get(r.question_id).add(r.answer_id);
                }
            });

            const validIds = new Set(rows.map(r => r.question_id));
            let correctCount = 0;
            const graded = [];
            for (const a of answers) {
                if (!validIds.has(a.questionId)) continue;
                const correctSet = correctByQuestion.get(a.questionId) || new Set();
                const isCorrect = correctSet.has(a.selectedAnswerId) ? 1 : 0;
                if (isCorrect) correctCount++;
                graded.push({questionId: a.questionId, selectedAnswerId: a.selectedAnswerId, isCorrect});
            }

            const totalQuestions = graded.length;
            const insertAttempt = 'INSERT INTO user_attempts (user_id, quiz_id, score, total_questions) VALUES (?, ?, ?, ?)';
            db.query(insertAttempt, [req.session.userId, quizId, correctCount, totalQuestions], (err, result) => {
                if (err) return res.status(500).json({success: false, message: 'Failed to save attempt'});

                const attemptId = result.insertId;
                if (graded.length === 0)
                    return res.json({
                        success: true,
                        results: {attemptId, score: correctCount, totalQuestions, correctCount}
                    });

                const values = graded.map(g => [attemptId, g.questionId, g.selectedAnswerId, g.isCorrect]);
                const insertResponses = 'INSERT INTO user_responses (attempt_id, question_id, selected_answer_id, is_correct) VALUES ?';
                db.query(insertResponses, [values], err => {
                    if (err) return res.status(500).json({success: false, message: 'Failed to save responses'});
                    res.json({success: true, results: {attemptId, score: correctCount, totalQuestions, correctCount}});
                });
            });
        });
    });
});

// ================= USER ATTEMPTS =================
router.get('/users/:id/attempts', (req, res) => {
    if (!req.session.userId)
        return res.status(401).json({success: false, message: 'Not logged in'});

    const userId = parseInt(req.params.id, 10);
    if (!Number.isInteger(userId))
        return res.status(400).json({success: false, message: 'Invalid user id'});

    if (userId !== req.session.userId)
        return res.status(403).json({success: false, message: 'Forbidden'});

    const sql = `
        SELECT ua.id AS   attempt_id,
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
    db.query(sql, [userId], (err, results) => {
        if (err) return res.status(500).json({success: false, message: 'Database error'});
        res.json({success: true, attempts: results});
    });
});

module.exports = router;
