import 'package:app_ui/app_ui.dart';
import 'package:conexion/l10n/l10n.dart';
import 'package:conexion/user_profile/bloc/user_profile_bloc.dart';
import 'package:conexion_blocks_ui/conexion_blocks_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
                CircleAvatar(
                  backgroundImage: NetworkImage(user.avatarUrl ?? ''),
                  radius: 32,
                ),
                const Gap.h(AppSpacing.md),
                Expanded(
                  child: UserProfileStatisticsCounts(
                    onStatisticTap: (tabIndex) =>
                        _pushToUserStatistics(context, tabIndex: tabIndex),
                  ),
                )
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
      // spacing: AppSpacing.sm,
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
