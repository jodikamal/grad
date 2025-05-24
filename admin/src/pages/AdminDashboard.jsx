import React, { useState } from 'react';
import OrdersPage from './OrdersPage';
import AddProductPage from './AddProductPage';
import DeleteProduct  from './DeleteProduct';
import ProductList from './ProductList';
const AdminDashboard = () => {
  const [selectedTab, setSelectedTab] = useState('orders');

  return (
    <div>
      <div style={styles.navbar}>
        <button onClick={() => setSelectedTab('orders')} style={styles.button}>Orders</button>
        <button onClick={() => setSelectedTab('add')} style={styles.button}>Add Product</button>
        <button onClick={() => setSelectedTab('delete')} style={styles.button}>Delete Product</button>
        <button onClick={() => setSelectedTab('view')} style={styles.button}>View Products</button>
      </div>

      <div style={styles.pageContent}>
        {selectedTab === 'orders' && <OrdersPage />}
        {selectedTab === 'add' && <AddProductPage />}
        {selectedTab === 'delete' && <DeleteProduct/>}
        {selectedTab === 'view' && <ProductList/>}
      </div>
    </div>
  );
};

const styles = {
  navbar: {
    display: 'flex',
    backgroundColor: '#5e36b1',
    padding: 10,
  },
  button: {
    color: '#fff',
    backgroundColor: 'transparent',
    border: 'none',
    fontSize: 18,
    marginRight: 20,
    cursor: 'pointer',
  },
  pageContent: {
    padding: 20,
  },
};

export default AdminDashboard;
