import 'package:expense_tracker/features/transactions/domain/bulk_entry_parser.dart';
import 'package:expense_tracker/features/transactions/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  int? amount(String line) => parseBulkLine(line).amountMinor;

  test('reads Vietnamese amount shorthand', () {
    expect(amount('coffee 35k'), 35000);
    expect(amount('lunch 1tr2'), 1200000);
    expect(amount('rent 1tr25'), 1250000);
    expect(amount('gift 2k5'), 2500);
    expect(amount('phone 1.5tr'), 1500000);
    expect(amount('phone 1,5tr'), 1500000);
    expect(amount('+salary 15tr'), 15000000);
    expect(amount('house 2 tỷ'), 2000000000);
    expect(amount('book 120.000'), 120000);
    expect(amount('book 1,200,000'), 1200000);
    expect(amount('taxi 52000'), 52000);
    // Bare small numbers are thousands.
    expect(amount('cafe 35'), 35000);
    expect(amount('no amount here'), isNull);
  });

  test('the amount can be anywhere; the rest is the note', () {
    final line = parseBulkLine('  52k grab đi làm ');
    expect(line.amountMinor, 52000);
    expect(line.note, 'grab đi làm');
    expect(line.type, TransactionType.expense);
  });

  test('a leading plus is income', () {
    final line = parseBulkLine('+lương tháng 10 15tr');
    expect(line.type, TransactionType.income);
    expect(line.category, CategoryCode.salary);
    expect(line.note, 'lương tháng 10');
  });

  test('guesses categories from keywords, with or without accents', () {
    CategoryCode cat(String l) => parseBulkLine(l).category;
    expect(cat('cà phê 35k'), CategoryCode.food);
    expect(cat('ca phe 35k'), CategoryCode.food);
    expect(cat('grab 52k'), CategoryCode.transport);
    expect(cat('tiền điện 600k'), CategoryCode.bills);
    expect(cat('Shopee 250k'), CategoryCode.shopping);
    expect(cat('thuốc 80k'), CategoryCode.health);
    expect(cat('something 10k'), CategoryCode.otherExpense);
    expect(cat('+lì xì 500k'), CategoryCode.gift);
  });

  test('blank lines are skipped and lines keep their order', () {
    final lines = parseBulkEntry('coffee 35k\n\n  \ngrab 52k\n+salary 15tr');
    expect(lines.map((l) => l.amountMinor), [35000, 52000, 15000000]);
    expect(lines.every((l) => l.isValid), isTrue);
  });
}
