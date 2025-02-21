# Project Architecture

This document provides an overview of the project's architecture.

![Architecture Diagram](./architecture-diagram.png)

## Components

- **Firebase Admin SDK**: Used for server-side operations with Firebase.
- **Firestore**: The database used for storing and retrieving data.
- **Server**: The backend server handling requests and interfacing with Firebase.

## Description

The architecture consists of a Node.js server that uses the Firebase Admin SDK to interact with Firestore. The server is responsible for handling client requests, performing operations on the database, and returning responses. 