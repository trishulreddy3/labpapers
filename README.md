# Question Papers App 📚

A modern Flutter application for sharing and accessing question papers for students. Built with Firebase and Cloudinary integration.

## Features ✨

- **User Authentication**: Secure login and registration with Firebase Auth
- **Paper Upload**: Upload question papers with filtering options
- **Advanced Search**: Filter papers by college, year, branch, and exam type
- **My Papers**: View all papers uploaded by you
- **Rating System**: Rate papers and see download counts
- **Modern UI**: Beautiful animations and Material Design 3
- **Cloud Storage**: Secure file storage with Cloudinary

## Setup Instructions 🚀

### 1. Prerequisites

- Flutter SDK (>=3.5.3)
- Dart SDK
- Firebase account
- Cloudinary account

### 2. Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication (Email/Password)
3. Create a Firestore database
4. Add your app to the project
5. Download `google-services.json` (Android) or `GoogleService-Info.plist` (iOS)
6. Place the files in the appropriate directories:
   - Android: `android/app/`
   - iOS: `ios/Runner/`

### 3. Cloudinary Setup

1. Create a Cloudinary account at [Cloudinary](https://cloudinary.com/)
2. Get your Cloud Name and API credentials
3. Update the Cloudinary configuration in `lib/services/cloudinary_service.dart`:
   ```dart
   static const String cloudName = 'YOUR_CLOUD_NAME';
   static const String uploadPreset = 'YOUR_UPLOAD_PRESET';
   ```

### 4. Install Dependencies

```bash
cd papers
flutter pub get
```

### 5. Run the App

```bash
flutter run
```

## App Structure 📁

```
lib/
├── models/
│   └── paper_model.dart
├── providers/
│   ├── auth_provider.dart
│   └── paper_provider.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── all_papers/
│   │   └── all_papers_screen.dart
│   ├── my_papers/
│   │   └── my_papers_screen.dart
│   ├── upload/
│   │   └── upload_screen.dart
│   ├── search/
│   │   └── search_screen.dart
│   └── profile/
│       └── profile_screen.dart
├── services/
│   ├── firebase_service.dart
│   └── cloudinary_service.dart
└── widgets/
    └── paper_card.dart
```

## Filter Options 🎯

The app supports filtering papers by:

- **College**: Name of the college
- **Year**: 1st, 2nd, 3rd, or 4th year
- **Branch**: AI, AIML, EEE, ECE, Civil, Mech
- **Examination Type**: Mid 1, Mid 2, or Semester

## Technologies Used 🛠️

- Flutter
- Firebase (Auth, Firestore)
- Cloudinary
- Provider (State Management)
- Google Fonts
- Flutter Animate
- File Picker

## Contributing 🤝

Contributions are welcome! Please feel free to submit a Pull Request.

## License 📄

This project is open source and available under the MIT License.

## Support 💬

For support, email garena114q@gmail.com or create an issue in the repository.
