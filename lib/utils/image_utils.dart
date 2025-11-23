class ImageUtils {
  static String getCompatibleImageUrl(String url) {
    if (url.contains('fmt=avif')) {
      return url.replaceAll('fmt=avif', 'fmt=jpg');
    }
    return url;
  }
}
