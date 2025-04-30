const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql2');
const cors = require('cors');
const app = express();
const port = 3000;
const bcrypt = require('bcrypt');
const saltRounds = 10;
const admin = require('firebase-admin');
// Middlewares
app.use(cors());
app.use(bodyParser.json());

// اتصال بقاعدة البيانات
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '0000', //
  database: 'glamzydb' // 
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
  console.log("📥 Body:", req.body);
  const { email, password } = req.body;

  db.query('SELECT * FROM users WHERE email = ? LIMIT 1', [email], (err, results) => {
    if (err) return res.status(500).json({ message: 'Database error', err });
    if (!results.length) return res.status(401).json({ message: 'Invalid email or password' });

    const user = results[0];
    console.log('🔐 Stored hash in DB:', user.password);
    console.log('🔑 Password entered:', password);

    bcrypt.compare(password, user.password, (err, isMatch) => {
      console.log('🧪 bcrypt.compare →', { err, isMatch });
      if (err) return res.status(500).json({ message: 'Error comparing passwords', err });
      if (!isMatch) return res.status(401).json({ message: 'Invalid email or password' });

      return res.json({ message: 'Login successful', user_id: user.user_id, name: user.name,email:   user.email,user_type: user.user_type });
    });
  });
});




app.post('/signup', async (req, res) => {
  const { name, email, password, address, phone } = req.body;


  console.log(email);
  console.log(password);
  console.log(address);
  console.log(phone);

  
  if (!name || !email || !password || !address || !phone) {
    return res.status(400).json({ message: 'Please fill all required fields' });
  }

  try {
    
    const hashedPassword = await bcrypt.hash(password, 10); 

   
    const sql = 'INSERT INTO users (name, email, password, address, phone, user_type) VALUES (?, ?, ?, ?, ?, "user")';
    const values = [name, email, hashedPassword, address, phone];

    db.query(sql, values, (err, result) => {
      if (err) {
        console.error('Signup Error:', err);
        return res.status(500).json({ message: 'Error creating account', error: err });
      }
      res.status(200).json({ message: 'Account created successfully' });
    });

  } catch (err) {
    console.error('Hashing Error:', err);
    res.status(500).json({ message: 'Error hashing password', error: err });
  }
});
//****************************************************reset ********************************************/
// إضافة هذا الجزء إلى ملف serves.js بدلاً من الكود الحالي لـ '/resetPassword'
// ضعّي هذا بدلاً من كود resetPassword الحالي
app.put('/resetPassword', (req, res) => {
  console.log('🔄 /resetPassword hit with body:', req.body);
  const { email, newPassword } = req.body;

  if (!email || !newPassword) {
    console.log('⚠️  Missing email or newPassword');
    return res.status(400).json({ message: 'Please provide email and newPassword' });
  }

  // أولاً نشفّر الباسوورد الجديد
  bcrypt.hash(newPassword, saltRounds, (hashErr, hashed) => {
    if (hashErr) {
      console.error('❌ Error hashing newPassword:', hashErr);
      return res.status(500).json({ message: 'Error hashing password', error: hashErr });
    }
    console.log('🔐 New hashed password:', hashed);

    // بعدين نحدّث القاعدة
    const sql = 'UPDATE users SET password = ? WHERE email = ?';
    db.query(sql, [hashed, email], (dbErr, result) => {
      if (dbErr) {
        console.error('❌ DB error on UPDATE:', dbErr);
        return res.status(500).json({ message: 'Database error', error: dbErr });
      }
      if (result.affectedRows === 0) {
        console.log('⚠️  No user found for email:', email);
        return res.status(404).json({ message: 'User not found' });
      }
      console.log('✅ Password updated for:', email);
      return res.json({ message: 'Password updated successfully' });
    });
  });
});







// تشغيل السيرفر
app.listen(port, () => {
  console.log(`Server running at http://192.168.88.7:${port}`);
});
