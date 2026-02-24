class UserModel {
  final String uid;
  final String fullName;
  final String email;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
  });

  factory UserModel.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      return UserModel(
        uid: documentId,
        fullName: 'Unknown',
        email: 'Unknown',
      );
    }
    return UserModel(
      uid: documentId,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
    };
  }
}
