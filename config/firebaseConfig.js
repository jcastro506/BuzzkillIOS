require('dotenv').config();
const admin = require('firebase-admin');
const serviceAccount = require(process.env.FIREBASE_SERVICE_ACCOUNT_KEY_PATH);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

module.exports = { admin, db };

// Add any unique code from the other file here

async function testFirestoreConnection() {
  try {
    const docRef = db.collection('testCollection').doc('testDocument');
    await docRef.set({
      testField: 'Hello, Firestore!'
    });
    console.log('Document successfully written!');
  } catch (error) {
    console.error('Error writing document: ', error);
  }
}

async function addUserToFirestore(user) {
  try {
    const userRef = db.collection('users').doc(user.id);
    await userRef.set({
      email: user.email || '',
      user_name: user.name || '',
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      friends: user.friends || [],
      total_amount_spent: user.totalAmountSpent || 0,
      total_budgets_set: user.totalBudgetsSet || 0
    });
    console.log('User successfully added!');
  } catch (error) {
    console.error('Error adding user: ', error);
  }
}

async function fetchUserBudgets(userId) {
  try {
    const budgetsRef = db.collection('budgets').where('userId', '==', userId);
    const snapshot = await budgetsRef.get();

    if (snapshot.empty) {
      console.log('No matching documents.');
      return [];
    }

    const budgets = [];
    snapshot.forEach(doc => {
      budgets.push({ id: doc.id, ...doc.data() });
    });

    console.log('Budgets fetched successfully:', budgets);
    return budgets;
  } catch (error) {
    console.error('Error fetching budgets: ', error);
    return [];
  }
}

testFirestoreConnection(); 