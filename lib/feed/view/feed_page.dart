import 'dart:math';

import 'package:app_ui/app_ui.dart';
import 'package:con_blocks/con_blocks.dart';
import 'package:conexion/l10n/slang/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeedView();
  }
}

class FeedView extends StatelessWidget {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context) {
    final feed = List.generate(
      10,
      (index) => PostLargeBlock(
        id: uuid.v4(),
        author: PostAuthor.randomConfirmed(),
        createdAt:
            DateTime.now().subtract(Duration(days: Random().nextInt(365))),
        media: [
          ImageMedia(
            id: uuid.v4(),
            url:
                'https://antimatter.vn/wp-content/uploads/2022/04/anh-meo-khoc-thet-meme.jpg',
          )
        ],
        caption: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. ',
      ),
    );

    return AppScaffold(
      body: Column(
        children: [
        //   Text.rich(
        //     t.likedBy(
        //       name: const TextSpan(text: 'John Doe'),
        //       and: const TextSpan(text: ' and '),
        //       others: const TextSpan(text: 'others'),
        //     ),
        //   ),
          Expanded(
            child: ListView.builder(
              itemCount: feed.length,
              itemBuilder: (context, index) {
                final post = feed[index];
                return Image.network(post.firstMediaUrl!);
              },
            ),
          ),
        ],
      ),
    );
  }
}
