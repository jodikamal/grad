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

  return (
    <div>
      <h2>Orders</h2>
      <table border="1" cellPadding="10" style={{ width: '100%', textAlign: 'left' }}>
        <thead>
          <tr>
            <th>ID</th>
            <th>User ID</th>
            <th>User Name</th>
            <th>Amount</th>
            <th>Payment Method</th>
            <th>Delivery Option</th>
            <th>Payment Date</th>
            <th>Order Status</th>
            <th>View Items</th> {/* العمود الجديد */}
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {orders.map(order => (
            <tr key={order.payment_id}>
              <td>{order.payment_id}</td>
              <td>{order.user_id}</td>
              <td>{order.user_name}</td>
              <td>{order.amount}</td>
              <td>{order.payment_method}</td>
              <td>{order.delivery_option}</td>
              <td>{new Date(order.payment_date).toLocaleString()}</td>
              <td>{order.order_status}</td>
              <td>
                <button onClick={() => handleViewItems(order.payment_id)}>
                  View Items
                </button>
              </td>
              <td>
                {order.order_status === 'Your Order Sent Successfully!' && (
                  <button onClick={() => handleUpdateStatus(order.payment_id)}>
                    Mark as Being Prepared
                  </button>
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      {/* Modal */}
      {showItemsModal && (
        <div style={{
          position: 'fixed', top: 0, left: 0, width: '100%',
          height: '100%', backgroundColor: 'rgba(0,0,0,0.5)',
          display: 'flex', justifyContent: 'center', alignItems: 'center'
        }}>
          <div style={{
            background: 'white', padding: '20px', borderRadius: '8px',
            maxHeight: '80%', overflowY: 'auto', minWidth: '300px'
          }}>
            <h3>Order Items</h3>
            <button onClick={() => setShowItemsModal(false)} style={{ marginBottom: '10px' }}>
              Close
            </button>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '15px' }}>
              {selectedItems.map((item, index) => (
                <div key={index} style={{ textAlign: 'center' }}>
                <img
  src={item.image_url}
  alt="Product"
  width="100"
  style={{ borderRadius: '8px', border: '1px solid #ccc' }}
/>

                  <div>Quantity: {item.quantity}</div>
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
