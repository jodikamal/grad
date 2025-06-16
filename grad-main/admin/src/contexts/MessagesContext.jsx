import React, { createContext, useContext, useState, useCallback } from 'react';
import { messagesService } from '../services/messagesService';

const MessagesContext = createContext();

export const useMessages = () => {
  const context = useContext(MessagesContext);
  if (!context) {
    throw new Error('useMessages must be used within a MessagesProvider');
  }
  return context;
};

export const MessagesProvider = ({ children }) => {
  const [messages, setMessages] = useState([]);
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const fetchMessages = useCallback(async () => {
    try {
      setLoading(true);
      const [messagesData, usersData] = await Promise.all([
        messagesService.getAllMessages(),
        messagesService.getAllUsers()
      ]);
      setMessages(messagesData);
      setUsers(usersData);
      setError(null);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, []);

  const sendMessage = useCallback(async (receiverId, content) => {
    try {
      const newMessage = await messagesService.sendMessage(receiverId, content);
      setMessages(prev => [...prev, newMessage]);
      return newMessage;
    } catch (err) {
      setError(err.message);
      throw err;
    }
  }, []);

  const deleteMessage = useCallback(async (messageId) => {
    try {
      await messagesService.deleteMessage(messageId);
      setMessages(prev => prev.filter(msg => msg.message_id !== messageId));
    } catch (err) {
      setError(err.message);
      throw err;
    }
  }, []);

  const markMessagesAsRead = useCallback(async (userId) => {
    try {
      await messagesService.markMessagesAsRead(userId);
    } catch (err) {
      setError(err.message);
      throw err;
    }
  }, []);

  const value = {
    messages,
    users,
    loading,
    error,
    fetchMessages,
    sendMessage,
    deleteMessage,
    markMessagesAsRead
  };

  return (
    <MessagesContext.Provider value={value}>
      {children}
    </MessagesContext.Provider>
  );
}; 