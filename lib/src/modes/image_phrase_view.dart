import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../repos/phrase.dart';

class ImagePhraseView extends StatelessWidget {
  final Phrase phrase;
  const ImagePhraseView({super.key, required this.phrase});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Center(
            child: FutureBuilder(
                future: phrase.imageUrl,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  return CachedNetworkImage(
                      cacheKey: phrase.uid,
                      imageUrl: snapshot.requireData,
                      placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                      const Icon(Icons.error));
                })));
  }
}
