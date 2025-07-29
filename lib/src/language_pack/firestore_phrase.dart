final class FirestorePhrase {
  final String id;
  final String text;
  bool active;

  FirestorePhrase({required this.id, required this.text, required this.active});

  FirestorePhrase.fromJson(Map<String, Object?> json)
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
