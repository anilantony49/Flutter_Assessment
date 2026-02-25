import 'package:firebase_auth/firebase_auth.dart';

class ErrorHandler {
  static String getMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found for that email address.';
        case 'wrong-password':
          return 'Wrong password provided for that user.';
        case 'invalid-credential':
          return 'Invalid email or password.';
        case 'email-already-in-use':
          return 'The account already exists for that email.';
        case 'invalid-email':
          return 'The email address is improperly formatted.';
        case 'weak-password':
          return 'The password is too weak.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'too-many-requests':
          return 'Too many login attempts. Please try again later.';
        case 'network-request-failed':
          return 'Please check your internet connection.';
        default:
          return error.message ??
              'An unexpected authentication error occurred.';
      }
    } else if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'You do not have permission to perform this action.';
        case 'unavailable':
          return 'The service is currently unavailable. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        default:
          return error.message ?? 'A database error occurred.';
      }
    }

    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }

    return 'An unexpected error occurred. Please try again.';
  }
}
