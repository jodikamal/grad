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


app.post('/admin/login', (req, res) => {
  
  const { email, password } = req.body;

  db.query('SELECT * FROM users WHERE email = ? AND user_type = "admin" LIMIT 1', [email], (err, results) => {
    if (err) return res.status(500).json({ message: 'Database error', err });
    if (!results.length) return res.status(401).json({ message: 'Invalid credentials or not an admin' });

    const user = results[0];

    bcrypt.compare(password, user.password, (err, isMatch) => {
      if (err) return res.status(500).json({ message: 'Error comparing passwords', err });
      if (!isMatch) return res.status(401).json({ message: 'Invalid password' });

      return res.json({
        message: 'Admin login successful',
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


//adding to cart

app.post('/cart/add', (req, res) => {
  const { user_id, product_id, quantity } = req.body;

  const sqlCheck = 'SELECT * FROM shopping_cart WHERE user_id = ? AND product_id = ?';
  db.query(sqlCheck, [user_id, product_id], (err, results) => {
    if (err) return res.status(500).json({ message: 'Database error', err });

    if (results.length > 0) {
      const newQty = results[0].quantity + quantity;
      const sqlUpdate = 'UPDATE shopping_cart SET quantity = ? WHERE user_id = ? AND product_id = ?';
      db.query(sqlUpdate, [newQty, user_id, product_id], (err) => {
        if (err) return res.status(500).json({ message: 'Error updating quantity', err });
        return res.json({ message: 'Cart updated successfully' });
      });
    } else {
      const sqlInsert = `
        INSERT INTO shopping_cart (user_id, product_id, quantity, date_cart)
        VALUES (?, ?, 1, CURDATE())
      `;
      db.query(sqlInsert, [user_id, product_id, quantity], (err) => {
        if (err) return res.status(500).json({ message: 'Error adding to cart', err });
        return res.json({ message: 'Item added to cart' });
      });
    }
  });
});

//show the items in the cart 
app.get('/cart/:user_id', (req, res) => {
  const user_id = parseInt(req.params.user_id);

  // تحقق إن القيمة رقم وصالحة
  if (isNaN(user_id)) {
    return res.status(400).json({ message: 'Invalid user ID provided' });
  }

  const sql = `
    SELECT sc.cart_id, sc.product_id, sc.quantity, p.name, p.price, p.image_url
    FROM shopping_cart sc
    JOIN products p ON sc.product_id = p.product_id 
    WHERE sc.user_id = ?
  `;

  console.log("Running query for user ID:", user_id);

  db.query(sql, [user_id], (err, results) => {
    if (err) {
      console.error("Query error:", err);
      return res.status(500).json({ message: 'Error fetching cart', err });
    }

    if (results.length === 0) {
      return res.status(200).json({ message: `No cart items found for user: ${user_id}` });
    }

    res.json(results);
  });
});




//delete from the cart 
app.delete('/cart/remove', (req, res) => {
  const { user_id, product_id } = req.body;
  const sql = 'DELETE FROM shopping_cart WHERE user_id = ? AND product_id = ?';
  db.query(sql, [user_id, product_id], (err) => {
    if (err) return res.status(500).json({ message: 'Error removing item', err });
    res.json({ message: 'Item removed from cart' });
  });
});

//update the cart 
app.put('/cart/update', (req, res) => {
  const { user_id, product_id, quantity } = req.body;
  const sql = 'UPDATE shopping_cart SET quantity = ? WHERE user_id = ? AND product_id = ?';
  db.query(sql, [quantity, user_id, product_id], (err) => {
    if (err) return res.status(500).json({ message: 'Error updating quantity', err });
    res.json({ message: 'Quantity updated' });
  });
});
//fooooooooor adminnnnnnnn
app.get('/admin/orders', (req, res) => {
  const query = `
    SELECT p.payment_id, p.amount, p.payment_date, p.payment_method, p.delivery_option, u.name AS user_name, p.user_id
    FROM pay p
    JOIN users u ON p.user_id = u.user_id
    ORDER BY p.payment_date DESC
  `;
  db.query(query, (err, results) => {
    if (err) return res.status(500).json({ message: 'Error fetching orders', err });
    res.json(results);
  });
});


// تشغيل السيرفر
app.listen(port, () => {
  console.log(`Server running at http://192.168.88.3:${port}`);
});
