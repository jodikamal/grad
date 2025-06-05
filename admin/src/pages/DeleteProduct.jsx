import React, { useState } from 'react';
import axios from 'axios';

function DeleteProduct() {
  const [productId, setProductId] = useState('');
  const [message, setMessage] = useState('');
  const [messageType, setMessageType] = useState(''); // 'success' or 'error'
  const [loading, setLoading] = useState(false);

  const handleDelete = async () => {
    if (!productId.trim()) {
      setMessageType('error');
      setMessage('⚠️ Please enter the product ID.');
      return;
    }

    const confirm = window.confirm(`Are you sure you want to delete product ID: ${productId}?`);
    if (!confirm) return;

    try {
      setLoading(true);
      const response = await axios.delete(`http://localhost:3000/admin/products/${productId}`);
      setMessageType('success');
      setMessage(response.data.message || '✅ Product deleted successfully.');
      setProductId('');
    } catch (error) {
      setMessageType('error');
      setMessage('❌ Failed to delete the product. Please check the ID and try again.');
      console.error('Delete error:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={styles.pageBackground}>
      <div style={styles.container}>
        <h2 style={styles.title}>Delete Product</h2>

        <label htmlFor="productId" style={styles.label}>
          Product ID
        </label>
        <input
          id="productId"
          type="text"
          placeholder="Enter product ID"
          value={productId}
          onChange={(e) => setProductId(e.target.value)}
          style={styles.input}
          disabled={loading}
          aria-describedby="message"
        />

        <button
          onClick={handleDelete}
          style={{ ...styles.button, ...(loading || !productId.trim() ? styles.buttonDisabled : {}) }}
          disabled={loading || !productId.trim()}
          aria-disabled={loading || !productId.trim()}
        >
          {loading ? 'Deleting...' : 'Delete'}
        </button>

        {message && (
          <p
            id="message"
            style={{
              ...styles.message,
              color: messageType === 'success' ? '#4caf50' : '#f44336',
            }}
            role={messageType === 'error' ? 'alert' : undefined}
          >
            {message}
          </p>
        )}
      </div>
    </div>
  );
}

const styles = {
  pageBackground: {
    minHeight: '100vh',
    padding: '60px 20px',
    background: 'linear-gradient(135deg, #7B3FBF, #9E67D6, #7B3FBF)', // Glamzy-inspired purple gradient
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    fontFamily: "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif",
  },
  container: {
    maxWidth: 400,
    width: '100%',
    padding: 30,
    borderRadius: 12,
    boxShadow: '0 6px 18px rgba(123, 63, 191, 0.3)',
    backgroundColor: '#fff',
  },
  title: {
    marginBottom: 20,
    fontWeight: '700',
    fontSize: 26,
    textAlign: 'center',
    color: '#5e35b1',
  },
  label: {
    display: 'block',
    marginBottom: 6,
    fontWeight: '600',
    fontSize: 14,
    color: '#4a148c',
  },
  input: {
    width: '100%',
    padding: '12px 14px',
    fontSize: 16,
    borderRadius: 8,
    border: '1.5px solid #b39ddb',
    marginBottom: 20,
    transition: 'border-color 0.3s',
    outline: 'none',
    color: '#4a148c',
  },
  button: {
    width: '100%',
    padding: '14px',
    backgroundColor: '#7B3FBF',
    border: 'none',
    borderRadius: 8,
    color: '#fff',
    fontWeight: '700',
    fontSize: 16,
    cursor: 'pointer',
    transition: 'background-color 0.3s',
  },
  buttonDisabled: {
    backgroundColor: '#b39ddb',
    cursor: 'not-allowed',
  },
  message: {
    marginTop: 18,
    fontSize: 15,
    textAlign: 'center',
  },
};

export default DeleteProduct;
