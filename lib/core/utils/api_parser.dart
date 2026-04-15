import '../errors/app_exception.dart';
import '../network/api_response.dart';

List<Map<String, dynamic>> parseItemList(dynamic raw) {
  final json = raw as Map<String, dynamic>;
  final wrapped = json.containsKey('isSuccess') || json.containsKey('data');
  final response = wrapped ? ApiResponse.fromJson(json) : null;

  if (response != null && !response.isSuccess) {
    throw AppException(response.message ?? 'Yeu cau that bai.');
  }

  final data = response?.data ?? json['data'] ?? json;
  if (data is List) {
    return data.whereType<Map<String, dynamic>>().toList();
  }
  if (data is Map<String, dynamic>) {
    final collections = <dynamic>[data['content'], data['items'], data['data']];
    for (final collection in collections) {
      if (collection is List) {
        return collection.whereType<Map<String, dynamic>>().toList();
      }
    }
  }
  return [];
}

Map<String, dynamic> parseItem(dynamic raw) {
  final json = raw as Map<String, dynamic>;
  final wrapped = json.containsKey('isSuccess') || json.containsKey('data');
  final response = wrapped ? ApiResponse.fromJson(json) : null;

  if (response != null && !response.isSuccess) {
    throw AppException(response.message ?? 'Yeu cau that bai.');
  }

  final data = response?.data ?? json['data'] ?? json;
  if (data is Map<String, dynamic>) {
    return data;
  }

  throw const AppException('Du lieu tra ve khong dung dinh dang.');
}
