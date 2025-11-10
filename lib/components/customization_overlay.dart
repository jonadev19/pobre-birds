import 'dart:ui';

import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';

import '../assets/player_sprites.dart';
import 'game.dart';

class CustomizationOverlay extends StatefulWidget {
  const CustomizationOverlay({super.key, required this.game});

  final MyPhysicsGame game;

  static const overlayId = 'customizationOverlay';

  @override
  State<CustomizationOverlay> createState() => _CustomizationOverlayState();
}

class _CustomizationOverlayState extends State<CustomizationOverlay> {
  late PlayerSprite _selection = widget.game.selectedPlayerSprite;

  void _close() {
    widget.game.overlays.remove(CustomizationOverlay.overlayId);
  }

  void _handleSelect(PlayerSprite color) {
    if (!widget.game.assetsReady) {
      return;
    }
    widget.game.selectPlayerSprite(color);
    setState(() => _selection = color);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87.withValues(alpha: 0.65),
      child: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final scale = (constraints.maxWidth / 600).clamp(0.75, 1.1);
              final tileSize = 120.0 * scale;

              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 520 * scale,
                  maxHeight: 500 * scale,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade900.withValues(alpha: 0.8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(24 * scale),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'PERSONALIZA TU ALIEN',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _close,
                                  icon: const Icon(Icons.close, color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: widget.game.assetsReady
                                  ? GridView.count(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 18,
                                      crossAxisSpacing: 18,
                                      childAspectRatio: 0.95,
                                      children: [
                                        for (final color in PlayerSprite.values)
                                          _SkinTile(
                                            color: color,
                                            isSelected: color == _selection,
                                            onTap: () => _handleSelect(color),
                                            sprite: widget.game.playerSpriteFor(color),
                                            tileSize: tileSize,
                                          ),
                                      ],
                                    )
                                  : const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tu selección se aplicará al siguiente intento.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SkinTile extends StatelessWidget {
  const _SkinTile({
    required this.color,
    required this.isSelected,
    required this.onTap,
    required this.sprite,
    required this.tileSize,
  });

  final PlayerSprite color;
  final bool isSelected;
  final VoidCallback onTap;
  final Sprite sprite;
  final double tileSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      splashColor: Colors.white24,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color:
                isSelected ? Colors.white : Colors.white.withValues(alpha: 0.25),
            width: isSelected ? 3 : 1.5,
          ),
          color: Colors.white.withValues(alpha: 0.05),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: tileSize,
              child: FittedBox(
                fit: BoxFit.contain,
                child: SpriteWidget(
                  sprite: sprite,
                  anchor: Anchor.center,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              color.displayName,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
