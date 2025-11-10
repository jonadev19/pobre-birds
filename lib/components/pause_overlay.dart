import 'dart:ui';

import 'package:flutter/material.dart';

import 'game.dart';
import 'hud_overlay.dart';
import 'main_menu_overlay.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.game});

  final MyPhysicsGame game;

  static const overlayId = 'pauseOverlay';

  Future<void> _handleResume() async {
    game.resumeGame();
    game.overlays.remove(PauseOverlay.overlayId);
  }

  Future<void> _handleRestart() async {
    await game.restartGame();
    game.overlays.remove(PauseOverlay.overlayId);
  }

  Future<void> _handleExitToMenu() async {
    await game.resetToMenu();
    game.overlays
      ..remove(PauseOverlay.overlayId)
      ..remove(HudOverlay.overlayId);
    if (!game.overlays.isActive(MainMenuOverlay.overlayId)) {
      game.overlays.add(MainMenuOverlay.overlayId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade900.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 28,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'PAUSA',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: Colors.white,
                              letterSpacing: 4,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 28),
                      _PauseButton(
                        label: 'CONTINUAR',
                        onPressed: _handleResume,
                        filled: true,
                      ),
                      const SizedBox(height: 16),
                      _PauseButton(
                        label: 'REINICIAR NIVEL',
                        onPressed: _handleRestart,
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: _handleExitToMenu,
                        child: Text(
                          'SALIR AL MENÚ',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white70,
                                letterSpacing: 2,
                              ),
                        ),
                      ),
                    ],
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

class _PauseButton extends StatelessWidget {
  const _PauseButton({
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final child = Center(
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
    );

    if (filled) {
      return SizedBox(
        height: 54,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent.shade400,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          onPressed: onPressed,
          child: child,
        ),
      );
    }

    return SizedBox(
      height: 54,
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.5),
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
