import React, { useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import glamzyLogo from '../assets/images/glamzy_logo.png';

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
      <div style={styles.overlay}>
        <div style={styles.formContainer}>
          <img src={glamzyLogo} alt="Glamzy Logo" style={styles.logo} />
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
    </div>
  );
};

const styles = {
  container: {
    background: 'linear-gradient(135deg, #8E2DE2, #4A00E0)',
    height: '100vh',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
  },
  overlay: {
    width: '100%',
    maxWidth: 420,
    padding: 24,
  },
  formContainer: {
    backgroundColor: '#fff',
    borderRadius: 16,
    boxShadow: '0 12px 24px rgba(0,0,0,0.2)',
    padding: 40,
    textAlign: 'center',
  },
  logo: {
    width: 120,
    height: 120,
    marginBottom: 20,
  },
  heading: {
    color: '#5e36b1',
    fontSize: 24,
    marginBottom: 30,
  },
  input: {
    width: '100%',
    padding: 14,
    marginBottom: 20,
    borderRadius: 10,
    border: '1px solid #ccc',
    fontSize: 16,
    outline: 'none',
  },
  button: {
    width: '100%',
    padding: 14,
    backgroundColor: '#5e36b1',
    color: '#fff',
    border: 'none',
    borderRadius: 10,
    fontSize: 16,
    cursor: 'pointer',
    transition: 'background-color 0.3s ease',
  },
  error: {
    color: 'red',
    marginTop: 10,
  },
};

export default AdminLogin;
