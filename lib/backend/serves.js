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
  const { email, password } = req.body;

  // استعلام للبحث عن المستخدم باستخدام البريد الإلكتروني
  const query = 'SELECT * FROM users WHERE email = ? LIMIT 1';
  db.query(query, [email], (err, results) => {
    if (err) {
      return res.status(500).json({ message: 'Database error', error: err });
    }

    if (results.length === 0) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    const user = results[0];

    // التحقق من كلمة السر باستخدام bcrypt
    bcrypt.compare(password, user.password, (err, isMatch) => {
      if (err) {
        return res.status(500).json({ message: 'Error comparing passwords', error: err });
      }

      if (!isMatch) {
        return res.status(401).json({ message: 'Invalid email or password' });
      }

      // إذا كانت كلمة السر صحيحة
      return res.status(200).json({
        message: 'Login successful',
        user_id: user.user_id,
        name: user.name,
        email: user.email,
        user_type: user.user_type
      });
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

const resetPassword = (req, res) => {
  const { email, newPassword } = req.body;

  bcrypt.hash(newPassword, 10, async (hashError, hashedPassword) => {
    if (hashError) {
      return res.status(500).json({ status: 'error', message: 'Error hashing password' });
    }

    try {
      // تحديث الباسورد بـ MySQL
      await new Promise((resolve, reject) => {
        db.query('UPDATE user SET password = ?, otp = NULL WHERE email = ?', [hashedPassword, email], (err, results) => {
          if (err) reject(err);
          else if (results.affectedRows === 0) reject('User not found');
          else resolve();
        });
      });

      // تحديث الباسورد بـ Firebase
      const userRecord = await admin.auth().getUserByEmail(email);
      await admin.auth().updateUser(userRecord.uid, {
        password: newPassword,
      });

      res.status(200).json({ status: 'success', message: 'Password reset successfully!' });
    } catch (error) {
      console.error('Error resetting password:', error);
      res.status(500).json({ status: 'error', message: error.toString() });
    }
  });
};

const otpMap = new Map(); // email -> otp

// إرسال كود ٤ أرقام
const sendOtp = (req, res) => {
  const { email } = req.body;

  const otp = Math.floor(1000 + Math.random() * 9000).toString(); // يولد رقم 4 خانات

  otpMap.set(email, otp);

  console.log(`Generated OTP for ${email}: ${otp}`);

  res.status(200).json({ status: 'success', message: 'OTP generated successfully' });

  // تقدر تضيف إرسال إيميل هون إذا بدك
};

// تأكيد الكود
const verifyOtp = (req, res) => {
  const { email, otp } = req.body;

  const storedOtp = otpMap.get(email);

  if (storedOtp === otp) {
    otpMap.delete(email);
    res.status(200).json({ status: 'success', message: 'OTP verified successfully' });
  } else {
    res.status(400).json({ status: 'error', message: 'Invalid OTP' });
  }
};

const verifyOTP = (req, res) => {
  const { email, otp } = req.body;

  db.query('SELECT otp FROM user WHERE email = ?', [email], (err, results) => {
    if (err) {
      return res.status(500).json({ status: 'error', message: 'Database error' });
    }

    if (results.length === 0) {
      return res.status(404).json({ status: 'error', message: 'User not found' });
    }

    const storedOTP = results[0].otp;

    if (storedOTP === otp) {
      return res.status(200).json({ status: 'success', message: 'OTP verified' });
    } else {
      return res.status(400).json({ status: 'error', message: 'Invalid OTP' });
    }
  });
};

const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'YOUR_GMAIL_ADDRESS@gmail.com',
    pass: 'YOUR_APP_PASSWORD',
  },
});

const sendOTP = async (req, res) => {
  const { email } = req.body;
  const otp = Math.floor(1000 + Math.random() * 9000).toString(); // 4 digits

  try {
    // خزن الكود بالـ database
    await new Promise((resolve, reject) => {
      db.query('UPDATE user SET otp = ? WHERE email = ?', [otp, email], (err, results) => {
        if (err) reject(err);
        else resolve();
      });
    });

    // بعت الايميل
    const mailOptions = {
      from: 'YOUR_GMAIL_ADDRESS@gmail.com',
      to: email,
      subject: 'Glamzy App - Your OTP Code',
      html: `<h2>Hello!</h2><p>Your OTP code is: <strong>${otp}</strong></p><p>It will expire in 5 minutes.</p>`,
    };

    await transporter.sendMail(mailOptions);

    res.status(200).json({ status: 'success', message: 'OTP sent to email successfully!' });
  } catch (error) {
    console.error('Error sending OTP:', error);
    res.status(500).json({ status: 'error', message: error.toString() });
  }
};



async function updateFirebasePassword(uid, newPassword) {
  try {
    await admin.auth().updateUser(uid, {
      password: newPassword,
    });
    console.log('Password updated successfully in Firebase');
  } catch (error) {
    console.error('Error updating password in Firebase:', error);
  }
}
async function getUserUidByEmail(email) {
  try {
    const userRecord = await admin.auth().getUserByEmail(email);
    return userRecord.uid;
  } catch (error) {
    console.error('Error fetching user data:', error);
    throw error;
  }
}


// تشغيل السيرفر
app.listen(port, () => {
  console.log(`Server running at http://192.168.88.8:${port}`);
});
