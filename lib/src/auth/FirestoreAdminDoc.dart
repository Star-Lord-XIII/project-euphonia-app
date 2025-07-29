final class FirestoreAdminDoc {
  final List<FirestoreAdmin> languagePackAdmins;

  FirestoreAdminDoc({required this.languagePackAdmins});

  FirestoreAdminDoc.fromJson(Map<String, dynamic>? json)
      : this(
      languagePackAdmins: (json?['language_packs'] as List<dynamic>? ?? [])
          .map((x) => FirestoreAdmin.fromJson(x))
          .toList());

  Map<String, Object?> toJson() {
    return {'language_packs': languagePackAdmins.map((l) => l.toJson()).toList()};
  }
}

final class FirestoreAdmin {
  final String emailId;

  FirestoreAdmin({required this.emailId});

  FirestoreAdmin.fromJson(Map<String, Object?> json)
  : this(emailId: ((json['email_id'] as String?) ?? ''));

  Map<String, String> toJson() {
    return {'email_id': emailId};
  }
}