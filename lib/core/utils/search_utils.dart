/// Normalizes a string for search comparison: lowercase + strip diacritics.
///
/// Covers Czech, Slovak, and common Western European accented characters.
String normalizeSearch(String input) {
  final lower = input.toLowerCase();
  final buffer = StringBuffer();
  for (var i = 0; i < lower.length; i++) {
    buffer.write(_charMap[lower[i]] ?? lower[i]);
  }
  return buffer.toString();
}

const _charMap = <String, String>{
  'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a',
  'č': 'c', 'ç': 'c',
  'ď': 'd', 'ð': 'd',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', 'ě': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ň': 'n', 'ñ': 'n',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o', 'ø': 'o',
  'ř': 'r',
  'š': 's',
  'ť': 't',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u', 'ů': 'u',
  'ý': 'y', 'ÿ': 'y',
  'ž': 'z',
};
