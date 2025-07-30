// src/firebase.js

import { initializeApp } from "firebase/app";

const firebaseConfig = {
  apiKey: "AIzaSyClausu1umd7XMICMom6cl--DvRr6DyMjE", 
  authDomain: "task-management-app-2e66e.firebaseapp.com",
  projectId: "task-management-app-2e66e",
  storageBucket: "task-management-app-2e66e.appspot.com",
  messagingSenderId: "89542425380",
  appId: "1:89542425380:android:ea7adc58171a8a744e51b1" 
};

const app = initializeApp(firebaseConfig);

export default app;
