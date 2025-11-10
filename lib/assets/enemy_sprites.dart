import 'dart:math';

enum EnemySprite {
  pinkSquare('alienPink_square.png', false),
  blueSquare('alienBlue_square.png', false),
  greenSquare('alienGreen_square.png', false),
  yellowSquare('alienYellow_square.png', false),
  pinkBoss('alienPink_suit.png', true),
  blueBoss('alienBlue_suit.png', true),
  greenBoss('alienGreen_suit.png', true),
  yellowBoss('alienYellow_suit.png', true);

  const EnemySprite(this.fileName, this.isBoss);

  final String fileName;
  final bool isBoss;

  static EnemySprite random() =>
      values[Random().nextInt(values.length)];
}
