import 'models.dart';

/// One line of bulk entry, e.g. "cafe 35k" or "+lương 15tr".
class BulkEntryLine {
  final String raw;

  /// Null when no amount was found; such lines are not saved.
  final int? amountMinor;
  final TransactionType type;
  final CategoryCode category;

  /// The line without its amount (and without a leading +/−).
  final String note;

  const BulkEntryLine({
    required this.raw,
    required this.amountMinor,
    required this.type,
    required this.category,
    required this.note,
  });

  bool get isValid => amountMinor != null && amountMinor! > 0;
}

/// Parses a pasted or typed spending list, one transaction per line.
///
/// Amounts: `35k` = 35.000, `1tr2` = 1.200.000, `1.5tr`, `15tr`, `2tỷ`,
/// `35.000` / `35,000`, `35000`. A bare number under 1.000 counts as
/// thousands (`cafe 35` = 35.000), the usual Vietnamese shorthand. A leading
/// `+` marks income. The category is guessed from keywords in the note.
List<BulkEntryLine> parseBulkEntry(String text) => [
  for (final line in text.split('\n'))
    if (line.trim().isNotEmpty) parseBulkLine(line),
];

BulkEntryLine parseBulkLine(String line) {
  var rest = line.trim();
  var type = TransactionType.expense;
  if (rest.startsWith('+')) {
    type = TransactionType.income;
    rest = rest.substring(1).trim();
  } else if (rest.startsWith('-') || rest.startsWith('−')) {
    rest = rest.substring(1).trim();
  }

  // The last amount-looking token wins ("grab 52k", "52k grab").
  int? amount;
  RegExpMatch? amountMatch;
  for (final m in _amountToken.allMatches(rest)) {
    final value = _amountOf(m);
    if (value != null) {
      amount = value;
      amountMatch = m;
    }
  }
  final note = amountMatch == null
      ? rest
      : (rest.substring(0, amountMatch.start) + rest.substring(amountMatch.end))
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();

  return BulkEntryLine(
    raw: line.trim(),
    amountMinor: amount,
    type: type,
    category: guessCategory(note, type),
    note: note,
  );
}

/// A number with an optional unit and an optional digit tail after the unit
/// (the "2" in "1tr2"). Bounded by spaces or line ends so words like "4g"
/// inside a note need the unit list to match.
final _amountToken = RegExp(
  r'(?<![\p{L}\d])(\d+(?:[.,]\d+)*)\s?(k|nghìn|ngàn|tr|triệu|m|tỷ|ty|b)?(\d{1,3})?(?![\p{L}\d])',
  caseSensitive: false,
  unicode: true,
);

const _units = {
  'k': 1000,
  'nghìn': 1000,
  'ngàn': 1000,
  'tr': 1000000,
  'triệu': 1000000,
  'm': 1000000,
  'tỷ': 1000000000,
  'ty': 1000000000,
  'b': 1000000000,
};

int? _amountOf(RegExpMatch m) {
  final number = m.group(1)!;
  final unitName = m.group(2)?.toLowerCase();
  final tail = m.group(3);
  final unit = unitName == null ? null : _units[unitName];

  if (unit == null) {
    if (tail != null) return null;
    // "35.000" / "35,000" / "1.200.000": grouping separators.
    if (RegExp(r'^\d{1,3}([.,]\d{3})+$').hasMatch(number)) {
      return int.parse(number.replaceAll(RegExp('[.,]'), ''));
    }
    if (!RegExp(r'^\d+$').hasMatch(number)) return null;
    final value = int.parse(number);
    return value < 1000 ? value * 1000 : value;
  }

  // "1.5tr" / "1,5tr": a decimal before the unit.
  final whole = double.tryParse(number.replaceAll(',', '.'));
  if (whole == null) return null;
  var value = (whole * unit).round();
  if (tail != null) {
    // "1tr2" = 1.2 million, "2k5" = 2.5 thousand, "1tr25" = 1.25 million.
    value += (int.parse(tail) * unit / _pow10(tail.length)).round();
  }
  return value;
}

int _pow10(int n) {
  var r = 1;
  for (var i = 0; i < n; i++) {
    r *= 10;
  }
  return r;
}

/// Keyword guesses, checked in order on the note without diacritics.
const _expenseKeywords = <CategoryCode, List<String>>{
  CategoryCode.bills: [
    'tien dien',
    'tien nuoc',
    'internet',
    'wifi',
    'dien thoai',
    '4g',
    'hoa don',
    'bill',
    'electric',
    'water bill',
    'phone',
  ],
  CategoryCode.housing: ['thue nha', 'tien nha', 'nha tro', 'rent', 'house'],
  CategoryCode.transport: [
    'grab',
    'be',
    'xanh sm',
    'xang',
    'taxi',
    'bus',
    'xe',
    'gui xe',
    'parking',
    'uber',
    'gojek',
    'gas',
    'fuel',
    'metro',
  ],
  CategoryCode.food: [
    'an',
    'com',
    'pho',
    'bun',
    'banh',
    'cafe',
    'ca phe',
    'coffee',
    'tra',
    'tra sua',
    'lunch',
    'dinner',
    'breakfast',
    'food',
    'nuoc',
    'bia',
    'beer',
    'snack',
    'di cho',
    'cho',
    'grocery',
    'lau',
    'nuong',
    'kfc',
    'pizza',
    'highlands',
    'starbucks',
    'milk tea',
    'tea',
    'drink',
  ],
  CategoryCode.shopping: [
    'shopee',
    'lazada',
    'tiki',
    'quan ao',
    'ao',
    'quan',
    'giay',
    'tui',
    'shopping',
    'mua',
    'sieu thi',
    'clothes',
    'shoes',
  ],
  CategoryCode.health: [
    'thuoc',
    'benh vien',
    'kham',
    'nha thuoc',
    'doctor',
    'medicine',
    'hospital',
    'gym',
    'pharmacy',
  ],
  CategoryCode.entertainment: [
    'phim',
    'movie',
    'netflix',
    'spotify',
    'youtube',
    'game',
    'karaoke',
    'cinema',
    'concert',
  ],
  CategoryCode.education: [
    'hoc',
    'hoc phi',
    'sach',
    'book',
    'course',
    'khoa hoc',
    'tuition',
  ],
  CategoryCode.travel: [
    'du lich',
    've may bay',
    'may bay',
    'flight',
    'hotel',
    'khach san',
    'travel',
    'homestay',
    'resort',
  ],
  CategoryCode.personalCare: [
    'cat toc',
    'toc',
    'spa',
    'nail',
    'haircut',
    'my pham',
    'cosmetic',
  ],
};

const _incomeKeywords = <CategoryCode, List<String>>{
  CategoryCode.salary: ['luong', 'salary', 'thuong', 'bonus', 'wage'],
  CategoryCode.freelance: ['freelance', 'du an', 'project', 'job'],
  CategoryCode.investment: [
    'lai',
    'co tuc',
    'interest',
    'dividend',
    'chung khoan',
    'stock',
  ],
  CategoryCode.business: ['ban hang', 'doanh thu', 'sales', 'business'],
  CategoryCode.gift: ['qua', 'li xi', 'lixi', 'mung', 'gift'],
};

CategoryCode guessCategory(String note, TransactionType type) {
  final words = ' ${_plain(note)} ';
  final table = type == TransactionType.income
      ? _incomeKeywords
      : _expenseKeywords;
  for (final entry in table.entries) {
    for (final keyword in entry.value) {
      if (words.contains(' $keyword ')) return entry.key;
    }
  }
  return type == TransactionType.income
      ? CategoryCode.otherIncome
      : CategoryCode.otherExpense;
}

/// Lowercase, Vietnamese diacritics removed, punctuation as spaces.
String _plain(String text) {
  final buffer = StringBuffer();
  for (final rune in text.toLowerCase().runes) {
    final ch = String.fromCharCode(rune);
    buffer.write(_fold[ch] ?? ch);
  }
  return buffer.toString().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
}

final _fold = () {
  const groups = {
    'a': 'àáạảãâầấậẩẫăằắặẳẵ',
    'e': 'èéẹẻẽêềếệểễ',
    'i': 'ìíịỉĩ',
    'o': 'òóọỏõôồốộổỗơờớợởỡ',
    'u': 'ùúụủũưừứựửữ',
    'y': 'ỳýỵỷỹ',
    'd': 'đ',
  };
  return {
    for (final MapEntry(:key, :value) in groups.entries)
      for (final ch in value.split('')) ch: key,
  };
}();
