import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import AdminDashboard from './pages/AdminDashboard';
import AddProductPage from './pages/AddProductPage';
import { Box } from '@mui/material';

function App() {
  return (
    <Router>
      <Box sx={{ p: 3 }}>
        <Routes>
          <Route path="/admin/dashboard" element={<AdminDashboard />} />
          <Route path="/admin/add-product" element={<AddProductPage />} />
        </Routes>
      </Box>
    </Router>
  );
}

export default App;
