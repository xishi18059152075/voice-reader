import 'package:flutter/material.dart';
import '../models/reading_state.dart';

/// 控制面板组件
class ControlPanel extends StatelessWidget {
  final PlaybackState playbackState;
  final double speed;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<double> onSpeedChanged;

  const ControlPanel({
    super.key,
    required this.playbackState,
    required this.speed,
    required this.onPlay,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    required this.onPrev,
    required this.onNext,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 语速调节
            Row(
              children: [
                Icon(Icons.speed, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '语速',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: speed,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    label: '${speed.toStringAsFixed(1)}x',
                    onChanged: onSpeedChanged,
                  ),
                ),
                Text(
                  '${speed.toStringAsFixed(1)}x',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // 播放控制按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 上一段
                _ControlButton(
                  icon: Icons.skip_previous_rounded,
                  onPressed: onPrev,
                ),
                const SizedBox(width: 8),
                // 停止
                _ControlButton(
                  icon: Icons.stop_rounded,
                  onPressed: onStop,
                  isActive: playbackState == PlaybackState.playing ||
                      playbackState == PlaybackState.paused,
                ),
                const SizedBox(width: 12),
                // 播放/暂停
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    iconSize: 36,
                    padding: const EdgeInsets.all(12),
                    icon: Icon(
                      playbackState == PlaybackState.playing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: theme.colorScheme.onPrimary,
                    ),
                    onPressed: () {
                      switch (playbackState) {
                        case PlaybackState.stopped:
                        case PlaybackState.loading:
                          onPlay();
                          break;
                        case PlaybackState.playing:
                          onPause();
                          break;
                        case PlaybackState.paused:
                          onResume();
                          break;
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                _ControlButton(
                  icon: Icons.skip_next_rounded,
                  onPressed: onNext,
                ),
                const SizedBox(width: 8),
                // 下一段
                _ControlButton(
                  icon: Icons.replay_10_rounded,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Opacity(
      opacity: isActive ? 1.0 : 0.4,
      child: IconButton(
        icon: Icon(icon, size: 28),
        color: theme.colorScheme.onSurface,
        onPressed: isActive ? onPressed : null,
      ),
    );
  }
}
