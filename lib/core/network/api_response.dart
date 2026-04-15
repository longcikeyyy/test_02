class ApiResponse<T> {
  const ApiResponse({
    required this.isSuccess,
    required this.message,
    required this.data,
  });

  final bool isSuccess;
  final String? message;
  final T? data;

  static ApiResponse<dynamic> fromJson(Map<String, dynamic> json) {
    return ApiResponse<dynamic>(
      isSuccess: json['isSuccess'] == true,
      message: json['message'] as String?,
      data: json['data'],
    );
  }
}
