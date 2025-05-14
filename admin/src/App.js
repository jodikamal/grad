import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import AdminLogin from './pages/AdminLogin';
import AdminDashboard from './pages/AdminDashboard';
import AddProductPage from './pages/AddProductPage'; // استيراد صفحة إضافة المنتج

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<AdminLogin />} />
        <Route path="/admin/dashboard" element={<AdminDashboard />} />
        <Route path="/admin/add-product" element={<AddProductPage />} /> {/* إضافة مسار جديد */}
      </Routes>
    </Router>
  );
}

export default App;
