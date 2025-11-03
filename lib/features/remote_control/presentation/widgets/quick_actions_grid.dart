import 'package:flutter/material.dart';

class QuickActionsGrid extends StatelessWidget {
  final VoidCallback onVolumeUp;
  final VoidCallback onVolumeDown;
  final VoidCallback onMute;
  final VoidCallback onPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;

  const QuickActionsGrid({
    super.key,
    required this.onVolumeUp,
    required this.onVolumeDown,
    required this.onMute,
    required this.onPrevious,
    required this.onPlayPause,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Expanded(child: _buildActionButton(Icons.volume_up, 'Vol+', onTap: onVolumeUp)),
          const SizedBox(width: 8),
          Expanded(child: _buildActionButton(Icons.volume_down, 'Vol-', onTap: onVolumeDown)),
          const SizedBox(width: 8),
          Expanded(child: _buildActionButton(Icons.volume_off, 'Mute', onTap: onMute)),
          const SizedBox(width: 8),
          Expanded(child: _buildActionButton(Icons.skip_previous, 'Prev', onTap: onPrevious)),
          const SizedBox(width: 8),
          Expanded(child: _buildActionButton(Icons.play_arrow, 'Play/Pause', 
              icon2: Icons.pause, onTap: onPlayPause)),
          const SizedBox(width: 8),
          Expanded(child: _buildActionButton(Icons.skip_next, 'Next', onTap: onNext)),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, {IconData? icon2, VoidCallback? onTap}) {
    return Material(
      color: const Color(0xFF334155), // slate-700
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon2 != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: const Color(0xFF60a5fa), size: 16),
                      const SizedBox(width: 2),
                      Icon(icon2, color: const Color(0xFF60a5fa), size: 16),
                    ],
                  )
                else
                  Icon(icon, color: const Color(0xFF60a5fa), size: 20),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFd1d5db), // slate-300
                    fontSize: 9,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
