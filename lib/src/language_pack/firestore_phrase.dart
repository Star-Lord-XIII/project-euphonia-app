final class FirestorePhrase {
  final String id;
  final String text;
  bool active;

  FirestorePhrase({required this.id, required this.text, required this.active});

  FirestorePhrase.fromJson(Map<String, Object?> json)
      : this(
            id: (json['id']! as String),
            text: (json['text']! as String),
            active: (json['active']! as bool));

  Map<String, Object?> toJson() {
    return {'id': id, 'text': text, 'active': active};
  }
}
