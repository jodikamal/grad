const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql2');
const cors = require('cors');
const app = express();
const port = 3000;

// Middlewares
app.use(cors());
app.use(bodyParser.json());

// اتصال بقاعدة البيانات
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '0000', // حط كلمة المرور تبعتك إذا في
  database: 'glamzydb' // غيّرها لاس قاعدتكم
});

db.connect((err) => {
  if (err) {
    console.error('Database connection failed:', err);
    return;
  }
  console.log('Connected to MySQL database');
});

// تسجيل الدخول
app.post('/login', (req, res) => {
  const { email, password } = req.body;

  const query = 'SELECT * FROM users WHERE email = ? AND password = ? LIMIT 1';
  db.query(query, [email, password], (err, results) => {
    if (err) {
      return res.status(500).json({ message: 'Database error', error: err });
    }

    if (results.length === 0) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    const user = results[0];
    return res.status(200).json({
      message: 'Login successful',
      user_id: user.user_id,
      name: user.name,
      email: user.email,
      user_type: user.user_type
    });
  });




});



app.post('/signup', (req, res) => {
    const { name, email, password, address, phone } = req.body;
  
    if (!name || !email || !password || !address || !phone) {
      return res.status(400).json({ message: 'Please fill all required fields' });
    }
  
    const sql = 'INSERT INTO users (name, email, password, address, phone) VALUES (?, ?, ?, ?, ?)';
    const values = [name, email, password, address, phone];
  
    db.query(sql, values, (err, result) => {
      if (err) {
        console.error('Signup Error:', err);
        return res.status(500).json({ message: 'Error creating account', error: err });
      }
      res.status(200).json({ message: 'Account created successfully' });
    });
  });
  
// تشغيل السيرفر
app.listen(port, () => {
  console.log(`Server running at http://192.168.88.9:${port}`);
});
