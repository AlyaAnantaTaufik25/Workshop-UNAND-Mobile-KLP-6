/// Model pembungkus respon standar REST API backend UNAND
/// Mengikuti format:
/// Sukses: { "success": true, "message": "...", "data": <object|array|null> }
/// Gagal:  { "success": false, "message": "...", "errors": [ ... ] }
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final List<String> errors;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors = const [],
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic rawData)? fromDataJson,
  ) {
    final rawErrors = json['errors'];
    final List<String> parsedErrors = [];

    if (rawErrors is List) {
      for (final item in rawErrors) {
        if (item != null) {
          parsedErrors.add(item.toString());
        }
      }
    } else if (rawErrors != null) {
      parsedErrors.add(rawErrors.toString());
    }

    final rawData = json['data'];
    T? parsedData;
    if (rawData != null && fromDataJson != null) {
      parsedData = fromDataJson(rawData);
    } else if (rawData is T) {
      parsedData = rawData;
    }

    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: parsedData,
      errors: parsedErrors,
    );
  }
}

