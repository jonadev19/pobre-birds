// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/game.dart';
import 'components/main_menu_overlay.dart';

void main() {
  runApp(
    GameWidget<MyPhysicsGame>.controlled(
      gameFactory: MyPhysicsGame.new,
      overlayBuilderMap: {
        MainMenuOverlay.overlayId: (context, game) =>
            MainMenuOverlay(game: game),
      },
      initialActiveOverlays: const [MainMenuOverlay.overlayId],
    ),
  );
}
