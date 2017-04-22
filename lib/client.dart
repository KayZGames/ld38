library client;

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
    addEntity([new Position(maxX - 2, maxY - 2), new Slime()]);
    addEntity([new Position(maxX - 1, maxY - 2), new Slime()]);
    addEntity([new Position(maxX - 1, maxY - 1), new Slime()]);

    addEntity([new Road(1, 1, 2, 1)]);

    addEntity([new Road(1, 3, 2, 1)]);
    addEntity([new Road(2, 1, 3, 3)]);
    addEntity([new Road(1, 3, 3, 3)]);

    addEntity([new Road(1, 4, 2, 2)]);
    addEntity([new Road(2, 2, 3, 4)]);
    addEntity([new Road(1, 4, 3, 4)]);

  }

  Map<int, List<EntitySystem>> getSystems() {
    return {
      GameBase.rendering: [
        new MouseInputSystem(canvas),
        new CanvasCleaningSystem(canvas, fillStyle: 'black'),
        new MapRenderingSystem(ctx, spriteSheet),
        new RoadRenderingSystem(ctx),
        new SlimeRenderingSystem(ctx),
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
