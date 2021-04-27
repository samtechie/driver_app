const express = require('express');
const bodyParser = require('body-parser');
const handlers = require('./httpHandlers');
const db = require('./db');
const cors = require('cors');

const app = express();

app.use(bodyParser.json());
app.use(cors());
app.set('db', db);

app.get('/packages', handlers.getPackages);
app.get('/drivers', handlers.getDrivers);
app.post('/packages/:packageId/assign_driver', handlers.assignDriver);
app.post('/packages/:packageId/unassign_driver', handlers.unassignDriver);

app.get('/drivers', handlers.getDrivers);

app.listen(9090, () => console.log('Server started at 9090'));
