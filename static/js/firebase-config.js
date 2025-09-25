// Firebase設定
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyCE7c5SJhVfX1rUm-DxLF8lcwX5v1nqCvk",
  authDomain: "blog-qli-jp-handsclap.firebaseapp.com",
  databaseURL: "https://blog-qli-jp-handsclap-default-rtdb.asia-southeast1.firebasedatabase.app",
  projectId: "blog-qli-jp-handsclap",
  storageBucket: "blog-qli-jp-handsclap.firebasestorage.app",
  messagingSenderId: "120440849708",
  appId: "1:120440849708:web:9ea74c4fb2d72549581889",
  measurementId: "G-4HX7KM00NB"
};

// Firebase初期化
import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js';
import { getDatabase } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-database.js';

const app = initializeApp(firebaseConfig);
const database = getDatabase(app);

window.firebaseDatabase = database;