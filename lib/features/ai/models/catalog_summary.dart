/// Sanitized catalog data for the AI system prompt.
///
/// Uses record types to strip sensitive fields (pinHash, authUserId)
/// before embedding into the system prompt context.
class CatalogSummary {
  CatalogSummary({
    required this.categories,
    required this.itemCountsByCategory,
    required this.taxRates,
    required this.paymentMethods,
    required this.users,
    required this.sections,
    required this.tables,
  });

  final List<({String id, String name, bool isActive, String? parentId})>
      categories;
  final Map<String, int> itemCountsByCategory;
  final List<
      ({
        String id,
        String label,
        String type,
        int rate,
        bool isDefault,
      })> taxRates;
  final List<({String id, String name, String type, bool isActive})>
      paymentMethods;
  final List<({String id, String fullName, String? email})> users;
  final List<({String id, String name, bool isActive})> sections;
  final List<({String id, String name, String? sectionId, int capacity})>
      tables;

  /// Formats all data as human-readable text for the system prompt.
  String toPromptString() {
    final buffer = StringBuffer();

    // Categories
    buffer.write('Kategorie (${categories.length}): ');
    buffer.writeln(
      categories.map((c) {
        final count = itemCountsByCategory[c.id] ?? 0;
        return '${c.name} (id: ${c.id}, $count polozek)';
      }).join(', '),
    );

    // Tax rates
    buffer.write('Danove sazby (${taxRates.length}): ');
    buffer.writeln(
      taxRates.map((t) {
        final pct = (t.rate / 100).toStringAsFixed(t.rate % 100 == 0 ? 0 : 2);
        final def = t.isDefault ? ', default' : '';
        return '${t.label} $pct% (id: ${t.id}$def)';
      }).join(', '),
    );

    // Payment methods
    buffer.write('Platebni metody (${paymentMethods.length}): ');
    buffer.writeln(
      paymentMethods
          .where((p) => p.isActive)
          .map((p) => '${p.name} (id: ${p.id}, ${p.type})')
          .join(', '),
    );

    // Users
    buffer.write('Uzivatele (${users.length}): ');
    buffer.writeln(
      users.map((u) => '${u.fullName} (id: ${u.id})').join(', '),
    );

    // Sections
    buffer.write('Sekce (${sections.length}): ');
    buffer.writeln(
      sections.map((s) => '${s.name} (id: ${s.id})').join(', '),
    );

    // Tables
    buffer.write('Stoly (${tables.length}): ');
    buffer.writeln(
      tables.map((t) {
        final section = t.sectionId != null
            ? sections
                .where((s) => s.id == t.sectionId)
                .map((s) => ', sekce: ${s.name}')
                .firstOrNull
            : null;
        return '${t.name} (id: ${t.id}${section ?? ''}, kapacita: ${t.capacity})';
      }).join(', '),
    );

    return buffer.toString();
  }
}
