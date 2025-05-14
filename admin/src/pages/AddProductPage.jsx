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
    image: null
  });

  const [message, setMessage] = useState('');

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleImageChange = (e) => {
    setFormData(prev => ({ ...prev, image: e.target.files[0] }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    const data = new FormData();
    for (const key in formData) {
      data.append(key, formData[key]);
    }

    try {
      const response = await axios.post('http://localhost:3000/admin/add-product', data, {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      });

      setMessage(response.data.message);
    } catch (error) {
      console.error(error);
      setMessage('Error adding product');
    }
  };

  return (
    <div style={{ maxWidth: '500px', margin: 'auto' }}>
      <h2>Add New Product</h2>
      <form onSubmit={handleSubmit} encType="multipart/form-data">
        <input type="text" name="name" placeholder="Product Name" onChange={handleChange} required /><br /><br />
        <textarea name="description" placeholder="Description" onChange={handleChange} required /><br /><br />
        <input type="number" name="price" placeholder="Price" onChange={handleChange} required /><br /><br />
        <input type="text" name="size" placeholder="Size (e.g., S, M, L)" onChange={handleChange} required /><br /><br />
        <input type="number" name="quantity" placeholder="Quantity" onChange={handleChange} required /><br /><br />
        <input type="number" name="category_id" placeholder="Category ID" onChange={handleChange} required /><br /><br />
        <input type="file" name="image" onChange={handleImageChange} accept="image/*" required /><br /><br />
        <button type="submit">Add Product</button>
      </form>

      {message && <p>{message}</p>}
    </div>
  );
};

export default AddProductPage;
