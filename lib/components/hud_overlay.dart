import 'dart:ui';

import 'package:flutter/material.dart';

import 'game.dart';
import 'pause_overlay.dart';

class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});

  final MyPhysicsGame game;

  static const overlayId = 'hudOverlay';

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !game.hasStarted,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: IconButton(
                    iconSize: 28,
                    splashRadius: 30,
                    color: Colors.white,
                    icon: const Icon(Icons.pause_rounded),
                    onPressed: () {
                      if (game.isPaused) {
                        return;
                      }
                      game.pauseGame();
                      if (!game.overlays.isActive(PauseOverlay.overlayId)) {
                        game.overlays.add(PauseOverlay.overlayId);
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
