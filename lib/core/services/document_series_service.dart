import '../database/app_database.dart';

class DocumentSeriesService {
  DocumentSeriesService(this._db);

  final AppDatabase _db;

  static const String itemModule = 'item';

  Future<String> getNextFormattedNumber(String module) async {
    final normalizedModule = module.trim().toLowerCase();
    if (normalizedModule.isEmpty) {
      throw StateError('Module is required');
    }

    var series = await _db.getSeriesByModule(normalizedModule);
    if (series == null && normalizedModule == itemModule) {
      await _db.ensureDefaultItemSeries();
      series = await _db.getSeriesByModule(normalizedModule);
    }

    if (series == null) {
      throw StateError('Series not found for module: $normalizedModule');
    }

    if (series.status != 1) {
      throw StateError('Series is inactive for module: $normalizedModule');
    }

    return _applyPattern(
      pattern: series.pattern,
      prefix: series.prefix,
      suffix: series.suffix,
      currentNumber: series.currentNumber,
    );
  }

  Future<void> incrementSeries(String module) {
    final normalizedModule = module.trim().toLowerCase();
    return _db.incrementSeriesNumber(normalizedModule);
  }

  String _applyPattern({
    required String pattern,
    required String? prefix,
    required String? suffix,
    required int currentNumber,
  }) {
    final prefixValue = (prefix ?? '').trim();
    final suffixValue = (suffix ?? '').trim();

    var output = pattern
        .replaceAll('{prefix}', prefixValue)
        .replaceAll('{current_number}', currentNumber.toString())
        .replaceAll('{suffix}', suffixValue);

    // Remove repeated separators caused by empty optional tokens.
    output = output
        .replaceAll('--', '-')
        .replaceAll('//', '/')
        .replaceAll('__', '_')
        .trim();

    if (output.startsWith('-') || output.startsWith('/') || output.startsWith('_')) {
      output = output.substring(1);
    }
    if (output.endsWith('-') || output.endsWith('/') || output.endsWith('_')) {
      output = output.substring(0, output.length - 1);
    }

    if (output.isEmpty) {
      return currentNumber.toString();
    }

    return output;
  }
}
