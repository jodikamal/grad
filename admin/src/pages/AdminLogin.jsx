import React, { useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

const AdminLogin = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.post('http://localhost:3000/admin/login', {
        email,
        password,
      });
      console.log(response.data);
      alert('Login successful!');
      navigate('/admin/dashboard');
    } catch (err) {
      console.error(err);
      setError('Login failed. Check credentials.');
    }
  };

  return (
    <div style={styles.container}>
      <div style={styles.formContainer}>
        <h2 style={styles.heading}>Admin Login</h2>
        <form onSubmit={handleLogin}>
          <input
            type="email"
            placeholder="Email"
            value={email}
            required
            onChange={(e) => setEmail(e.target.value)}
            style={styles.input}
          />
          <input
            type="password"
            placeholder="Password"
            value={password}
            required
            onChange={(e) => setPassword(e.target.value)}
            style={styles.input}
          />
          <button type="submit" style={styles.button}>Login</button>
          {error && <p style={styles.error}>{error}</p>}
        </form>
      </div>
    </div>
  );
};

const styles = {
  container: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    height: '100vh',
    backgroundColor: '#f4f4f4',
  },
  formContainer: {
    backgroundColor: '#fff',
    borderRadius: 8,
    boxShadow: '0 4px 8px rgba(0, 0, 0, 0.1)',
    padding: 40,
    width: '100%',
    maxWidth: 400,
  },
  heading: {
    textAlign: 'center',
    color: '#5e36b1', // Purple, similar to Glamzy's brand color
    fontSize: 24,
    marginBottom: 30,
  },
  input: {
    width: '100%',
    padding: 12,
    marginBottom: 20,
    borderRadius: 8,
    border: '1px solid #ddd',
    fontSize: 16,
  },
  button: {
    width: '100%',
    padding: 14,
    backgroundColor: '#5e36b1', // Glamzy purple color
    color: '#fff',
    border: 'none',
    borderRadius: 8,
    fontSize: 16,
    cursor: 'pointer',
    transition: 'background-color 0.3s ease',
  },
  buttonHover: {
    backgroundColor: '#4b2d9d', // Darker purple when hovered
  },
  error: {
    color: 'red',
    textAlign: 'center',
    marginTop: 10,
  },
};

export default AdminLogin;
