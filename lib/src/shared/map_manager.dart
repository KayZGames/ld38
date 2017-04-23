part of shared;

class MapManager extends Manager {
  TerrainMap map;
  RoadMap roadMap;
  AStar<TerrainTile> pathfinder;
  AStar<TerrainTile> roadPathfinder;
  bool firstRoadSearch = true;
  MapManager() : map = new TerrainMap() {
    roadMap = new RoadMap(map);
    pathfinder = new AStar<TerrainTile>(map);
    roadPathfinder = new AStar<TerrainTile>(roadMap);
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

  List<TerrainTile> getRoadRoute(int startX, int startY, int endX, int endY) {
    final patrolStartTile = getTile(startX, startY);
    final patrolEndTile = getTile(endX, endY);
    // something something lazy
    if (firstRoadSearch) {
      roadPathfinder.findPathSync(patrolStartTile, patrolEndTile).toList();
      firstRoadSearch = false;
    }
    return roadPathfinder.findPathSync(patrolStartTile, patrolEndTile).toList();
  }

  TerrainTile getRoadSignTile(int x, int y) =>
      getTile(y % 2 == 0 ? x + 1 : x, y + 1);

  Entity createBuilding(int x, int y, String buildingId) {
    final building = world
        .createAndAddEntity([new GridPosition(x, y), new Building(buildingId)]);
    getTile(x, y).building = buildingId;
    getTile(x, y).hasRoad = true;
    if (buildingId != 'road_sign') {
      final roadSignTile = getRoadSignTile(x, y);
      world.createAndAddEntity(
          [new RoadFragment(x, y, roadSignTile.x, roadSignTile.y)]);

      if (roadSignTile.building == null) {
        world.createAndAddEntity([
          new GridPosition(roadSignTile.x, roadSignTile.y),
          new Building('road_sign')
        ]);
        roadSignTile.building = 'road_sign';
        roadSignTile.hasRoad = true;
      } else if (roadSignTile.building != 'road_sign') {
        throw 'encountered unexpected building ${roadSignTile
            .building} when trying to place road_sign';
      }
    }
    return building;
  }

  void registerRoad(RoadFragment roadFragment) {
    getTile(roadFragment.startX, roadFragment.startY).hasRoad = true;
    getTile(roadFragment.endX, roadFragment.endY).hasRoad = true;
  }
}

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

class RoadMap implements Graph<TerrainTile> {
  final TerrainMap map;
  RoadMap(this.map);

  Iterable<TerrainTile> get allNodes =>
      map.allNodes.where((tile) => tile.hasRoad);
  num getDistance(TerrainTile a, TerrainTile b) => 1;
  num getHeuristicDistance(TerrainTile a, TerrainTile b) =>
      map.getHeuristicDistance(a, b);
  Iterable<TerrainTile> getNeighboursOf(TerrainTile node) =>
      map.getNeighboursOf(node).where((tile) => tile.hasRoad);
}
