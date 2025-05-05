class UserModel {
  final String username;
  final String email;
  final String uid;

  UserModel({required this.username, required this.email, required this.uid});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      email: json['email'],
      uid: json['uid'],
    );
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'uid': uid,
  };
}
