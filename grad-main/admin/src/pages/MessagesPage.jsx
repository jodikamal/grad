import React, { useState, useEffect, useRef } from 'react';
import axios from 'axios';
import './MessagesPage.css';

function MessagesPage() {
  const [messages, setMessages] = useState([]);
  const [newMessage, setNewMessage] = useState('');
  const [selectedUserId, setSelectedUserId] = useState(null);
  const [users, setUsers] = useState([]);
  const [adminId, setAdminId] = useState(null);
  const messagesEndRef = useRef(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    // Get admin info from localStorage
    const adminData = JSON.parse(localStorage.getItem('adminData') || '{}');
    setAdminId(adminData.user_id);
    
    fetchMessages();
    const interval = setInterval(fetchMessages, 5000); // Poll for new messages every 5 seconds
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const fetchMessages = async () => {
    try {
      const response = await axios.get('http://localhost:3000/admin/messages');
      setMessages(response.data);

      // Extract unique users from messages
      const uniqueUsers = [
        ...new Map(
          response.data
            .filter((msg) => !msg.is_admin)
            .map((msg) => [msg.sender_id, { id: msg.sender_id, name: msg.sender_name }])
        ).values(),
      ];
      setUsers(uniqueUsers);
    } catch (error) {
      console.error('Error fetching messages:', error);
    }
  };

  const handleSendMessage = async (e) => {
    e.preventDefault();
    if (!newMessage.trim() || !selectedUserId || !adminId) return;

    try {
      await axios.post('http://localhost:3000/messages/send', {
        sender_id: adminId,
        receiver_id: selectedUserId,
        content: newMessage,
        is_admin: true,
        sender_name: 'Admin',
      });

      setNewMessage('');
      fetchMessages();
    } catch (error) {
      console.error('Error sending message:', error);
    }
  };

  const formatTimestamp = (timestamp) => {
    const date = new Date(timestamp);
    return `${date.toLocaleDateString()} ${date.toLocaleTimeString()}`;
  };

  // Filter messages for the selected user conversation
  const filteredMessages = selectedUserId
    ? messages.filter(
        (msg) =>
          (msg.sender_id === selectedUserId && msg.receiver_id === adminId) ||
          (msg.sender_id === adminId && msg.receiver_id === selectedUserId)
      )
    : [];

  return (
    <div className="messages-container">
      <div className="users-list">
        <h2>Users</h2>
        {users.map((user) => (
          <div
            key={user.id}
            className={`user-item ${selectedUserId === user.id ? 'selected' : ''}`}
            onClick={() => setSelectedUserId(user.id)}
          >
            {user.name || `User ${user.id}`}
          </div>
        ))}
      </div>

      <div className="chat-container">
        {selectedUserId ? (
          <>
            <div className="selected-user-header">
              <h3>Chat with: {users.find(u => u.id === selectedUserId)?.name || `User ${selectedUserId}`}</h3>
            </div>
            <div className="messages-list">
              {filteredMessages.map((message, index) => (
                <div
                  key={index}
                  className={`message ${message.is_admin ? 'admin' : 'user'}`}
                >
                  <div className="message-content">
                    <strong>
                      {message.sender_name ||
                        (message.is_admin
                          ? 'Admin'
                          : `User ${message.sender_id}`)}
                    </strong>
                    <p>{message.content}</p>
                    <small>{formatTimestamp(message.timestamp)}</small>
                  </div>
                </div>
              ))}
              <div ref={messagesEndRef} />
            </div>

            <form onSubmit={handleSendMessage} className="message-input">
              <input
                type="text"
                value={newMessage}
                onChange={(e) => setNewMessage(e.target.value)}
                placeholder="Type a message..."
              />
              <button type="submit">Send</button>
            </form>
          </>
        ) : (
          <div className="no-chat-selected">
            <p>Select a user to start chatting</p>
          </div>
        )}
      </div>
    </div>
  );
}

export default MessagesPage;
