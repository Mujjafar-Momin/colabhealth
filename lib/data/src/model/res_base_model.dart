class ResBaseModel<T> {
  final bool success;
  final int statusCode;
  final String? message;
  final String? error;
  final T? data;

  const ResBaseModel({
    required this.success,
    required this.statusCode,
    this.message,
    this.error,
    this.data,
  });

  factory ResBaseModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJson,
  ) {
    return ResBaseModel<T>(
      success: json['success'] ?? false,
      statusCode: json['statusCode'] ?? 0,
      message: json['message'],
      error: json['error'],
      data: json['data'] != null
          ? (fromJson != null ? fromJson(json['data']) : json['data'] as T)
          : null,
    );
  }

  ResBaseModel<T> copyWith({bool? success, T? data, String? error}) => ResBaseModel<T>(
        success: success ?? this.success,
        statusCode: statusCode,
        message: message,
        error: error ?? this.error,
        data: data ?? this.data,
      );

  @override
  String toString() =>
      'ResBaseModel(success: $success, statusCode: $statusCode, message: $message, error: $error, data: $data)';
}
