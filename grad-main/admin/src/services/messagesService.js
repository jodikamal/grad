import axios from 'axios';

const API_URL = 'http://localhost:3000';

export const messagesService = {
  // Get all messages for admin
  getAllMessages: async () => {
    try {
      const response = await axios.get(`${API_URL}/admin/messages`);
      return response.data;
    } catch (error) {
      throw new Error('Failed to fetch messages');
    }
  },

  // Get all users
  getAllUsers: async () => {
    try {
      const response = await axios.get(`${API_URL}/users`);
      return response.data;
    } catch (error) {
      throw new Error('Failed to fetch users');
    }
  },

  // Send a message
  sendMessage: async (receiverId, content) => {
    try {
      const response = await axios.post(`${API_URL}/admin/messages/send`, {
        receiver_id: receiverId,
        content
      });
      return response.data;
    } catch (error) {
      throw new Error('Failed to send message');
    }
  },

  // Delete a message
  deleteMessage: async (messageId) => {
    try {
      await axios.delete(`${API_URL}/messages/${messageId}`);
      return true;
    } catch (error) {
      throw new Error('Failed to delete message');
    }
  },

  // Mark messages as read
  markMessagesAsRead: async (userId) => {
    try {
      await axios.post(`${API_URL}/messages/mark-read`, {
        user_id: 1,
        sender_id: userId
      });
      return true;
    } catch (error) {
      throw new Error('Failed to mark messages as read');
    }
  }
}; 