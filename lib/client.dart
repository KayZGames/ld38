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
    var mapManager = world.getManager(MapManager) as MapManager;
    var hq = mapManager.createBuilding(maxX ~/ 2, maxY ~/ 2, 'crashed_ship');
    var gameStateManager =
        world.getManager(GameStateManager) as GameStateManager;
    var tagManager = world.getManager(TagManager) as TagManager;
    tagManager.register(hq, hqTag);

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
        new PatrolAction(),
        new CanvasCleaningSystem(canvas),
        new MapRenderingSystem(ctx, spriteSheet),
        new MousePositionHighlightingSystem(ctx),
        new RoadFragmentRenderingSystem(ctx, spriteSheet),
        new BuildingRenderingSystem(ctx, spriteSheet),
        new SlimeRenderingSystem(ctx),
        new BuildingSelectionRenderingSystem(ctx, spriteSheet),
//        new DebugCoordRenderingSystem(ctx),
        new FpsRenderingSystem(ctx, fillStyle: 'white'),
        new BuildRoadActionSystem(),
        new BuildRoadExecutionSystem(),
        new BuildRoadAbortSystem(),
        new BuildBuildingExecutionAction(),
        new FinalizeActionSystem(),
        new WayPointVisitSystem(),
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
