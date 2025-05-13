
const bcrypt = require('bcrypt');

const plainPassword = '123456';

bcrypt.hash(plainPassword, 10, (err, hash) => {
  if (err) {
    console.error('❌ Error hashing password:', err);
  } else {
    console.log('🔐 Hashed password:', hash);
  }
});
