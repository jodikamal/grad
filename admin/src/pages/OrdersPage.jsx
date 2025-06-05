import React, { useEffect, useState } from 'react';
import axios from 'axios';

const OrdersPage = () => {
  const [orders, setOrders] = useState([]);
  const [selectedItems, setSelectedItems] = useState([]);
  const [showItemsModal, setShowItemsModal] = useState(false);

  useEffect(() => {
    fetchOrders();
  }, []);

  const fetchOrders = () => {
    axios.get('http://localhost:3000/admin/orders')
      .then(res => setOrders(res.data))
      .catch(err => console.error('Error fetching orders', err));
  };

  const handleUpdateStatus = (paymentId) => {
    axios.post('http://localhost:3000/admin/orders/update-status', {
      payment_id: paymentId,
      new_status: 'Your Order is Being Prepared'
    })
      .then(() => {
        alert('Order status updated!');
        fetchOrders();
      })
      .catch(err => {
        console.error('Error updating order status', err);
        alert('Failed to update status.');
      });
  };

  const handleViewItems = (paymentId) => {
    axios.get(`http://localhost:3000/api/payments/${paymentId}/items`)
      .then(res => {
        setSelectedItems(res.data);
        setShowItemsModal(true);
      })
      .catch(err => {
        console.error('Error fetching items', err);
        alert('Failed to load order items.');
      });
  };

  const tableStyle = {
    width: '100%',
    borderCollapse: 'collapse',
  };

  const thStyle = {
    borderBottom: '2px solid #ddd',
    padding: '12px',
    backgroundColor: '#7B49D3', // Glamzy purple
    color: 'white',
    textAlign: 'left',
  };

  const tdStyle = {
    borderBottom: '1px solid #ddd',
    padding: '10px',
  };

  const buttonStyle = {
    backgroundColor: '#7B49D3',
    color: 'white',
    border: 'none',
    padding: '8px 12px',
    borderRadius: '5px',
    cursor: 'pointer',
  };

  const disabledButtonStyle = {
    ...buttonStyle,
    backgroundColor: '#bbb',
    cursor: 'not-allowed',
  };

  return (
    <div style={{ padding: '20px', fontFamily: 'Arial, sans-serif' }}>
      <h2 style={{ color: '#7B49D3' }}>Orders</h2>
      <table style={tableStyle}>
        <thead>
          <tr>
            <th style={thStyle}>ID</th>
            <th style={thStyle}>User ID</th>
            <th style={thStyle}>User Name</th>
            <th style={thStyle}>Amount</th>
            <th style={thStyle}>Payment Method</th>
            <th style={thStyle}>Delivery Option</th>
            <th style={thStyle}>Payment Date</th>
            <th style={thStyle}>Order Status</th>
            <th style={thStyle}>View Items</th>
            <th style={thStyle}>Actions</th>
          </tr>
        </thead>
        <tbody>
          {orders.map(order => (
            <tr key={order.payment_id}>
              <td style={tdStyle}>{order.payment_id}</td>
              <td style={tdStyle}>{order.user_id}</td>
              <td style={tdStyle}>{order.user_name}</td>
              <td style={tdStyle}>
                {order.amount != null && !isNaN(order.amount)
                  ? `$${Number(order.amount).toFixed(2)}`
                  : 'N/A'}
              </td>
              <td style={tdStyle}>{order.payment_method}</td>
              <td style={tdStyle}>{order.delivery_option}</td>
              <td style={tdStyle}>{new Date(order.payment_date).toLocaleString()}</td>
              <td style={tdStyle}>{order.order_status}</td>
              <td style={tdStyle}>
                <button style={buttonStyle} onClick={() => handleViewItems(order.payment_id)}>
                  View Items
                </button>
              </td>
              <td style={tdStyle}>
                {order.order_status === 'Your Order Sent Successfully!' ? (
                  <button style={buttonStyle} onClick={() => handleUpdateStatus(order.payment_id)}>
                    Mark as Being Prepared
                  </button>
                ) : (
                  <button style={disabledButtonStyle} disabled>
                    Update Status
                  </button>
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      {/* Modal for order items */}
      {showItemsModal && (
        <div style={{
          position: 'fixed', top: 0, left: 0, width: '100%',
          height: '100%', backgroundColor: 'rgba(0,0,0,0.5)',
          display: 'flex', justifyContent: 'center', alignItems: 'center',
          zIndex: 1000,
        }}>
          <div style={{
            background: 'white', padding: '20px', borderRadius: '8px',
            maxHeight: '80%', overflowY: 'auto', minWidth: '300px',
            boxShadow: '0 4px 12px rgba(0,0,0,0.2)'
          }}>
            <h3 style={{ marginTop: 0 }}>Order Items</h3>
            <button
              onClick={() => setShowItemsModal(false)}
              style={{ ...buttonStyle, marginBottom: '15px' }}
            >
              Close
            </button>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '15px' }}>
              {selectedItems.map((item, index) => (
                <div key={index} style={{ textAlign: 'center', width: '120px' }}>
  <img
    src={item.image_url}
    alt="Product"
    width="100"
    style={{ borderRadius: '8px', border: '1px solid #ccc' }}
  />
  <div style={{ marginTop: '5px' }}>Quantity: {item.quantity}</div>

  {/* عرض صورة التصميم إذا كانت موجودة */}
  {item.image_designed && (
    <div style={{ marginTop: '10px' }}>
      <strong style={{ fontSize: '12px' }}>Custom Design:</strong>
      <img
        src={item.image_designed}
        alt="Designed"
        width="100"
        style={{ borderRadius: '8px', border: '1px dashed #7B49D3', marginTop: '5px' }}
      />
    </div>
  )}
</div>

              ))}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default OrdersPage;
