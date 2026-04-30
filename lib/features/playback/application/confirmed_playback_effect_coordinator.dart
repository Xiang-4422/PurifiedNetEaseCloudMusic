import 'package:bujuan/features/playback/application/current_track_side_effect_coordinator.dart';

/// 已确认播放歌曲的副作用调度器。
///
/// 只处理底层 source 已确认后的缓存、下载状态和当前歌曲持久化等行为。
class ConfirmedPlaybackEffectCoordinator extends CurrentTrackSideEffectCoordinator {}
