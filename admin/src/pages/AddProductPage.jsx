import React, { useState } from 'react';
import axios from 'axios';

const AddProductPage = () => {
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    price: '',
    size: '',
    quantity: '',
    category_id: '',
    image: null,
  });

  const [message, setMessage] = useState('');
  const [messageType, setMessageType] = useState(''); // 'success' | 'error'
  const [loading, setLoading] = useState(false);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleImageChange = (e) => {
    setFormData((prev) => ({ ...prev, image: e.target.files[0] || null }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    // Basic client-side validation
    if (
      !formData.name.trim() ||
      !formData.description.trim() ||
      !formData.price ||
      !formData.size.trim() ||
      !formData.quantity ||
      !formData.category_id ||
      !formData.image
    ) {
      setMessageType('error');
      setMessage('Please fill all required fields.');
      return;
    }

    setLoading(true);
    setMessage('');
    setMessageType('');

    try {
      const data = new FormData();
      Object.entries(formData).forEach(([key, value]) => {
        data.append(key, value);
      });

      const response = await axios.post('http://localhost:3000/admin/add-product', data, {
        headers: { 'Content-Type': 'multipart/form-data' },
      });

      setMessageType('success');
      setMessage(response.data.message || 'Product added successfully!');
      setFormData({
        name: '',
        description: '',
        price: '',
        size: '',
        quantity: '',
        category_id: '',
        image: null,
      });
    } catch (error) {
      console.error('Add product error:', error);
      setMessageType('error');
      setMessage('Failed to add product. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={styles.pageBackground}>
      <div style={styles.card}>
        <h2 style={styles.heading}>Add New Product</h2>
        <form onSubmit={handleSubmit} encType="multipart/form-data" noValidate>
          <label htmlFor="name" style={styles.label}>
            Product Name
          </label>
          <input
            id="name"
            type="text"
            name="name"
            placeholder="Enter product name"
            value={formData.name}
            onChange={handleChange}
            style={styles.input}
            required
            disabled={loading}
          />

          <label htmlFor="description" style={styles.label}>
            Description
          </label>
          <textarea
            id="description"
            name="description"
            placeholder="Enter product description"
            value={formData.description}
            onChange={handleChange}
            style={{ ...styles.input, height: '80px', resize: 'vertical' }}
            required
            disabled={loading}
          />

          <label htmlFor="price" style={styles.label}>
            Price ($)
          </label>
          <input
            id="price"
            type="number"
            name="price"
            placeholder="Enter price"
            value={formData.price}
            onChange={handleChange}
            style={styles.input}
            min="0"
            step="0.01"
            required
            disabled={loading}
          />

          <label htmlFor="size" style={styles.label}>
            Size (e.g., S, M, L)
          </label>
          <input
            id="size"
            type="text"
            name="size"
            placeholder="Enter size"
            value={formData.size}
            onChange={handleChange}
            style={styles.input}
            required
            disabled={loading}
          />

          <label htmlFor="quantity" style={styles.label}>
            Quantity
          </label>
          <input
            id="quantity"
            type="number"
            name="quantity"
            placeholder="Enter quantity"
            value={formData.quantity}
            onChange={handleChange}
            style={styles.input}
            min="0"
            required
            disabled={loading}
          />

          <label htmlFor="category_id" style={styles.label}>
            Category ID
          </label>
          <input
            id="category_id"
            type="number"
            name="category_id"
            placeholder="Enter category ID"
            value={formData.category_id}
            onChange={handleChange}
            style={styles.input}
            min="0"
            required
            disabled={loading}
          />

          <label htmlFor="image" style={styles.label}>
            Product Image
          </label>
          <input
            id="image"
            type="file"
            name="image"
            accept="image/*"
            onChange={handleImageChange}
            style={styles.fileInput}
            required
            disabled={loading}
          />

          <button
            type="submit"
            style={{ ...styles.button, ...(loading ? styles.buttonDisabled : {}) }}
            disabled={loading}
          >
            {loading ? 'Adding...' : 'Add Product'}
          </button>

          {message && (
            <p
              style={{
                ...styles.message,
                color: messageType === 'success' ? '#4caf50' : '#f44336',
              }}
              role={messageType === 'error' ? 'alert' : undefined}
            >
              {message}
            </p>
          )}
        </form>
      </div>
    </div>
  );
};

const styles = {
  pageBackground: {
    minHeight: '100vh',
    padding: '60px 20px',
    background: 'linear-gradient(135deg, #7B3FBF, #9E67D6, #7B3FBF)',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    fontFamily: "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif",
  },
  card: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 30,
    maxWidth: 500,
    width: '100%',
    boxShadow: '0 6px 18px rgba(123, 63, 191, 0.3)',
  },
  heading: {
    marginBottom: 24,
    textAlign: 'center',
    color: '#5e35b1',
    fontWeight: 700,
    fontSize: 28,
  },
  label: {
    display: 'block',
    marginBottom: 6,
    fontWeight: 600,
    color: '#4a148c',
    fontSize: 14,
  },
  input: {
    width: '100%',
    padding: '12px 14px',
    borderRadius: 8,
    border: '1.5px solid #b39ddb',
    marginBottom: 20,
    fontSize: 16,
    outline: 'none',
    color: '#4a148c',
    transition: 'border-color 0.3s',
  },
  fileInput: {
    marginBottom: 20,
    fontSize: 16,
    color: '#4a148c',
  },
  button: {
    width: '100%',
    padding: 14,
    borderRadius: 8,
    border: 'none',
    backgroundColor: '#7B3FBF',
    color: '#fff',
    fontSize: 16,
    fontWeight: 700,
    cursor: 'pointer',
    transition: 'background-color 0.3s',
  },
  buttonDisabled: {
    backgroundColor: '#b39ddb',
    cursor: 'not-allowed',
  },
  message: {
    marginTop: 20,
    fontSize: 15,
    textAlign: 'center',
  },
};

export default AddProductPage;
