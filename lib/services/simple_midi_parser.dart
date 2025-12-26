// import 'package:just_audio/just_audio.dart';
// import 'package:flutter_midi_command/flutter_midi_command.dart';


// class HymnAudioService {

//   final _midiDevice = MidiCommand();
//   static final AudioPlayer _player = AudioPlayer();

//   static Future<void> playFromAsset(String hymnId) async {
//     try {
//       await _player.stop();
//       await _player.setAsset('assets/mp3/m$hymnId.mp3');
//       await _player.play();
//     } catch (e) {
//       print('Audio error: assets/mp3/m$hymnId.mp3 $e');
//     }
//   }

//   static Future<void> stop() async {
//     await _player.stop();
//   }

//   static bool get isPlaying => _player.playing;
// }
