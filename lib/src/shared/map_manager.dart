part of shared;

class MapManager extends Manager {
  TerrainMap map;
  AStar<TerrainTile> pathfinder;
  MapManager() : map = new TerrainMap() {
    pathfinder = new AStar<TerrainTile>(map);
  }

  TerrainTile getTile(int x, int y) => map.map[y][x];
  List<TerrainTile> findPath(BuildRoadAction bra) {
    var endTile = getTile(bra.endX, bra.endY);
    if (endTile.type == TileType.water) return [];
    if (endTile.hasRoad && endTile.building != 'road_sign') return [];
    if (endTile.building != null && endTile.building != 'road_sign') return [];
    return pathfinder
        .findPathSync(getTile(bra.startX, bra.startY), endTile)
        .toList();
  }

  void createBuilding(int x, int y, String buildingId) {
    world.createAndAddEntity([new Position(x, y), new Building(buildingId)]);
    getTile(x, y).building = buildingId;
    getTile(x, y).hasRoad = true;
    if (buildingId != 'road_sign') {
      var roadSignX = y % 2 == 0 ? x + 1 : x;
      world.createAndAddEntity([new RoadFragment(x, y, roadSignX, y + 1)]);

      var roadSignTile = getTile(roadSignX, y + 1);
      if (roadSignTile.building == null) {
        world.createAndAddEntity(
            [new Position(roadSignX, y + 1), new Building('road_sign')]);
        roadSignTile.building = 'road_sign';
        roadSignTile.hasRoad = true;
      } else if (roadSignTile.building != 'road_sign') {
        throw 'encountered unexpected building ${roadSignTile
            .building} when trying to place road_sign';
      }
    }
  }

  void registerRoad(RoadFragment roadFragment) {
    getTile(roadFragment.startX, roadFragment.startY).hasRoad = true;
    getTile(roadFragment.endX, roadFragment.endY).hasRoad = true;
  }
}

enum TileType { empty, water, carbon }

class TerrainTile extends Object with Node {
  int x, y;
  int cx, cy, cz;
  TileType type;
  String building;
  bool hasRoad = false;
  TerrainTile(this.x, this.y, this.type) {
    cx = x - (y + (y % 2)) ~/ 2;
    cz = y;
    cy = -cx - cz;
  }

  @override
  String toString() => '$x:$y - $type';
}

class TerrainMap implements Graph<TerrainTile> {
  final List<List<TerrainTile>> map = new List.generate(
      maxY, (y) => new List.generate(maxX, (x) => _generateTile(x, y)));

  Iterable<TerrainTile> get allNodes => map.expand((rows) => rows).toList();
  num getDistance(TerrainTile a, TerrainTile b) {
    if (a == b) return 0;
    if (b.building == 'road_sign') return 1;
    if (b.type == TileType.water) return null;
    if (b.hasRoad) return null;
    return 1;
  }

  num getHeuristicDistance(TerrainTile a, TerrainTile b) =>
      ((a.cx - b.cx).abs() + (a.cy - b.cy).abs() + (a.cz - b.cz).abs()) / 2;
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
    if ((maxX ~/ 2 - x).abs() <= 2 || (maxY ~/ 2 - y).abs() <= 2) {
      return new TerrainTile(x, y, TileType.empty);
    }
    final value = random.nextDouble();
    if (value < 0.06) {
      return new TerrainTile(x, y, TileType.water);
    } else if (value < 0.15) {
      return new TerrainTile(x, y, TileType.carbon);
    }
    return new TerrainTile(x, y, TileType.empty);
  }
}
