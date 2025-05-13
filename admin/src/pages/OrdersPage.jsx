import React, { useEffect, useState } from 'react';
import axios from 'axios';

const OrdersPage = () => {
  const [orders, setOrders] = useState([]);

  useEffect(() => {
    axios.get('http://localhost:3000/admin/orders')
      .then(res => setOrders(res.data))
      .catch(err => console.error('Error fetching orders', err));
  }, []);

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
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default OrdersPage;
