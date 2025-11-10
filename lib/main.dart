// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'components/customization_overlay.dart';
import 'components/game.dart';
import 'components/hud_overlay.dart';
import 'components/main_menu_overlay.dart';
import 'components/pause_overlay.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(
    GameWidget<MyPhysicsGame>.controlled(
      gameFactory: MyPhysicsGame.new,
      overlayBuilderMap: {
        MainMenuOverlay.overlayId: (context, game) =>
            MainMenuOverlay(game: game),
        CustomizationOverlay.overlayId: (context, game) =>
            CustomizationOverlay(game: game),
        HudOverlay.overlayId: (context, game) => HudOverlay(game: game),
        PauseOverlay.overlayId: (context, game) => PauseOverlay(game: game),
      },
      initialActiveOverlays: const [MainMenuOverlay.overlayId],
    ),
  );
}
