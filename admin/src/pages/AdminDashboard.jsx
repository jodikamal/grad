import React, { useState } from 'react';
import OrdersPage from './OrdersPage';
import AddProductPage from './AddProductPage';

const AdminDashboard = () => {
  const [selectedTab, setSelectedTab] = useState('orders');

  return (
    <div>
      <div style={styles.navbar}>
        <button onClick={() => setSelectedTab('orders')} style={styles.button}>Orders</button>
        <button onClick={() => setSelectedTab('add')} style={styles.button}>Add Product</button>
      </div>

      <div style={styles.pageContent}>
        {selectedTab === 'orders' && <OrdersPage />}
        {selectedTab === 'add' && <AddProductPage />}
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
