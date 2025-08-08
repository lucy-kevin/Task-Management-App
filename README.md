# Task Management App

A cross-platform task management application with a Flutter mobile app and a React web dashboard, powered by Firebase backend services.

---

## Overview

This project consists of two main components:

* **Mobile App:** Built with Flutter, allowing users to create, update, and manage their tasks on Android and iOS devices.
* **Dashboard:** Built with React, providing an administrative interface to monitor and manage tasks, users, and analytics.
* **Backend:** Firebase services (Authentication, Firestore Database, Cloud Functions) handle user authentication, data storage, and real-time synchronization.

---

## Features

### Mobile App (Flutter)

* User authentication (sign up, login, logout) via Firebase Auth
* Create, edit, delete tasks
* Mark tasks as completed or pending
* Real-time task updates using Firestore streams
* Notifications/reminders (optional - if implemented)
* Responsive UI for both Android and iOS

### Dashboard (React)

* Admin login and authentication
* View all users and their tasks
* Task analytics and filtering
* Manage user roles (optional)
* Responsive design for desktops and tablets

---

## Technologies Used

* **Flutter** - Cross-platform mobile app development
* **React** - Frontend dashboard web application
* **Firebase Authentication** - User login and management
* **Cloud Firestore** - Real-time database for task storage
* **Firebase Cloud Functions** (optional) - Backend logic and triggers
* **Firebase Hosting** (optional) - Hosting for the React dashboard

---

## Getting Started

### Prerequisites

* Flutter SDK installed ([Flutter install guide](https://flutter.dev/docs/get-started/install))
* Node.js and npm/yarn installed for React
* Firebase project set up with Authentication and Firestore enabled
* Android Studio/Xcode (for running Flutter apps)

### Setup for Mobile App

1. Clone the repo:

   ```bash
   git clone https://github.com/lucy-kevin/Task-Management-App.git
   cd task-management-app/mobile_app
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Configure Firebase:

   * Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) from your Firebase project.
   * Place them in the appropriate platform directories (`android/app` and `ios/Runner`).

4. Run the app:

   ```bash
   flutter run
   ```

---

### Setup for Dashboard

1. Navigate to the dashboard folder:

   ```bash
   cd ../dashboard
   ```

2. Install dependencies:

   ```bash
   npm install
   # or
   yarn install
   ```

3. Configure Firebase:

   * Create a `.env` file or configure Firebase config in your React app.
   * Add Firebase API keys and project identifiers.

4. Start the development server:

   ```bash
   npm start
   # or
   yarn start
   ```

---

## Folder Structure

```
/mobile_app       # Flutter app source code
/dashboard        # React dashboard source code
/firebase        # Firebase Cloud Functions (if applicable)
README.md        # This file
```

---

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for bug fixes or feature requests.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Contact

For questions or support, please contact:

* Your Name - [your.email@example.com](mailto:your.email@example.com)
* GitHub: [yourusername](https://github.com/yourusername)

---

If you want, I can help you customize it further or add specific sections like screenshots, API documentation, or deployment instructions!


- Admin email admin@example.com
- Admin password: 123456


<img width="1912" height="889" alt="Screenshot 2025-07-31 113218" src="https://github.com/user-attachments/assets/8b4982f8-f1a3-47f2-b6e6-095fd4012833" />

<img width="1890" height="884" alt="Screenshot 2025-07-31 113455" src="https://github.com/user-attachments/assets/a18d00f0-d7b0-4ce7-8590-679ca24060e3" />
<img width="1889" height="894" alt="Screenshot 2025-07-31 114039" src="https://github.com/user-attachments/assets/1d82392e-2018-4590-924b-71c99f35c4b5" />
<img width="1890" height="890" alt="Screenshot 2025-07-31 114013" src="https://github.com/user-attachments/assets/6a09ad61-c798-4c32-9c32-63e79a2d2470" />
