// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_kenney_xml/flame_kenney_xml.dart';
import 'package:flutter/material.dart';

import '../assets/enemy_sprites.dart';
import '../assets/player_sprites.dart';
import 'background.dart';
import 'brick.dart';
import 'enemy.dart';
import 'ground.dart';
import 'player.dart';

enum GamePhase { splash, playing }

class MyPhysicsGame extends Forge2DGame {
  MyPhysicsGame()
    : super(
        gravity: Vector2(0, 10),
        camera: CameraComponent.withFixedResolution(width: 800, height: 600),
      );

  late final XmlSpriteSheet playerSprites;
  late final XmlSpriteSheet enemySprites;
  late final XmlSpriteSheet elements;
  late final XmlSpriteSheet tiles;
  late final Sprite _backgroundSprite;

  GamePhase _phase = GamePhase.splash;
  bool _assetsReady = false;
  bool _hasStarted = false;
  bool _isPaused = false;
  PlayerSprite _selectedPlayerSprite = PlayerSprite.random();

  @override
  FutureOr<void> onLoad() async {
    final backgroundImage = await images.load('colored_grass.png');
    playerSprites = await XmlSpriteSheet.load(
      imagePath: 'spritesheet_players.png',
      xmlPath: 'spritesheet_players.xml',
    );
    enemySprites = await XmlSpriteSheet.load(
      imagePath: 'spritesheet_enemies.png',
      xmlPath: 'spritesheet_enemies.xml',
    );
    elements = await XmlSpriteSheet.load(
      imagePath: 'spritesheet_elements.png',
      xmlPath: 'spritesheet_elements.xml',
    );
    tiles = await XmlSpriteSheet.load(
      imagePath: 'spritesheet_tiles.png',
      xmlPath: 'spritesheet_tiles.xml',
    );
    _backgroundSprite = Sprite(backgroundImage);
    _assetsReady = true;

    return super.onLoad();
  }

  Future<void> startGame() async {
    if (!_assetsReady || _hasStarted) {
      return;
    }
    _hasStarted = true;
    _phase = GamePhase.playing;
    await _buildWorld();
  }

  bool get assetsReady => _assetsReady;
  bool get hasStarted => _hasStarted;
  bool get isPaused => _isPaused;

  PlayerSprite get selectedPlayerSprite => _selectedPlayerSprite;

  void selectPlayerSprite(PlayerSprite sprite) {
    _selectedPlayerSprite = sprite;
  }

  Sprite playerSpriteFor(PlayerSprite sprite) =>
      playerSprites.getSprite(sprite.fileName);

  Sprite enemySpriteFor(EnemySprite sprite) =>
      enemySprites.getSprite(sprite.fileName);

  Future<void> addGround() {
    return world.addAll([
      for (
        var x = camera.visibleWorldRect.left;
        x < camera.visibleWorldRect.right + groundSize;
        x += groundSize
      )
        Ground(
          Vector2(x, (camera.visibleWorldRect.height - groundSize) / 2),
          tiles.getSprite('grass.png'),
        ),
    ]);
  }

  final _random = Random();

  Future<void> addBricks() async {
    for (var i = 0; i < 5; i++) {
      final type = BrickType.randomType;
      final size = BrickSize.randomSize;
      await world.add(
        Brick(
          type: type,
          size: size,
          damage: BrickDamage.some,
          position: Vector2(
            camera.visibleWorldRect.right / 3 +
                (_random.nextDouble() * 5 - 2.5),
            0,
          ),
          sprites: brickFileNames(
            type,
            size,
          ).map((key, filename) => MapEntry(key, elements.getSprite(filename))),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> addPlayer() async => world.add(
    Player(
      Vector2(camera.visibleWorldRect.left * 2 / 3, 0),
      playerSpriteFor(_selectedPlayerSprite),
    ),
  );

  Future<void> pauseGame() async {
    if (!_hasStarted || _isPaused) {
      return;
    }
    _isPaused = true;
    pauseEngine();
  }

  Future<void> resumeGame() async {
    if (!_isPaused) {
      return;
    }
    _isPaused = false;
    resumeEngine();
  }

  Future<void> restartGame() async {
    if (!_assetsReady) {
      return;
    }
    await resumeGame();
    await _clearWorld();
    _phase = GamePhase.playing;
    _hasStarted = true;
    await _buildWorld();
  }

  Future<void> resetToMenu() async {
    await resumeGame();
    await _clearWorld();
    _phase = GamePhase.splash;
    _hasStarted = false;
    enemiesFullyAdded = false;
  }

  Future<void> _buildWorld() async {
    await world.add(Background(sprite: _backgroundSprite));
    await addGround();
    enemiesFullyAdded = false;
    unawaited(addBricks().then((_) => addEnemies()));
    await addPlayer();
  }

  Future<void> _clearWorld() async {
    final components = world.children.toList();
    for (final component in components) {
      component.removeFromParent();
    }
  }

  @override
  void update(double dt) {
    if (_phase != GamePhase.playing) {
      return;
    }
    super.update(dt);
    if (isMounted &&
        world.children.whereType<Player>().isEmpty &&
        world.children.whereType<Enemy>().isNotEmpty) {
      addPlayer();
    }
    if (isMounted &&
        enemiesFullyAdded &&
        world.children.whereType<Enemy>().isEmpty &&
        world.children.whereType<TextComponent>().isEmpty) {
      world.addAll(
        [
          (position: Vector2(0.5, 0.5), color: Colors.white),
          (position: Vector2.zero(), color: Colors.orangeAccent),
        ].map(
          (e) => TextComponent(
            text: 'You win!',
            anchor: Anchor.center,
            position: e.position,
            textRenderer: TextPaint(
              style: TextStyle(color: e.color, fontSize: 16),
            ),
          ),
        ),
      );
    }
  }

  var enemiesFullyAdded = false;

  Future<void> addEnemies() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    for (var i = 0; i < 3; i++) {
      await world.add(
        Enemy(
          Vector2(
            camera.visibleWorldRect.right / 3 +
                (_random.nextDouble() * 7 - 3.5),
            (_random.nextDouble() * 3),
          ),
          enemySpriteFor(EnemySprite.random()),
        ),
      );
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    enemiesFullyAdded = true;
  }
}
