import React, { useState } from 'react';
import OrdersPage from './OrdersPage';
import AddProductPage from './AddProductPage';
import DeleteProduct from './DeleteProduct';
import ProductList from './ProductList';

const AdminDashboard = () => {
  const [selectedTab, setSelectedTab] = useState('orders');

  const renderPage = () => {
    switch (selectedTab) {
      case 'orders':
        return <OrdersPage />;
      case 'add':
        return <AddProductPage />;
      case 'delete':
        return <DeleteProduct />;
      case 'view':
        return <ProductList />;
      default:
        return <OrdersPage />;
    }
  };

  return (
    <div style={styles.container}>
      {/* Sidebar */}
      <div style={styles.sidebar}>
        <h2 style={styles.logo}>Glamzy Admin</h2>
        <div style={styles.nav}>
          <SidebarButton
            label="Orders"
            active={selectedTab === 'orders'}
            onClick={() => setSelectedTab('orders')}
          />
          <SidebarButton
            label="Add Product"
            active={selectedTab === 'add'}
            onClick={() => setSelectedTab('add')}
          />
          <SidebarButton
            label="Delete Product"
            active={selectedTab === 'delete'}
            onClick={() => setSelectedTab('delete')}
          />
          <SidebarButton
            label="View Products"
            active={selectedTab === 'view'}
            onClick={() => setSelectedTab('view')}
          />
        </div>
      </div>

      {/* Main content */}
      <div style={styles.content}>
        {renderPage()}
      </div>
    </div>
  );
};

const SidebarButton = ({ label, active, onClick }) => {
  return (
    <button
      onClick={onClick}
      style={{
        ...styles.button,
        ...(active ? styles.activeButton : {}),
      }}
    >
      {label}
    </button>
  );
};

const styles = {
  container: {
    display: 'flex',
    height: '100vh',
    fontFamily: 'Segoe UI, sans-serif',
  },
  sidebar: {
    width: '220px',
    backgroundColor: '#5e36b1',
    color: 'white',
    padding: '20px',
    boxShadow: '2px 0 10px rgba(0,0,0,0.1)',
  },
  logo: {
    fontSize: '24px',
    marginBottom: '40px',
    textAlign: 'center',
  },
  nav: {
    display: 'flex',
    flexDirection: 'column',
    gap: '15px',
  },
  button: {
    backgroundColor: 'transparent',
    border: 'none',
    color: 'white',
    fontSize: '16px',
    padding: '10px 15px',
    textAlign: 'left',
    cursor: 'pointer',
    transition: 'background 0.3s',
    borderRadius: '8px',
  },
  activeButton: {
    backgroundColor: '#7B49D3',
    fontWeight: 'bold',
    boxShadow: 'inset 0 0 5px rgba(0,0,0,0.2)',
  },
  content: {
    flex: 1,
    backgroundColor: '#f7f7f7',
    padding: '30px',
    overflowY: 'auto',
  },
};

export default AdminDashboard;
