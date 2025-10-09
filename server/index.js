require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const session = require('express-session');
const mysql = require('mysql2');
const app = express();
const PORT = process.env.PORT || 3000;

// Database connection
const db = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME
});
// Test database connection
db.connect((err) => {
  if (err) {
    console.error('Database connection failed:', err.message);
  } else {
    console.log('Connected to MySQL database');
  }
});

// Middleware
app.use(cors({
  origin: ['http://localhost:5173', 'http://localhost:5174'],
  credentials: true
}));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(session({
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
  cookie: { secure: false, maxAge: 24 * 60 * 60 * 1000 }
}));

// Authentication endpoints

// POST /api/register
app.post('/api/register', (req, res) => {
  const { username, email, password } = req.body;
  
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
        user: { id: result.insertId, username, email }
      });
    });
  });
});

// POST /api/login
app.post('/api/login', (req, res) => {
  const { email, password } = req.body;
  
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
      user: { id: user.id, username: user.username, email: user.email }
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
      SELECT 
        q.id as question_id,
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

// POST /api/quizzes/:id/submit - Submit answers, grade, and store results
app.post('/api/quizzes/:id/submit', (req, res) => {
  // Require login
  if (!req.session.userId) {
    return res.status(401).json({ success: false, message: 'Not logged in' });
  }

  const quizId = req.params.id;
  const { answers } = req.body || {};

  if (!Array.isArray(answers) || answers.length === 0) {
    return res.status(400).json({ success: false, message: 'Answers are required' });
  }

  // Validate quiz exists
  const quizCheckQuery = 'SELECT id, total_questions FROM quizzes WHERE id = ?';
  db.query(quizCheckQuery, [quizId], (err, quizResults) => {
    if (err) {
      return res.status(500).json({ success: false, message: 'Database error' });
    }

    if (quizResults.length === 0) {
      return res.status(404).json({ success: false, message: 'Quiz not found' });
    }

    // Fetch correct answers for the questions of this quiz
    const questionIds = answers.map(a => a.questionId);
    if (questionIds.length === 0) {
      return res.status(400).json({ success: false, message: 'No question answers provided' });
    }

    const placeholders = questionIds.map(() => '?').join(',');
    const correctQuery = `
      SELECT q.id AS question_id, a.id AS answer_id, a.is_correct
      FROM questions q
      JOIN answers a ON a.question_id = q.id
      WHERE q.quiz_id = ? AND q.id IN (${placeholders})
    `;

    db.query(correctQuery, [quizId, ...questionIds], (err, rows) => {
      if (err) {
        return res.status(500).json({ success: false, message: 'Database error' });
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
        graded.push({ questionId: a.questionId, selectedAnswerId: a.selectedAnswerId, isCorrect });
      }

      const totalQuestions = graded.length; // count of answered questions that belong to this quiz

      // Insert attempt
      const insertAttempt = 'INSERT INTO user_attempts (user_id, quiz_id, score, total_questions) VALUES (?, ?, ?, ?)';
      db.query(insertAttempt, [req.session.userId, quizId, correctCount, totalQuestions], (err, result) => {
        if (err) {
          return res.status(500).json({ success: false, message: 'Failed to save attempt' });
        }

        const attemptId = result.insertId;

        // Insert responses (bulk)
        if (graded.length === 0) {
          return res.json({
            success: true,
            results: { attemptId, score: correctCount, totalQuestions, correctCount }
          });
        }

        const values = graded.map(g => [attemptId, g.questionId, g.selectedAnswerId, g.isCorrect]);
        const insertResponses = 'INSERT INTO user_responses (attempt_id, question_id, selected_answer_id, is_correct) VALUES ?';

        // mysql2 supports bulk insert via query with array of arrays as second param when using the special [values]
        db.query(insertResponses, [values], (err) => {
          if (err) {
            return res.status(500).json({ success: false, message: 'Failed to save responses' });
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

// GET /api/users/:id/attempts - Fetch attempts for the logged-in user
app.get('/api/users/:id/attempts', (req, res) => {
  // Require login
  if (!req.session.userId) {
    return res.status(401).json({ success: false, message: 'Not logged in' });
  }

  const requestedUserId = parseInt(req.params.id, 10);
  if (!Number.isInteger(requestedUserId)) {
    return res.status(400).json({ success: false, message: 'Invalid user id' });
  }

  // Authorization: user can only access their own attempts
  if (requestedUserId !== req.session.userId) {
    return res.status(403).json({ success: false, message: 'Forbidden' });
  }

  const attemptsQuery = `
    SELECT 
      ua.id AS attempt_id,
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
      return res.status(500).json({ success: false, message: 'Database error' });
    }

    return res.json({ success: true, attempts: results });
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
