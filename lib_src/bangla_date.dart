// Bangladesh official Bangla calendar conversion (approximate to the
// official calendar: year starts 14 April, month lengths fixed, Falgun
// 30 days in Gregorian leap years).
const List<String> banglaMonths = [
  'বৈশাখ', 'জ্যৈষ্ঠ', 'আষাঢ়', 'শ্রাবণ', 'ভাদ্র', 'আশ্বিন',
  'কার্তিক', 'অগ্রহায়ণ', 'পৌষ', 'মাঘ', 'ফাল্গুন', 'চৈত্র',
];

bool _isLeap(int y) => (y % 4 == 0 && y % 100 != 0) || y % 400 == 0;

List<int> _monthDays(int banglaYearStartGregYear) {
  // Falgun belongs to the Gregorian year after the Boishakh start year
  // when counting from April, except Jan-Mar dates handled by caller.
  return [31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29, 30];
}

String banglaDateString(DateTime d) {
  // Find the Boishakh 1 (14 April) that starts this Bangla year.
  var startYear = d.month > 4 || (d.month == 4 && d.day >= 14)
      ? d.year
      : d.year - 1;
  final start = DateTime(startYear, 4, 14);
  var diff = d.difference(start).inDays;
  final banglaYear = startYear - 593;
  // Falgun length: leap if the Gregorian year containing Falgun is leap.
  final falgunLeap = _isLeap(startYear + 1);
  final days = [31, 31, 31, 31, 31, 30, 30, 30, 30, 30, falgunLeap ? 30 : 29, 30];
  var m = 0;
  while (m < 12 && diff >= days[m]) {
    diff -= days[m];
    m++;
  }
  if (m >= 12) {
    m = 11;
    diff = days[11] - 1;
  }
  return '${_bnNum(diff + 1)} ${banglaMonths[m]}, ${_bnNum(banglaYear)}';
}

String _bnNum(int n) {
  const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  return n.toString().split('').map((c) => bn[int.parse(c)]).join();
}

String bnNumStr(String s) {
  const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  return s.split('').map((c) {
    final v = int.tryParse(c);
    return v == null ? c : bn[v];
  }).join();
}
