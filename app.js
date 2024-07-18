const express = require('express');
const app = express();
const port = 3000;

app.use(express.json());

// Sample endpoint
app.get('/', (req, res) => {
  res.send('Hello, Node.js 20!');
});

// Another sample endpoint
app.get('/api/sample', (req, res) => {
  res.json({ message: 'This is a sample API endpoint.' });
});

// Endpoint to create a resource
app.post('/api/resource', (req, res) => {
  const resource = req.body;
  res.status(201).json({ message: 'Resource created!', resource });
});

app.listen(port, () => {
  console.log(`App is running at http://localhost:${port}`);
});
