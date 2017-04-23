library client;

import 'dart:collection';
import 'dart:html';
export 'dart:html';
import 'package:ld38/shared.dart';
import 'package:gamedev_helpers/gamedev_helpers.dart';
export 'package:gamedev_helpers/gamedev_helpers.dart';
//part 'src/client/systems/name.dart';
part 'src/client/systems/events.dart';
part 'src/client/systems/rendering.dart';

class Game extends GameBase {
  Game() : super('ld38', '#game', 800, 600, bodyDefsName: null);

  void createEntities() {
    addEntity([new Position(1, 1), new Slime()]);
    addEntity([new Position(3, 1), new Slime()]);
    addEntity([new Position(maxX - 2, maxY - 2), new Slime()]);
    addEntity([new Position(maxX - 1, maxY - 2), new Slime()]);
    addEntity([new Position(maxX - 1, maxY - 1), new Slime()]);

    var mapManager = world.getManager(MapManager) as MapManager;
    mapManager.createBuilding(maxX ~/ 2, maxY ~/ 2, 'crashed_ship');
    var gameStateManager =
        world.getManager(GameStateManager) as GameStateManager;

    gameStateManager.cameraX =
        ((maxX / 2 * pixelPerWidth * gameStateManager.zoom) - 800 / 2) /
            gameStateManager.zoom + pixelPerWidth/2;
    gameStateManager.cameraY =
        ((maxY / 2 * verticalDistance * gameStateManager.zoom) - 600 / 2) /
            gameStateManager.zoom + pixelPerHeight/2;
  }

  Map<int, List<EntitySystem>> getSystems() {
    return {
      GameBase.rendering: [
        new MouseInputSystem(canvas),
        new ActionTriggerSystem(),
        new CanvasCleaningSystem(canvas),
        new MapRenderingSystem(ctx, spriteSheet),
        new MousePositionHighlightingSystem(ctx),
        new RoadFragmentRenderingSystem(ctx, spriteSheet),
        new BuildingRenderingSystem(ctx, spriteSheet),
        new SlimeRenderingSystem(ctx),
        new DebugCoordRenderingSystem(ctx),
        new FpsRenderingSystem(ctx, fillStyle: 'white'),
        new BuildRoadActionSystem(),
        new BuildRoadExecutionSystem(),
        new BuildRoadAbortSystem(),
      ],
      GameBase.physics: [
        // add at least one
      ]
    };
  }

  @override
  onInit() {
    world.addManager(new GameStateManager());
    world.addManager(new MapManager());
    world.addManager(new GroupManager());
    world.addManager(new TagManager());
  }
}
