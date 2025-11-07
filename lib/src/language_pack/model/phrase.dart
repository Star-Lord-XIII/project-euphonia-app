///
/// Item in Firebase Firestore language_pack_document's phrases list.
///
final class Phrase {
  // A UUID that helps identify the phrase uniquely
  final String id;

  // If its a
  // text phrase - just plain text
  // image phrase - path starting with a `/`
  final String text;

  // Phrases once created shouldn't be deleted, they should be deactivated.
  // As there can be a recording linked to the deactivated phrase.
  bool active;

  Phrase({required this.id, required this.text, required this.active});

  Phrase.fromJson(Map<String, Object?> json)
      : this(
            id: (json['id']! as String),
            text: (json['text']! as String),
            active: (json['active'] as bool?) ?? true);

  Map<String, Object?> toJson() {
    return {'id': id, 'text': text, 'active': active};
  }

  Map<String, String> toJsonWithoutActive() {
    return {'id': id, 'text': text};
  }
}
