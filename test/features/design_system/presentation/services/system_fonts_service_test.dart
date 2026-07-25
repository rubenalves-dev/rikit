import 'package:flutter_test/flutter_test.dart';
import 'package:rikit/features/design_system/presentation/services/system_fonts_service.dart';

void main() {
  test(
    'SystemFontsService loads fonts and returns at least standard fallbacks',
    () async {
      const service = SystemFontsService();
      final fonts = await service.loadSystemFonts();
      expect(fonts.isNotEmpty, true);
      expect(
        fonts.contains('Arial') ||
            fonts.contains('Helvetica') ||
            fonts.contains('SF Pro'),
        true,
      );
    },
  );
}
