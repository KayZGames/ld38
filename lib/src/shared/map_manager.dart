part of shared;

class MapManager extends Manager {
  TerrainMap map;
  AStar<TerrainTile> pathfinder;
  MapManager() : map = new TerrainMap() {
    pathfinder = new AStar<TerrainTile>(map);
  }

  TerrainTile getTile(int x, int y) => map.map[y][x];
}

enum TileType { empty, water, carbon }

class TerrainTile extends Object with Node {
  int x, y;
  TileType type;
  TerrainTile(this.x, this.y, this.type);

  @override
  String toString() => '$x:$y - $type';
}

class TerrainMap implements Graph<TerrainTile> {
  final List<List<TerrainTile>> map = new List.generate(
      maxY, (y) => new List.generate(maxX, (x) => _generateTile(x, y)));

  Iterable<TerrainTile> get allNodes => map.expand((rows) => rows).toList();
  num getDistance(TerrainTile a, TerrainTile b) => 1;
  num getHeuristicDistance(TerrainTile a, TerrainTile b) => (a.y - b.y).abs() + (a.x - b.x).abs();
  Iterable<TerrainTile> getNeighboursOf(TerrainTile node) {
    List<TerrainTile> result = [];
    final x = node.x;
    final y = node.y;
    if (x - 1 >= 0) {
      result.add(map[y][x - 1]);
    }
    if (x + 1 < maxX) {
      result.add(map[y][x + 1]);
    }
    if (y % 2 == 0) {
      if (y > 0) {
        result.add(map[y - 1][x]);
        if (x + 1 < maxX) {
          result.add(map[y - 1][x + 1]);
        }
      }
      if (y + 1 < maxY) {
        result.add(map[y + 1][x]);
        if (x + 1 < maxX) {
          result.add(map[y + 1][x + 1]);
        }
      }
    } else {
      if (y > 0) {
        result.add(map[y - 1][x]);
        if (x > 0) {
          result.add(map[y - 1][x - 1]);
        }
      }
      if (y + 1 < maxY) {
        result.add(map[y + 1][x]);
        if (x > 0) {
          result.add(map[y + 1][x - 1]);
        }
      }
    }
    return result;
  }

  static TerrainTile _generateTile(int x, int y) {
    final value = random.nextDouble();
    if (value < 0.02) {
      return new TerrainTile(x, y, TileType.water);
    } else if (value < 0.05) {
      return new TerrainTile(x, y, TileType.carbon);
    }
    return new TerrainTile(x, y, TileType.empty);
  }
}
