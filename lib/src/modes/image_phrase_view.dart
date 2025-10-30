import 'package:firebase_cached_image/firebase_cached_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../repos/phrase.dart';

class ImagePhraseView extends StatelessWidget {
  final Phrase phrase;
  const ImagePhraseView({super.key, required this.phrase});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Center(
            child: Image(
              image: FirebaseImageProvider(
                FirebaseUrl.fromReference(FirebaseStorage.instance.ref(phrase.firebaseRef))
              ),
            ),));
  }
}
