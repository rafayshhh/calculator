import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/constants/kreate_links.dart';

void main() {
  group('KreateLinks Open-Source Destinations & Creator Credits Tests', () {
    test('Official URLs point to Calculator repository and creator profile', () {
      expect(KreateLinks.creatorName, 'Muhammad Abdul Rafay');
      expect(KreateLinks.creatorHandle, '@rafayshhh');
      expect(KreateLinks.github, 'https://github.com/rafayshhh');
      expect(KreateLinks.repo, 'https://github.com/rafayshhh/calculator');
      expect(KreateLinks.website, 'https://kreatekode.website');
      expect(KreateLinks.instagram, 'https://www.instagram.com/kreatekode/');
      expect(KreateLinks.playStore, 'https://play.google.com/store/apps/developer?id=KreateKode');
      expect(KreateLinks.issues, 'https://github.com/rafayshhh/calculator/issues');
      expect(KreateLinks.discussions, 'https://github.com/rafayshhh/calculator/discussions');
      expect(KreateLinks.supportEmail, 'rafayinreality@gmail.com');
    });
  });
}
