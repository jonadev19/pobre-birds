import 'dart:math';

enum PlayerSprite {
  pinkRound('alienPink_round.png', 'Rosa'),
  blueRound('alienBlue_round.png', 'Azul'),
  greenRound('alienGreen_round.png', 'Verde'),
  yellowRound('alienYellow_round.png', 'Amarilla');

  const PlayerSprite(this.fileName, this.displayName);

  final String fileName;
  final String displayName;

  static PlayerSprite random() =>
      values[Random().nextInt(values.length)];
}
