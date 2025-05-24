import React, { useEffect, useState } from 'react';
import axios from 'axios';

function ProductList() {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    axios.get('http://localhost:3000/admin/products')
      .then(res => {
        setProducts(res.data);
        setLoading(false);
      })
      .catch(err => {
        console.error('Error fetching products:', err);
        setLoading(false);
      });
  }, []);

  if (loading) return <p>Loading products...</p>;

  return (
    <div>
      <h2>Product List</h2>
      <table border="1" cellPadding="8" cellSpacing="0">
        <thead>
          <tr>
            <th>Product ID</th>
            <th>Name</th>
            <th>Description</th>
            <th>Price ($)</th>
            <th>Image</th>
            <th>Size</th>
            <th>Quantity</th>
            <th>Average Rating</th>
            <th>Created At</th>
            <th>Category ID</th>
          </tr>
        </thead>
        <tbody>
          {products.map(prod => (
            <tr key={prod.product_id}>
              <td>{prod.product_id}</td>
              <td>{prod.name}</td>
              <td>{prod.description}</td>
              <td>{prod.price ? Number(prod.price).toFixed(2) : '-'}</td>
              <td>
                {prod.image_url ? (
                  <img src={prod.image_url} alt={prod.name} width="80" />
                ) : (
                  'No Image'
                )}
              </td>
              <td>{prod.size}</td>
              <td>{prod.quantity}</td>
              <td>{prod.average_rating}</td>
              <td>{new Date(prod.created_at).toLocaleDateString()}</td>
              <td>{prod.category_id}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default ProductList;
