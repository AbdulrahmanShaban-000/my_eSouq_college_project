import 'package:zad/core/api/end_points.dart';

class ErrorModel {
  final String errorMessage;
  final int? statusCode;
  ErrorModel({required this.errorMessage, this.statusCode});
  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    return ErrorModel(
      errorMessage: json[ApiKeys.errors] ?? 'An error occurred',
      statusCode: json[ApiKeys.statusCode] != null ? int.tryParse(json[ApiKeys.statusCode].toString()) : null,
    );
  }
}