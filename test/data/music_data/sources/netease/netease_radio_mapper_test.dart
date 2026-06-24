import 'package:bujuan/data/music_data/sources/netease/mappers/netease_radio_mapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netease_music_api/netease_music_api.dart';

void main() {
  group('NeteaseRadioMapper', () {
    test('normalizes radio ids before building domain radio summary', () {
      final radio = NeteaseRadioMapper.fromRadio(_radio('  radio-1  '));

      expect(radio.id, 'radio-1');
    });

    test('skips blank radio ids in batch mapper', () {
      final radios = NeteaseRadioMapper.fromRadioList([
        _radio('  radio-1  '),
        _radio('   '),
        _radio('  radio-2  '),
      ]);

      expect(radios.map((radio) => radio.id), ['radio-1', 'radio-2']);
    });

    test('normalizes program and main track ids before building domain program', () {
      final program = NeteaseRadioMapper.fromProgram(
        _program(
          '  program-1  ',
          mainTrackId: 123,
        ),
      );

      expect(program.id, 'program-1');
      expect(program.mainTrackId, '123');
    });

    test('skips blank program ids in batch mapper', () {
      final programs = NeteaseRadioMapper.fromProgramList([
        _program('  program-1  ', mainTrackId: 123),
        _program('   ', mainTrackId: 456),
        _program('  program-2  ', mainTrackId: null),
      ]);

      expect(programs.map((program) => program.id), ['program-1', 'program-2']);
      expect(programs.map((program) => program.mainTrackId), ['123', '']);
    });
  });
}

DjRadio _radio(String id) {
  return DjRadio()
    ..id = id
    ..name = 'Radio'
    ..picUrl = 'https://example.com/radio.jpg'
    ..subCount = 1
    ..programCount = 1
    ..radioFeeType = 0
    ..feeScope = 0;
}

DjProgram _program(
  String id, {
  required int? mainTrackId,
}) {
  return DjProgram()
    ..id = id
    ..name = 'Program'
    ..coverUrl = 'https://example.com/program.jpg'
    ..mainTrackId = mainTrackId
    ..bdAuditStatus = 0
    ..duration = 3000
    ..isPublish = true
    ..radio = _radio('radio-1')
    ..mainSong = (Song()
      ..id = '123'
      ..name = 'Song')
    ..dj = (NeteaseAccountProfile()..nickname = 'DJ');
}
