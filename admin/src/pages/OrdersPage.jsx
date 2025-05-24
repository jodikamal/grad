import React, { useEffect, useState } from 'react';
import axios from 'axios';

const OrdersPage = () => {
  const [orders, setOrders] = useState([]);

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
        fetchOrders(); // Refresh the table
      })
      .catch(err => {
        console.error('Error updating order status', err);
        alert('Failed to update status.');
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
            <th>Action</th>
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
    </div>
  );
};

export default OrdersPage;
