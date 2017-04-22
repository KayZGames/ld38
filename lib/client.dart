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
    Queue path = mapManager.pathfinder.findPathSync(mapManager.getTile(1,1), mapManager.getTile(2, 2));
    print(path);
    path = mapManager.pathfinder.findPathSync(mapManager.getTile(6,2), mapManager.getTile(3, 4));
    print(path);

    addEntity([new Road(1, 1, 3, 1)]);
    addEntity([new Road(1, 2, 3, 2)]);

    addEntity([new Road(7, 7, 7, 8)]);
    addEntity([new Road(7, 8, 8, 8)]);
    addEntity([new Road(8, 8, 9, 8)]);

    addEntity([new Position(7, 7), new Building('crashed_ship')]);
    addEntity([new Position(7, 8), new Building('road_sign')]);
    addEntity([new Position(9, 8), new Building('road_sign')]);
  }

  Map<int, List<EntitySystem>> getSystems() {
    return {
      GameBase.rendering: [
        new MouseInputSystem(canvas),
        new CanvasCleaningSystem(canvas, fillStyle: 'black'),
        new MapRenderingSystem(ctx, spriteSheet),
        new RoadRenderingSystem(ctx, spriteSheet),
        new BuildingRenderingSystem(ctx, spriteSheet),
        new SlimeRenderingSystem(ctx),
//        new DebugCoordRenderingSystem(ctx),
        new FpsRenderingSystem(ctx, fillStyle: 'white'),
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
  }


}
