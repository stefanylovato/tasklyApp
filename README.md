# taskly

Taskly is a task management mobile application built with Flutter, Firebase, and the BLoC pattern. It allows users to create, manage, and categorize tasks with features like authentication, task filtering, and media uploads. This project is developed as part of a coding challenge.

## Target Platform
This application is designed and tested for **iOS**. It has been developed and run successfully on the iOS Simulator (iPhone 16) using Flutter.

## Prerequisites
To run this project, ensure you have the following installed:

- Flutter: Version 3.22.2 or higher (stable channel)
- Dart: Version 3.4.3 or higher
- Xcode: Version 15.0 or higher (for iOS builds)
- Firebase CLI: Optional, for setting up your own Firebase project
- A macOS environment for iOS development
- Git (to clone the repository)

## Setup Instructions
1. Clone the Repository
Clone the project from GitHub:
```bash
git clone https://github.com/your-username/taskly.git
cd taskly
```

2. Add Firebase Configuration Files
The Firebase configuration files (lib/firebase_options.dart and ios/Runner/GoogleService-Info.plist) contain sensitive information and are not included in the repository. These files have been sent via email to the evaluators.

- Place the Files:
    - Copy firebase_options.dart to lib/.
    - Copy GoogleService-Info.plist to ios/Runner/.


Alternatively, if you prefer to set up your own Firebase project:

Create a Firebase project in the Firebase Console.
Add an iOS app to the project (bundle ID: com.example.taskly).
Download GoogleService-Info.plist and place it in ios/Runner/.
Run the following command to generate firebase_options.dart:
```bash
flutterfire configure
```
Enable Firebase Authentication (Email/Password) and Firestore in the Firebase Console.

3. Install Dependencies
Install the required Flutter packages:
flutter pub get

4. Run the Application
Build and run the app on an iOS simulator:
```bash
flutter run
```

Ensure an iOS simulator (e.g., iPhone 16) is selected in Xcode.
If you encounter build issues, run flutter clean and flutter pub get again.

5. Testing the Application

- Authentication: Sign up or log in using the email/password authentication flow.
- Task Management: Create, edit, delete, and filter tasks in the home screen.
- Category Management: Add and manage task categories via the "Manage Categories" option.
- Media Uploads: Upload media files to tasks (stored in Firebase Storage).

## Project Structure

- lib/core/: Router configuration (router.dart).
- lib/features/auth/: Authentication logic (BLoC, repository, use cases).
- lib/features/tasks/: Task and category management (BLoC, repository, use cases, entities).
- lib/firebase_options.dart: Firebase configuration (sent via email).
- ios/Runner/GoogleService-Info.plist: iOS Firebase configuration (sent via email).

## Dependencies
Key dependencies used in the project:

- flutter_bloc: ^8.1.1 - State management
- firebase_core: ^2.15.0 - Firebase integration
- firebase_auth: ^4.7.0 - Authentication
- cloud_firestore: ^4.8.0 - Firestore database
- firebase_storage: ^11.2.0 - Media uploads
- go_router: ^10.0.0 - Navigation
- equatable: ^2.0.5 - Value equality

### Notes

The application is optimized for iOS. Android support may require additional configuration (e.g., adding google-services.json for Android).
Ensure a stable internet connection for Firebase services.
If you encounter issues, run flutter run --verbose to capture detailed logs and contact the developer for assistance.

## Contact
For any questions or issues, please contact [stefany.s.lovatol@gmail.com].