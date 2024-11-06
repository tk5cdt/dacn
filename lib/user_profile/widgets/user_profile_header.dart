import 'package:app_ui/app_ui.dart';
import 'package:conexion/l10n/l10n.dart';
import 'package:conexion/user_profile/user_profile.dart';
import 'package:conexion_blocks_ui/conexion_blocks_ui.dart';
import 'package:conexion_blocks_ui/src/user_profile/user_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

class UserProfileHeader extends StatelessWidget {
  const UserProfileHeader({required this.userId, super.key});

  final String userId;

  void _pushToUserStatistics(BuildContext context, {required int tabIndex}) =>
      context.pushNamed(
        'user_statistics',
        extra: tabIndex,
        queryParameters: {'user_id': userId},
      );

  @override
  Widget build(BuildContext context) {
    final isOwner = context.select((UserProfileBloc bloc) => bloc.isOwner);
    final user = context.select((UserProfileBloc bloc) => bloc.state.user);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            Row(
              children: [
                // CircleAvatar(
                //   backgroundImage: NetworkImage(user.avatarUrl ?? ''),
                //   radius: 32,
                // ),
                UserProfileAvatar(
                  avatarUrl: user.avatarUrl,
                  onLongPress: (avatarUrl) => avatarUrl == null
                      ? null
                      : context.showImagePreview(avatarUrl),
                  onTap: (imageUrl) {
                    if (imageUrl == null) return;
                    if (!isOwner) context.showImagePreview(imageUrl);
                    if (isOwner) {}
                  },
                ),
                const Gap.h(AppSpacing.md),
                Expanded(
                  child: UserProfileStatisticsCounts(
                    onStatisticTap: (tabIndex) =>
                        _pushToUserStatistics(context, tabIndex: tabIndex),
                  ),
                ),
              ],
            ),
            const Gap.v(AppSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                user.displayFullName,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: context.titleMedium
                    ?.copyWith(fontWeight: AppFontWeight.semiBold),
              ),
            ),
            const Gap.v(AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isOwner)
                  ...<Widget>[
                    const Flexible(flex: 3, child: EditProfileButton()),
                    const Flexible(flex: 3, child: ShareProfileButton()),
                    const Flexible(child: ShowSuggestedPeopleButton()),
                  ].spacerBetween(width: AppSpacing.sm)
                else ...[
                  const Expanded(
                    flex: 3,
                    child: UserProfileFollowUserButton(),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UserProfileStatisticsCounts extends StatelessWidget {
  const UserProfileStatisticsCounts({required this.onStatisticTap, super.key});

  final ValueSetter<int> onStatisticTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final postsCount =
        context.select((UserProfileBloc bloc) => bloc.state.postsCount);
    final followersCount =
        context.select((UserProfileBloc bloc) => bloc.state.followersCount);
    final followingsCount =
        context.select((UserProfileBloc bloc) => bloc.state.followingsCount);

    return Row(
      children: <Widget>[
        Expanded(
          child: UserProfileStatistic(
            name: l10n.postsCount(postsCount),
            value: postsCount,
          ),
        ),
        Expanded(
          child: UserProfileStatistic(
            name: l10n.followersText,
            value: followersCount,
            onTap: () => onStatisticTap.call(0),
          ),
        ),
        Expanded(
          child: UserProfileStatistic(
            name: l10n.followingsText,
            value: followingsCount,
            onTap: () => onStatisticTap.call(1),
          ),
        ),
      ],
    );
  }
}

class EditProfileButton extends StatelessWidget {
  const EditProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return UserProfileButton(
      label: context.l10n.editProfileText,
      onTap: () => context.pushNamed('edit_profile'),
    );
  }
}

class ShareProfileButton extends StatelessWidget {
  const ShareProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return UserProfileButton(
      label: context.l10n.shareProfileText,
      onTap: () {},
    );
  }
}

class ShowSuggestedPeopleButton extends StatefulWidget {
  const ShowSuggestedPeopleButton({super.key});

  @override
  State<ShowSuggestedPeopleButton> createState() =>
      _ShowSuggestedPeopleButtonState();
}

class _ShowSuggestedPeopleButtonState extends State<ShowSuggestedPeopleButton> {
  var _showPeople = false;

  @override
  Widget build(BuildContext context) {
    return UserProfileButton(
      onTap: () => setState(() => _showPeople = !_showPeople),
      child: Icon(
        _showPeople ? Icons.person_add_rounded : Icons.person_add_outlined,
        size: 20,
      ),
    );
  }
}

class UserProfileFollowUserButton extends StatelessWidget {
  const UserProfileFollowUserButton({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<UserProfileBloc>();
    final user = context.select((UserProfileBloc bloc) => bloc.state.user);

    final l10n = context.l10n;

    return BetterStreamBuilder<bool>(
      stream: bloc.followingStatus(),
      builder: (context, isFollowed) {
        return UserProfileButton(
          label: isFollowed ? '${l10n.followingUser} ▼' : l10n.followUser,
          color: isFollowed
              ? null
              : context.customReversedAdaptiveColor(
                  light: AppColors.lightBlue,
                  dark: AppColors.blue,
                ),
          onTap: isFollowed
              ? () async {
                  void callback(ModalOption option) =>
                      option.onTap.call(context);

                  final option = await context.showListOptionsModal(
                    title: user.username,
                    options: followerModalOptions(
                      unfollowLabel: context.l10n.cancelFollowingText,
                      onUnfollowTap: () =>
                          bloc.add(const UserProfileFollowUserRequested()),
                    ),
                  );
                  if (option == null) return;
                  callback.call(option);
                }
              : () => bloc.add(const UserProfileFollowUserRequested()),
        );
      },
    );
  }
}
