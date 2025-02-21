const express = require('express');
const { addUserToFirestore } = require('./config/firebaseConfig');
const app = express();

app.use(express.json());

app.post('/addUser', async (req, res) => {
  try {
    const user = req.body;
    await addUserToFirestore(user);
    res.status(200).send('User successfully added!');
  } catch (error) {
    res.status(500).send('Error adding user: ' + error.message);
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
}); 