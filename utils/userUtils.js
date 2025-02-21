const { db } = require('../config/firebaseConfig'); // Updated path
const admin = require('firebase-admin');

async function addUserToFirestore(user) {
  try {
    if (!user.id || typeof user.id !== 'string' || user.id.trim() === '') {
      throw new Error('Invalid user ID');
    }

    const userRef = db.collection('users').doc(user.id);
    await userRef.set(user);
    console.log('User successfully added!');
  } catch (error) {
    console.error('Error adding user: ', error);
  }
}

// Example user data
const newUser = {
  id: 'unique-user-id', // Ensure this is a valid, non-empty string
  name: 'John Doe',
  email: 'john.doe@example.com',
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
  profilePictureUrl: 'https://example.com/profile.jpg', // Optional
  friends: [] // Optional
};

// Call the function to add a user
addUserToFirestore(newUser); 