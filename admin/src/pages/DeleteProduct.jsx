import React, { useState } from 'react';
import axios from 'axios';

function DeleteProduct() {
  const [productId, setProductId] = useState('');
  const [message, setMessage] = useState('');

  const handleDelete = async () => {
    if (!productId) {
      setMessage('Enter the ID product');
      return;
    }

    try {
      const response = await axios.delete(`http://localhost:3000/admin/products/${productId}`);
      setMessage(response.data.message);
      setProductId('');
    } catch (error) {
      console.error('Error:', error);
      setMessage('❌cannot delete the product!');
    }
  };

  return (
    <div>
      <h2>Delete Product</h2>
      <input
        type="text"
        placeholder="Enter the ID of Product!"
        value={productId}
        onChange={(e) => setProductId(e.target.value)}
      />
      <button onClick={handleDelete}>Delete</button>
      <p>{message}</p>
    </div>
  );
}

export default DeleteProduct;
