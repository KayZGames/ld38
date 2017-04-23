part of shared;

class ActionTriggerSystem extends VoidEntitySystem {
  bool triggerAction = false;
  bool abortAction = false;
  GameStateManager gsm;
  MapManager mapManager;
  TagManager tagManager;

  @override
  void processSystem() {
    final selectedCoord = gsm.selectedMapCoord;
    final tile = mapManager.getTile(selectedCoord.x, selectedCoord.y);
    var currentAction = tagManager.getEntity(currentActionTag);
    if (currentAction == null) {
      if (tile.building == 'road_sign') {
        var action = world.createAndAddEntity(
            [new BuildRoadAction(tile.x, tile.y, tile.x, tile.y)]);
        tagManager.register(action, currentActionTag);
      }
    } else if (abortAction) {
      currentAction.addComponent(new AbortAction());
      currentAction.changedInWorld();
    } else {
      currentAction.addComponent(new ExecuteAction());
      currentAction.changedInWorld();
    }
  }

  @override
  void end() {
    triggerAction = false;
    abortAction = false;
  }

  @override
  bool checkProcessing() => triggerAction || abortAction;
}

class BuildRoadActionSystem extends EntityProcessingSystem {
  MapManager mapManager;
  GameStateManager gsm;
  Mapper<BuildRoadAction> bram;
  GroupManager gm;

  BuildRoadActionSystem()
      : super(Aspect.getAspectForAllOf([BuildRoadAction]).exclude(
            [AbortAction, ExecuteAction]));

  @override
  void processEntity(Entity entity) {
    final action = bram[entity];

    action.endX = gsm.selectedMapCoord.x;
    action.endY = gsm.selectedMapCoord.y;

    final path = mapManager.findPath(action);
    final oldRoad = gm.getEntities(temporaryRoadGroup);
    if (oldRoad != null) {
      oldRoad.forEach((roadFragment) => roadFragment.deleteFromWorld());
    }
    if (path.length > 1) {
      for (int i = 0; i < path.length - 1; i++) {
        TerrainTile roadStart;
        TerrainTile roadEnd;
        if (path[i].y < path[i + 1].y || path[i].x < path[i + 1].x) {
          roadStart = path[i];
          roadEnd = path[i + 1];
        } else {
          roadStart = path[i + 1];
          roadEnd = path[i];
        }
        var e = world.createAndAddEntity([
          new RoadFragment(roadStart.x, roadStart.y, roadEnd.x, roadEnd.y,
              temp: true)
        ]);
        gm.add(e, temporaryRoadGroup);
      }
    }
  }
}

class BuildRoadAbortSystem extends EntityProcessingSystem {
  GroupManager gm;
  BuildRoadAbortSystem()
      : super(Aspect.getAspectForAllOf([BuildRoadAction, AbortAction]));

  @override
  void processEntity(Entity entity) {
    entity.deleteFromWorld();
    final oldRoad = gm.getEntities(temporaryRoadGroup);
    if (oldRoad != null) {
      oldRoad.forEach((roadFragment) => roadFragment.deleteFromWorld());
    }
  }
}

class BuildRoadExecutionSystem extends EntityProcessingSystem {
  GroupManager gm;
  Mapper<RoadFragment> rfm;
  GameStateManager gsm;
  MapManager mapManager;

  BuildRoadExecutionSystem()
      : super(Aspect.getAspectForAllOf(
            [BuildRoadAction, ExecuteAction]).exclude([AbortAction]));

  @override
  void processEntity(Entity entity) {
    entity.deleteFromWorld();
    final newRoad = gm.getEntities(temporaryRoadGroup);
    if (newRoad.length > 0) {
      newRoad.forEach((fragment) {
        gm.remove(fragment, temporaryRoadGroup);
        rfm[fragment].temp = false;
        mapManager.registerRoad(rfm[fragment]);
      });
      mapManager.createBuilding(
          gsm.selectedMapCoord.x, gsm.selectedMapCoord.y, 'road_sign');
    }
  }
}
