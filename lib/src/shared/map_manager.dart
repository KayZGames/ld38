part of shared;


class MapManager extends Manager {

  final List<List<Tile>> map = new List.generate(100, (_) => new List.generate(100, _generateTile));


  static Tile _generateTile(_) {
    final value = random.nextDouble();
    if (value < 0.05) {
      return Tile.water;
    } else if (value < 0.20) {
      return Tile.carbon;
    }
    return Tile.empty;
  }
}

enum Tile {
  empty,
  water,
  carbon
}