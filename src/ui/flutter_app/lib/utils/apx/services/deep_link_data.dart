/// Data class to hold deep link information
class DeepLinkData {
  /// The path from the deep link
  final String path;

  /// Query parameters from the deep link
  final Map<String, String> queryParams;

  DeepLinkData({required this.path, required this.queryParams});
}
