import 'package:app_ui/app_ui.dart';
import 'package:conexion_blocks_ui/conexion_blocks_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:shared/shared.dart';
import 'package:flutter/widgets.dart';
import 'package:conexion/l10n/l10n.dart';

void initUtilities(BuildContext context, Locale locale) {
  final isSameLocal = Localizations.localeOf(context) == locale;
  if (isSameLocal) return;

  final l10n = context.l10n;
  // final t = context.t;

  PickImage().init(
    tabsTexts: TabsTexts(
      photoText: l10n.photoText,
      videoText: l10n.videoText,
      acceptAllPermissions: l10n.acceptAllPermissionsText,
      clearImagesText: l10n.clearImagesText,
      deletingText: l10n.deletingText,
      galleryText: l10n.galleryText,
      holdButtonText: l10n.holdButtonText,
      noMediaFound: l10n.noMediaFound,
      notFoundingCameraText: l10n.notFoundingCameraText,
      noCameraFoundText: l10n.noCameraFoundText,
      newPostText: l10n.newPostText,
      newAvatarImageText: l10n.newAvatarImageText,
    ),
  );
  
  BlockSettings().init(
    postDelegate: PostTextDelegate(
      cancelText: l10n.cancelText,
      editText: l10n.editText,
      deleteText: l10n.deleteText,
      deletePostText: l10n.deletePostText,
      deletePostConfirmationText: l10n.deletePostConfirmationText,
      notShowAgainText: l10n.notShowAgainText,
      blockAuthorConfirmationText: l10n.blockAuthorConfirmationText,
      blockAuthorText: l10n.blockAuthorText,
      blockPostAuthorText: l10n.blockPostAuthorText,
      blockText: l10n.blockText,
      noPostsText: l10n.noPostsText,
      visitSponsoredInstagramProfileText: l10n.visitSponsoredInstagramProfile,
      likedByText: (count, name, onUsernameTap) => t.likedBy(
        name: TextSpan(
          text: name,
          style: context.titleMedium?.copyWith(fontWeight: AppFontWeight.bold),
          recognizer: TapGestureRecognizer()..onTap = onUsernameTap,
        ),
        and: TextSpan(text: count < 1 ? '' : l10n.andText),
        others: TextSpan(
          text: l10n.othersText(count),
          style: context.titleMedium?.copyWith(fontWeight: AppFontWeight.bold),
        ),
      ),
      sponsoredPostText: l10n.sponsoredPostText,
      likesCountText: l10n.likesCountText,
      likesCountShortText: l10n.likesCountTextShort,
    ),
    commentDelegate: CommentTextDelegate(
      seeAllCommentsText: l10n.seeAllComments,
      replyText: l10n.replyText,
    ),
    followDelegate: FollowTextDelegate(
      followText: l10n.followUser,
      followingText: l10n.followingUser,
    ),
  );
}