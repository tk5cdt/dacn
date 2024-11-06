import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class EnCustomShortMessages extends timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'now';
  @override
  String aboutAMinute(int minutes) => '1 min.';
  @override
  String minutes(int minutes) => '$minutes min.';
  @override
  String aboutAnHour(int minutes) => 'an hour';
  @override
  String hours(int hours) => '$hours hours';
  @override
  String aDay(int hours) => 'a day';
  @override
  String days(int days) => '$days days';
  @override
  String aboutAMonth(int days) => 'a month';
  @override
  String months(int months) => '$months months';
  @override
  String aboutAYear(int year) => 'a year';
  @override
  String years(int years) => '$years years';
  @override
  String wordSeparator() => ' ';
}

extension TimeAgo on DateTime {
  String timeAgo(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays < 6) {
      return timeago.format(this, locale: locale.languageCode);
    } else {
      late DateFormat formatter;
      if (now.year == year) {
        formatter = DateFormat.MMMd(locale.languageCode);
        return formatter.format(this);
      }
      formatter = DateFormat.yMMMd(locale.languageCode);
      return formatter.format(this);
    }
  }

  String timeAgoShort(BuildContext context) {
    timeago.setLocaleMessages('en_custom_short', EnCustomShortMessages());

    const locale = 'en_custom_short';

    return timeago.format(this, locale: locale);
  }
}
