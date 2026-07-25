import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final comparator = goldenFileComparator;
  if (comparator is LocalFileComparator) {
    goldenFileComparator = _CrossPlatformGoldenComparator(comparator);
  }
  await testMain();
}

final class _CrossPlatformGoldenComparator extends LocalFileComparator {
  _CrossPlatformGoldenComparator(LocalFileComparator original)
    : super(original.basedir.resolve('flutter_test_config.dart'));

  static const maximumPlatformDiff = 0.025;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    final accepted = result.passed || result.diffPercent <= maximumPlatformDiff;
    result.dispose();
    if (accepted) return true;
    return super.compare(imageBytes, golden);
  }
}
