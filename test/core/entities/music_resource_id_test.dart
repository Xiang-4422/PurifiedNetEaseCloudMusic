import 'package:bujuan/core/entities/music_resource_id.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MusicResourceId', () {
    test('normalizes bare and prefixed netease ids', () {
      expect(MusicResourceId.toNeteaseEntityId('123'), 'netease:123');
      expect(MusicResourceId.toNeteaseEntityId('netease:123'), 'netease:123');
      expect(MusicResourceId.toNeteaseEntityId(' 123 '), 'netease:123');
      expect(MusicResourceId.toNeteaseEntityId(' netease:123 '), 'netease:123');
      expect(MusicResourceId.toNeteaseEntityId(' local:/music/a.mp3 '), 'local:/music/a.mp3');
      expect(MusicResourceId.toNeteaseEntityId('   '), '');
      expect(MusicResourceId.toNeteaseSourceId('netease:123'), '123');
      expect(MusicResourceId.toNeteaseSourceId(' netease:123 '), '123');
      expect(MusicResourceId.toNeteaseSourceId('local:/music/a.mp3'), 'local:/music/a.mp3');
      expect(MusicResourceId.toNeteaseSourceId(' local:/music/a.mp3 '), 'local:/music/a.mp3');
    });

    test('resolves source ids and source types for known prefixes', () {
      expect(MusicResourceId.toSourceId('123'), '123');
      expect(MusicResourceId.toSourceId(' 123 '), '123');
      expect(MusicResourceId.toSourceId('netease:123'), '123');
      expect(MusicResourceId.toSourceId(' netease:123 '), '123');
      expect(MusicResourceId.toSourceId('local:/music/a.mp3'), '/music/a.mp3');
      expect(MusicResourceId.toSourceId(' local:/music/a.mp3 '), '/music/a.mp3');
      expect(MusicResourceId.sourceTypeOf('123'), SourceType.netease);
      expect(MusicResourceId.sourceTypeOf(' 123 '), SourceType.netease);
      expect(MusicResourceId.sourceTypeOf('netease:123'), SourceType.netease);
      expect(MusicResourceId.sourceTypeOf(' netease:123 '), SourceType.netease);
      expect(MusicResourceId.sourceTypeOf('local:/music/a.mp3'), SourceType.local);
      expect(MusicResourceId.sourceTypeOf(' local:/music/a.mp3 '), SourceType.local);
    });

    test('checks known prefixes after trimming ids', () {
      expect(MusicResourceId.hasKnownPrefix(' netease:123 '), isTrue);
      expect(MusicResourceId.hasKnownPrefix(' local:/music/a.mp3 '), isTrue);
      expect(MusicResourceId.hasKnownPrefix(' 123 '), isFalse);
    });
  });
}
