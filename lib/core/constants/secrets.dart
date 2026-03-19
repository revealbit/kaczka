class Secrets {
  Secrets._();

  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String osmTileUrl = String.fromEnvironment('OSM_TILE_URL');
  static const String osmUserAgent = String.fromEnvironment('OSM_USER_AGENT');
}
