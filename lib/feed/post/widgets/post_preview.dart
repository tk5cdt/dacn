import 'package:app_ui/app_ui.dart';
import 'package:con_blocks/con_blocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conexion/feed/feed.dart';
import 'package:conexion/feed/post/post.dart';
import 'package:conexion/l10n/l10n.dart';
import 'package:shared/shared.dart';

class PostPreviewPage extends StatelessWidget {
  const PostPreviewPage({
    required this.id,
    super.key,
  });

  final String id;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const PostPreviewAppBar(),
      body: PostPreviewDetails(id: id),
    );
  }
}

class PostPreviewAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PostPreviewAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'Conexion',
        style: context.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 28,
          fontFamily: FontFamily.inter,
        ),
      ),
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class PostPreviewEmptyDetails extends StatelessWidget {
  const PostPreviewEmptyDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        context.l10n.noPostFoundText,
        style: context.headlineMedium,
      ),
    );
  }
}

class PostPreviewDetails extends StatefulWidget {
  const PostPreviewDetails({required this.id, super.key});

  final String id;

  @override
  State<PostPreviewDetails> createState() => _PostPreviewDetailsState();
}

class _PostPreviewDetailsState extends State<PostPreviewDetails> {
  PostBlock? block;

  @override
  void initState() {
    super.initState();
    context
        .read<FeedBloc>()
        .getPostBy(widget.id)
        .then((value) => setState(() => block = value as PostBlock?));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () async => context
          .read<FeedBloc>()
          .getPostBy(widget.id)
          .then((value) => setState(() => block = value as PostBlock?)),
      child: ListView(
        children: [
          if (block == null)
            const PostPreviewEmptyDetails()
          else
            PostView(
              key: ValueKey(block!.id),
              block: block!,
              withCustomVideoPlayer: false,
              withInViewNotifier: false,
            ),
        ],
      ),
    );
  }
}
