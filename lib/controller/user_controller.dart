String getMonthName(int month) {
  switch (month) {
    case 1:
      return 'January';
    case 2:
      return 'February';
    case 3:
      return 'March';
    case 4:
      return 'April';
    case 5:
      return 'May';
    case 6:
      return 'June';
    case 7:
      return 'July';
    case 8:
      return 'August';
    case 9:
      return 'September';
    case 10:
      return 'October';
    case 11:
      return 'November';
    case 12:
      return 'December';
    default:
      return '';
  }
}

String getTimeString(int hour, int minute, int second) {
  String hourString = hour.toString().padLeft(2, '0');
  String minuteString = minute.toString().padLeft(2, '0');
  String secondString = second.toString().padLeft(2, '0');
  return '$hourString:$minuteString:$secondString';
} 