class UserModel {
  final String firstName;
  final String lastName;
  final String mobileNumber;
  final String? token;
  final String? message;

  const UserModel({
    required this.firstName,
    required this.lastName,
    required this.mobileNumber,
    this.token,
    this.message,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String _str(dynamic v) => v?.toString().trim() ?? '';

    return UserModel(
    
      firstName: _str(
        json['first_name'] ?? json['firstName'] ?? json['name_first'],
      ),
      lastName: _str(
        json['last_name'] ?? json['lastName'] ?? json['name_last'],
      ),
      mobileNumber: _str(
        json['mobile_number'] ??
            json['mobileNumber'] ??
            json['phone'] ??
            json['mobile'],
      ),
      token: json['token']?.toString(),
      message: json['message']?.toString() ?? json['error']?.toString(),
    );
  }
}
