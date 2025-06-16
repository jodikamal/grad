import React, { useState, useEffect, useMemo } from 'react';
import {
  Box,
  Typography,
  TextField,
  Button,
  List,
  ListItem,
  Paper,
  IconButton,
  CircularProgress,
  Alert,
  Snackbar
} from '@mui/material';
import SendIcon from '@mui/icons-material/Send';
import DeleteIcon from '@mui/icons-material/Delete';
import { styled } from '@mui/material/styles';
import axios from 'axios';

// Styled components
const ChatContainer = styled(Box)(({ theme }) => ({
  display: 'flex',
  height: 'calc(100vh - 64px)',
  backgroundColor: theme.palette.background.default
}));

const UsersList = styled(Box)(({ theme }) => ({
  width: 300,
  borderRight: `1px solid ${theme.palette.divider}`,
  padding: theme.spacing(2),
  backgroundColor: theme.palette.background.paper
}));

const ChatArea = styled(Box)(({ theme }) => ({
  flex: 1,
  display: 'flex',
  flexDirection: 'column',
  padding: theme.spacing(2),
  backgroundColor: theme.palette.background.default
}));

const MessageBubble = styled(Paper)(({ theme, isAdmin }) => ({
  padding: theme.spacing(2),
  marginBottom: theme.spacing(1),
  maxWidth: '70%',
  marginLeft: isAdmin ? 'auto' : 0,
  backgroundColor: isAdmin ? theme.palette.primary.light : theme.palette.grey[100],
  color: isAdmin ? theme.palette.primary.contrastText : theme.palette.text.primary
}));

const MessagesPage = () => {
  const [messages, setMessages] = useState([]);
  const [newMessage, setNewMessage] = useState('');
  const [selectedUser, setSelectedUser] = useState(null);
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });

  // Fetch messages and users
  const fetchData = async () => {
    try {
      setLoading(true);
      const [messagesRes, usersRes] = await Promise.all([
        axios.get('http://localhost:3000/admin/messages'),
        axios.get('http://localhost:3000/users')
      ]);
      setMessages(messagesRes.data);
      setUsers(usersRes.data);
      setError(null);
    } catch (err) {
      setError('Failed to fetch data. Please try again.');
      console.error('Error fetching data:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
    const interval = setInterval(fetchData, 5000);
    return () => clearInterval(interval);
  }, []);

  // Group messages by user
  const messagesByUser = useMemo(() => {
    return messages.reduce((acc, message) => {
      const userId = message.sender_id === 1 ? message.receiver_id : message.sender_id;
      if (!acc[userId]) {
        acc[userId] = [];
      }
      acc[userId].push(message);
      return acc;
    }, {});
  }, [messages]);

  // Get user name by ID
  const getUserName = (userId) => {
    const user = users.find(u => u.user_id === userId);
    return user ? user.name : 'Unknown User';
  };

  // Send message
  const handleSendMessage = async () => {
    if (!newMessage.trim() || !selectedUser) return;

    try {
      const response = await axios.post('http://localhost:3000/admin/messages/send', {
        receiver_id: selectedUser,
        content: newMessage.trim()
      });

      setMessages(prev => [...prev, response.data]);
      setNewMessage('');
      setSnackbar({
        open: true,
        message: 'Message sent successfully',
        severity: 'success'
      });
    } catch (err) {
      setSnackbar({
        open: true,
        message: 'Failed to send message',
        severity: 'error'
      });
      console.error('Error sending message:', err);
    }
  };

  // Delete message
  const handleDeleteMessage = async (messageId) => {
    try {
      await axios.delete(`http://localhost:3000/messages/${messageId}`);
      setMessages(prev => prev.filter(msg => msg.message_id !== messageId));
      setSnackbar({
        open: true,
        message: 'Message deleted successfully',
        severity: 'success'
      });
    } catch (err) {
      setSnackbar({
        open: true,
        message: 'Failed to delete message',
        severity: 'error'
      });
      console.error('Error deleting message:', err);
    }
  };

  // Mark messages as read
  const markMessagesAsRead = async (userId) => {
    try {
      await axios.post('http://localhost:3000/messages/mark-read', {
        user_id: 1,
        sender_id: userId
      });
    } catch (err) {
      console.error('Error marking messages as read:', err);
    }
  };

  const handleSnackbarClose = () => {
    setSnackbar(prev => ({ ...prev, open: false }));
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" height="100vh">
        <CircularProgress />
      </Box>
    );
  }

  if (error) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" height="100vh">
        <Alert severity="error">{error}</Alert>
      </Box>
    );
  }

  return (
    <ChatContainer>
      <UsersList>
        <Typography variant="h6" sx={{ mb: 2 }}>Users</Typography>
        <List>
          {users.map(user => (
            <ListItem
              key={user.user_id}
              button
              selected={selectedUser === user.user_id}
              onClick={() => {
                setSelectedUser(user.user_id);
                markMessagesAsRead(user.user_id);
              }}
            >
              <Typography>{user.name}</Typography>
            </ListItem>
          ))}
        </List>
      </UsersList>

      <ChatArea>
        {selectedUser ? (
          <>
            <Typography variant="h6" sx={{ mb: 2 }}>
              Chat with {getUserName(selectedUser)}
            </Typography>
            <Box sx={{ flex: 1, overflow: 'auto', mb: 2 }}>
              {messagesByUser[selectedUser]?.map(message => (
                <MessageBubble
                  key={message.message_id}
                  isAdmin={message.sender_id === 1}
                >
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <Typography variant="body1">{message.content}</Typography>
                    <IconButton
                      size="small"
                      onClick={() => handleDeleteMessage(message.message_id)}
                    >
                      <DeleteIcon />
                    </IconButton>
                  </Box>
                  <Typography variant="caption" color="text.secondary">
                    {new Date(message.timestamp).toLocaleString()}
                  </Typography>
                </MessageBubble>
              ))}
            </Box>
            <Box sx={{ display: 'flex', gap: 1 }}>
              <TextField
                fullWidth
                value={newMessage}
                onChange={(e) => setNewMessage(e.target.value)}
                placeholder="Type a message..."
                onKeyPress={(e) => e.key === 'Enter' && handleSendMessage()}
                variant="outlined"
                size="small"
              />
              <Button
                variant="contained"
                endIcon={<SendIcon />}
                onClick={handleSendMessage}
                disabled={!newMessage.trim()}
              >
                Send
              </Button>
            </Box>
          </>
        ) : (
          <Typography variant="body1" sx={{ textAlign: 'center', mt: 4 }}>
            Select a user to start chatting
          </Typography>
        )}
      </ChatArea>

      <Snackbar
        open={snackbar.open}
        autoHideDuration={6000}
        onClose={handleSnackbarClose}
        anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
      >
        <Alert onClose={handleSnackbarClose} severity={snackbar.severity}>
          {snackbar.message}
        </Alert>
      </Snackbar>
    </ChatContainer>
  );
};

export default MessagesPage;
