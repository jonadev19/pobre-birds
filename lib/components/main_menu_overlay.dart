import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'game.dart';

class MainMenuOverlay extends StatefulWidget {
  const MainMenuOverlay({super.key, required this.game});

  final MyPhysicsGame game;

  static const overlayId = 'mainMenuOverlay';

  @override
  State<MainMenuOverlay> createState() => _MainMenuOverlayState();
}

class _MainMenuOverlayState extends State<MainMenuOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
    lowerBound: 0.95,
    upperBound: 1.05,
  )..repeat(reverse: true);
  late final AnimationController _cloudController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 38),
  )..repeat(reverse: true);

  bool _isStarting = false;

  @override
  void dispose() {
    _pulseController.dispose();
    _cloudController.dispose();
    super.dispose();
  }

  Future<void> _handleStart() async {
    if (_isStarting) {
      return;
    }
    setState(() => _isStarting = true);
    await widget.game.startGame();
    if (!mounted) {
      return;
    }
    widget.game.overlays.remove(MainMenuOverlay.overlayId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.blueGrey.shade900.withOpacity(0.35),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;
          final titleStyle = GoogleFonts.luckiestGuy(
            fontSize: isLandscape ? 70 : 82,
            color: Colors.redAccent.shade200,
            letterSpacing: 3,
            shadows: [
              Shadow(
                offset: const Offset(4, 4),
                blurRadius: 10,
                color: Colors.red.shade900.withOpacity(0.8),
              ),
            ],
          );

          return Container(
            color: const Color(0xFF01ADFF),
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _cloudController,
                    builder: (context, child) {
                      final easedValue =
                          Curves.easeInOut.transform(_cloudController.value);
                      final slide = lerpDouble(-0.12, 0.12, easedValue)!;

                      return FractionalTranslation(
                        translation: Offset(slide, 0),
                        child: FractionallySizedBox(
                          widthFactor: 1.4,
                          heightFactor: 1.15,
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Colors.lightBlueAccent.withOpacity(0.1),
                              BlendMode.srcATop,
                            ),
                            child: Image.asset(
                              'assets/sprites/clouds.jpg',
                              fit: BoxFit.cover,
                              alignment: Alignment.centerLeft,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.2),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, safeConstraints) {
                      const baselineHeight = 540;
                      final scaleFactor = (safeConstraints.maxHeight / baselineHeight)
                          .clamp(0.65, 1.0);
                      final titleSize =
                          (isLandscape ? 70 : 82) * scaleFactor;
                      final buttonSize = 180 * scaleFactor;
                      final iconSize = 110 * scaleFactor.clamp(0.8, 1.0);
                      final gapLarge = 48 * scaleFactor;

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isLandscape ? 48 : 24,
                          vertical: isLandscape ? 16 : 24,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isLandscape
                                  ? safeConstraints.maxWidth * 0.7
                                  : safeConstraints.maxWidth,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'CHAFA BIRD',
                                  textAlign: TextAlign.center,
                                  style: titleStyle.copyWith(fontSize: titleSize),
                                ),
                                SizedBox(height: gapLarge),
                                ScaleTransition(
                                  scale: _pulseController,
                                  child: SizedBox(
                                    width: buttonSize,
                                    height: buttonSize,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: const CircleBorder(),
                                        backgroundColor:
                                            Colors.redAccent.shade400,
                                            foregroundColor: Colors.white,
                                            elevation: 12,
                                            padding: EdgeInsets.zero,
                                            side: const BorderSide(
                                              color: Colors.white,
                                              width: 4,
                                            ),
                                      ),
                                      onPressed: _isStarting ? null : _handleStart,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                        horizontal: buttonSize * 0.08,
                                        vertical: buttonSize * 0.12,
                                      ),
                                  child: Center(
                                    child: Transform.translate(
                                      offset: Offset(0, buttonSize * 0.025),
                                      child: Text(
                                        _isStarting ? 'CARGANDO' : 'PLAY',
                                        textAlign: TextAlign.center,
                                        textHeightBehavior:
                                            const TextHeightBehavior(
                                          applyHeightToFirstAscent: false,
                                          applyHeightToLastDescent: false,
                                        ),
                                        style: GoogleFonts.luckiestGuy(
                                          color: Colors.white,
                                          letterSpacing: 3,
                                          fontSize: iconSize * 0.42,
                                          height: 0.9,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
