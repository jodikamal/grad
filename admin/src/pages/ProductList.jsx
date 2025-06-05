import React, { useEffect, useState } from 'react';
import axios from 'axios';

function ProductList() {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    axios.get('http://localhost:3000/admin/products')
      .then(res => {
        setProducts(res.data);
        setLoading(false);
      })
      .catch(err => {
        console.error('Error fetching products:', err);
        setError('Failed to load products.');
        setLoading(false);
      });
  }, []);

  if (loading) return <p style={{ textAlign: 'center', marginTop: 50 }}>Loading products...</p>;
  if (error) return <p style={{ textAlign: 'center', marginTop: 50, color: 'red' }}>{error}</p>;
  if (products.length === 0) return <p style={{ textAlign: 'center', marginTop: 50 }}>No products found.</p>;

  return (
    <div style={{ maxWidth: 1200, margin: '40px auto', padding: '0 20px' }}>
      <h2 style={{ textAlign: 'center', marginBottom: 30, fontFamily: 'Arial, sans-serif', fontWeight: 'bold' }}>
        Product List
      </h2>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit,minmax(320px,1fr))', gap: 24 }}>
        {products.map(prod => (
          <div
            key={prod.product_id}
            style={{
              border: '1px solid #ddd',
              borderRadius: 8,
              padding: 20,
              boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
              backgroundColor: '#fff',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              fontFamily: 'Segoe UI, Tahoma, Geneva, Verdana, sans-serif'
            }}
          >
            {prod.image_url ? (
              <img
                src={prod.image_url}
                alt={prod.name}
                style={{ width: 180, height: 180, objectFit: 'contain', marginBottom: 16, borderRadius: 8 }}
              />
            ) : (
              <div
                style={{
                  width: 180,
                  height: 180,
                  backgroundColor: '#f0f0f0',
                  color: '#999',
                  display: 'flex',
                  justifyContent: 'center',
                  alignItems: 'center',
                  marginBottom: 16,
                  borderRadius: 8,
                  fontSize: 14,
                  fontStyle: 'italic'
                }}
              >
                No Image
              </div>
            )}

            <h3 style={{ margin: '0 0 8px', textAlign: 'center' }}>{prod.name}</h3>
            <p style={{ fontSize: 14, color: '#555', textAlign: 'center', minHeight: 48 }}>
              {prod.description || 'No description available.'}
            </p>

            <div style={{ marginTop: 12, width: '100%' }}>
              <DetailRow label="Price" value={`$${prod.price ? Number(prod.price).toFixed(2) : '-'}`} />
              <DetailRow label="Size" value={prod.size || '-'} />
              <DetailRow label="Quantity" value={prod.quantity || '-'} />
              <DetailRow label="Average Rating" value={prod.average_rating ? prod.average_rating.toFixed(1) : '-'} />
              <DetailRow label="Category ID" value={prod.category_id || '-'} />
              <DetailRow
                label="Created At"
                value={prod.created_at ? new Date(prod.created_at).toLocaleDateString() : '-'}
              />
              <DetailRow label="Product ID" value={prod.product_id} />
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function DetailRow({ label, value }) {
  return (
    <div
      style={{
        display: 'flex',
        justifyContent: 'space-between',
        padding: '6px 0',
        borderBottom: '1px solid #eee',
        fontSize: 14,
        color: '#333'
      }}
    >
      <strong>{label}:</strong> <span>{value}</span>
    </div>
  );
}

export default ProductList;
