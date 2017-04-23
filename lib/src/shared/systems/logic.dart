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
      var action;
      if (tile.building == 'road_sign') {
        action = world.createAndAddEntity(
            [new BuildRoadAction(tile.x, tile.y, tile.x, tile.y)]);
      } else if (tile.building == null) {
        final roadSignTile = mapManager.getRoadSignTile(tile.x, tile.y);
        if (roadSignTile.type != TileType.water &&
            (roadSignTile.building == null ||
                roadSignTile.building == 'road_sign')) {
          action = world
              .createAndAddEntity([new BuildBuildingAction(tile.x, tile.y)]);
          gsm.buildActionActive = true;
        }
      }
      if (action != null) {
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

    if (gsm.selectedMapCoord.x != action.endX || gsm.selectedMapCoord.y != action.endY) {
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
        gsm.validAction = true;
      } else {
        gsm.validAction = false;
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

class FinalizeActionSystem extends EntityProcessingSystem {
  GameStateManager gsm;
  FinalizeActionSystem()
      : super(Aspect.getAspectForOneOf([ExecuteAction, AbortAction]));

  @override
  void processEntity(Entity entity) {
    entity.deleteFromWorld();
    gsm.validAction = null;
    gsm.buildActionActive = false;
  }
}

class BuildBuildingExecutionAction extends EntityProcessingSystem {
  Mapper<BuildBuildingAction> bbam;
  MapManager mapManager;
  GameStateManager gsm;

  BuildBuildingExecutionAction()
      : super(Aspect.getAspectForAllOf([BuildBuildingAction, ExecuteAction]));

  @override
  void processEntity(Entity entity) {
    final action = bbam[entity];
    final tile = mapManager.getTile(action.x, action.y);
    final baseX = convertX(action.x, action.y) - gsm.cameraX;
    final baseY = convertY(action.y) - gsm.cameraY;
    var buildingToBuild = BuildingType.buildingTypes
        .where((buildingType) => buildingType.allowedTiles.contains(tile.type))
        .firstWhere((buildingType) {
      final x = (baseX + pixelPerWidth * buildingType.x) * gsm.zoom;
      final y = (baseY + pixelPerHeight * buildingType.y) * gsm.zoom;
      final radius = gsm.zoom * pixelPerWidth / 4;
      return gsm.mousePos.distanceTo(new Point(x, y)) < radius;
    }, orElse: null);
    if (buildingToBuild != null) {
      mapManager.createBuilding(action.x, action.y, buildingToBuild.type);
    }
  }
}
