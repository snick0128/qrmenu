enum DateFilterType {
  today,
  week,
  month,
  year,
  allTime;

  String get displayName {
    switch (this) {
      case DateFilterType.today:
        return 'Today';
      case DateFilterType.week:
        return 'This Week';
      case DateFilterType.month:
        return 'This Month';
      case DateFilterType.year:
        return 'This Year';
      case DateFilterType.allTime:
        return 'All Time';
    }
  }
}