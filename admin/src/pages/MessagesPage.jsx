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

// Styled components
const ChatContainer = styled(Box)(({ theme }) => ({
  display: 'flex',
  height: 'calc(100vh - 64px)',
  backgroundColor: '#f4f5fa',
  fontFamily: 'Segoe UI, sans-serif',
}));

const UsersList = styled(Box)(({ theme }) => ({
  width: 300,
  borderRight: `1px solid ${theme.palette.divider}`,
  padding: theme.spacing(2),
  backgroundColor: '#ffffff',
  boxShadow: '2px 0 5px rgba(0,0,0,0.03)',
}));

const ChatArea = styled(Box)(({ theme }) => ({
  flex: 1,
  display: 'flex',
  flexDirection: 'column',
  backgroundColor: '#fcfcfc',
  borderLeft: `1px solid ${theme.palette.divider}`,
}));

const MessageBubble = styled(Paper)(({ theme, isAdmin }) => ({
  padding: theme.spacing(1.5),
  marginBottom: theme.spacing(2),
  maxWidth: '65%',
  borderRadius: 12,
  marginLeft: isAdmin ? 'auto' : 0,
  marginRight: isAdmin ? 0 : 'auto',
  backgroundColor: isAdmin ? '#e3e0ff' : '#f0f0f0',
  boxShadow: '0 2px 8px rgba(0,0,0,0.05)',
  color: '#333',
}));

const MessageHeader = styled(Typography)(({ theme }) => ({
  fontSize: '0.8rem',
  fontWeight: 600,
  marginBottom: 4,
  color: theme.palette.primary.main,
}));

const MessageTimestamp = styled(Typography)(({ theme }) => ({
  fontSize: '0.7rem',
  color: '#888',
  marginTop: 6,
}));

const MessageInputContainer = styled(Box)(({ theme }) => ({
  display: 'flex',
  padding: theme.spacing(2),
  borderTop: `1px solid ${theme.palette.divider}`,
  backgroundColor: '#ffffff',
}));

const ChatHeader = styled(Box)(({ theme }) => ({
  padding: theme.spacing(2),
  borderBottom: `1px solid ${theme.palette.divider}`,
  backgroundColor: '#ffffff',
  boxShadow: '0px 1px 4px rgba(0, 0, 0, 0.03)',
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
      const userId = message.sender_id === 16 ? message.receiver_id : message.sender_id;
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
      <ChatHeader>
        <Typography variant="h6">
          Chat with {getUserName(selectedUser)}
        </Typography>
      </ChatHeader>

      <Box sx={{ flex: 1, overflowY: 'auto', padding: 2 }}>
        {messagesByUser[selectedUser]?.map(message => (
          <MessageBubble key={message.message_id} isAdmin={message.sender_id === 16}>
            <MessageHeader>
              {message.sender_id === 16 ? 'Admin' : message.sender_name}
            </MessageHeader>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <Typography variant="body1">{message.content}</Typography>
              <IconButton
                size="small"
                onClick={() => handleDeleteMessage(message.message_id)}
              >
                <DeleteIcon fontSize="small" />
              </IconButton>
            </Box>
            <MessageTimestamp>
              {new Date(message.timestamp).toLocaleString()}
            </MessageTimestamp>
          </MessageBubble>
        ))}
      </Box>

      <MessageInputContainer>
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
          sx={{ marginLeft: 1 }}
        >
          Send
        </Button>
      </MessageInputContainer>
    </>
  ) : (
    <Box sx={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      <Typography variant="body1" color="text.secondary">
        Select a user to start chatting
      </Typography>
    </Box>
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
