library shared;

import 'dart:collection';
import 'package:gamedev_helpers/gamedev_helpers_shared.dart';
import 'package:a_star/a_star.dart';
part 'src/shared/components.dart';
//part 'src/shared/systems/name.dart';
part 'src/shared/game_state_manager.dart';
part 'src/shared/map_manager.dart';
part 'src/shared/systems/logic.dart';

const maxX = 40;
const maxY = 40;
const String cameraTag = 'camera';
const String currentActionTag = 'currentAction';
const String hqTag = 'HQ';
const String temporaryRoadGroup = 'temporaryRoad';
const double hexSize = pixelPerHeight / 2;
const double pixelPerHeight = 148.0;
const double verticalDistance = pixelPerHeight * 0.75;
const double pixelPerWidth = pixelPerHeight * 1.732 / 2;

num convertX(num x, int y) =>
    y % 2 == 0 ? x * pixelPerWidth : x * pixelPerWidth - 0.5 * pixelPerWidth;
num convertY(num y) => y * verticalDistance;

enum TileType { empty, water, carbon }

class BuildingType {
  static const List<BuildingType> buildingTypes = const [
    const BuildingType(
        0.0, 0.75, 'well', 'Produces water.', const [TileType.water]),
    const BuildingType(
        0.0, 0.25, 'mine', 'Produces carbon.', const [TileType.carbon]),
    const BuildingType(0.5, 0.0, 'house', 'Increases the population limit.',
        const [TileType.empty, TileType.carbon]),
    const BuildingType(
        1.0,
        0.75,
        'breeder',
        'Breeds new slimes, 3 parent slimes required. Requires water.',
        const [TileType.empty, TileType.carbon]),
    const BuildingType(
        1.0,
        0.25,
        'factory',
        'Produces material to repair the spaceship. Requires carbon and water.',
        const [TileType.empty, TileType.carbon]),
  ];

  final double x, y;
  final String type;
  final String desciption;
  final List<TileType> allowedTiles;
  const BuildingType(
      this.x, this.y, this.type, this.desciption, this.allowedTiles);
}
