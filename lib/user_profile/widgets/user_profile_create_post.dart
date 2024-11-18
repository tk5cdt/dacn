// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:conexion/l10n/l10n.dart';
import 'package:conexion_blocks_ui/conexion_blocks_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

import '../../app/view/app.dart';
import '../../feed/post/widgets/post_edit.dart';
import '../../feed/widgets/feed_page_controller.dart';
import '../../home/provider/home_provider.dart';

class UserProfileCreatePost extends StatelessWidget {
  const UserProfileCreatePost({
    this.canPop = true,
    this.imagePickerKey,
    this.pickVideo = false,
    this.onPopInvoked,
    this.onBackButtonTap,
    super.key,
    this.wantKeepAlive = true,
  });

  final bool canPop;
  final Key? imagePickerKey;
  final bool pickVideo;
  final bool wantKeepAlive;
  final VoidCallback? onBackButtonTap;
  final VoidCallback? onPopInvoked;

  @override
  Widget build(BuildContext context) {
    final pickerSource = pickVideo ? PickerSource.video : PickerSource.both;
    return WillPopScope(
      onWillPop: () =>
          onPopInvoked == null ? Future.value(true) : Future.value(false),
      child: PickImage().customMediaPicker(
        key: imagePickerKey,
        context: context,
        source: ImageSource.both,
        pickerSource: pickerSource,
        multiSelection: !pickVideo,
        wantKeepAlive: wantKeepAlive,
        onMediaPicked: (details) => context.pushNamed(
          'publish_post',
          extra: CreatePostProps(details: details, pickVideo: pickVideo),
        ),
        onBackButtonTap:
            onBackButtonTap != null ? () => onBackButtonTap?.call() : null,
      ),
    );
  }
}

class CreatePostProps {
  const CreatePostProps({
    required this.details,
    this.pickVideo = false,
  });

  final SelectedImagesDetails details;
  final bool pickVideo;
}

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({required this.props, super.key});

  final CreatePostProps props;

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  late TextEditingController _captionController;
  late List<Media> _media;

  List<SelectedByte> get selectedFiles => widget.props.details.selectedFiles;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController();
    _media = selectedFiles
        .map(
          (e) => e.isThatImage
              ? MemoryImageMedia(bytes: e.selectedByte, id: uuid.v4())
              : MemoryVideoMedia(id: uuid.v4(), file: e.selectedFile),
        )
        .toList();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _onShareTap(String caption) async {
    void goHome() {
      if (!widget.props.pickVideo) {
        HomeProvider().animateToPage(1);
        FeedPageController().scrollToTop();
      }
    }

    try {
      toggleLoadingIndeterminate();

      final postId = uuid.v4();
      unawaited(
        FeedPageController().processPostMedia(
          postId: postId,
          selectedFiles: selectedFiles,
          caption: _captionController.text.trim(),
          pickVideo: widget.props.pickVideo,
        ),
      );
      goHome.call();
      toggleLoadingIndeterminate(enable: false);
    } catch (error, stackTrace) {
      toggleLoadingIndeterminate(enable: false);
      logE('Failed to create post', error: error, stackTrace: stackTrace);
      openSnackbar(
        const SnackbarMessage.error(title: 'Failed to create post!'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: false,
        title: Text(context.l10n.newPostText),
      ),
      bottomNavigationBar: PublishPostButton(
        onShareTap: () => _onShareTap(_captionController.text.trim()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostMedia(
              media: _media,
              withLikeOverlay: false,
              withInViewNotifier: false,
              autoHideCurrentIndex: false,
              mediaCarouselSettings: const MediaCarouselSettings.empty(
                viewportFraction: .9,
              ),
            ),
            const Gap.v(AppSpacing.sm),
            CaptionInputField(
              captionController: _captionController,
              caption: _captionController.text.trim(),
              onSubmitted: _onShareTap,
            ),
          ],
        ),
      ),
    );
  }
}

class PublishPostButton extends StatelessWidget {
  const PublishPostButton({required this.onShareTap, super.key});

  final VoidCallback onShareTap;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 0,
      color: context.reversedAdaptiveColor,
      padding: EdgeInsets.zero,
      height: 90,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Tappable.faded(
              onTap: onShareTap,
              borderRadius: BorderRadius.circular(6),
              backgroundColor: AppColors.blue,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
                horizontal: AppSpacing.sm,
              ),
              child: Align(
                child: Text(
                  context.l10n.sharePostText,
                  style: context.labelLarge,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
