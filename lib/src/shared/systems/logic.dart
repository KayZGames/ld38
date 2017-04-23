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
      } else if (tile.building == null && !tile.hasRoad) {
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

    if (gsm.selectedMapCoord.x != action.endX ||
        gsm.selectedMapCoord.y != action.endY) {
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
  Mapper<BuildRoadAction> bram;
  Mapper<GridPosition> pm;
  GameStateManager gsm;
  MapManager mapManager;
  TagManager tm;

  BuildRoadExecutionSystem()
      : super(Aspect.getAspectForAllOf(
            [BuildRoadAction, ExecuteAction]).exclude([AbortAction]));

  @override
  void processEntity(Entity entity) {
    final action = bram[entity];
    final newRoad = gm.getEntities(temporaryRoadGroup);
    if (newRoad.length > 0) {
      newRoad.forEach((fragment) {
        gm.remove(fragment, temporaryRoadGroup);
        rfm[fragment].temp = false;
        mapManager.registerRoad(rfm[fragment]);
      });
      mapManager.createBuilding(action.endX, action.endY, 'road_sign');
      final hqPos = pm[tm.getEntity(hqTag)];
      world.createAndAddEntity([
        new Slime([0, 120, 240][random.nextInt(3)]),
        new Age(world.time()),
        new GridPosition(hqPos.x, hqPos.y),
        new Patrol(action.startX, action.startY, action.endX, action.endY)
      ]);
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
    }, orElse: () => null);
    if (buildingToBuild != null) {
      mapManager.createBuilding(action.x, action.y, buildingToBuild.type);
    }
  }
}

class PatrolAction extends EntityProcessingSystem {
  Mapper<GridPosition> positionMapper;
  Mapper<Patrol> patrolMapper;
  MapManager mapManager;
  PatrolAction()
      : super(Aspect
            .getAspectForAllOf([GridPosition, Patrol]).exclude([WayPoints]));

  @override
  void processEntity(Entity entity) {
    final pos = positionMapper[entity];
    final patrol = patrolMapper[entity];

    final patrolRoute = mapManager.getRoadRoute(
        patrol.startX, patrol.startY, patrol.endX, patrol.endY);
    final patrolMiddle = patrolRoute[patrolRoute.length ~/ 2];

    if (patrolMiddle.x != pos.x || patrolMiddle.y != pos.y) {
      final route =
          mapManager.getRoadRoute(pos.x, pos.y, patrolMiddle.x, patrolMiddle.y);
      final List<Point> waypoints = [];
      route.reversed.forEach((tile) {
        final x = convertX(tile.x, tile.y) + pixelPerWidth / 2;
        final y = convertY(tile.y) + pixelPerHeight / 2;
        waypoints.add(new Point(x, y));
      });
      entity.addComponent(new WayPoints(waypoints));
      entity.addComponent(new PixelPosition(
          convertX(pos.x, pos.y) + pixelPerWidth / 2,
          convertY(pos.y) + pixelPerHeight / 2));
      entity.removeComponent(GridPosition);
      entity.changedInWorld();
    }
  }
}

class WayPointVisitSystem extends EntityProcessingSystem {
  Mapper<PixelPosition> pm;
  Mapper<WayPoints> wm;
  Mapper<Age> am;

  WayPointVisitSystem()
      : super(Aspect.getAspectForAllOf([WayPoints, PixelPosition, Age]));

  @override
  void processEntity(Entity entity) {
    final wayPoints = wm[entity];
    final pos = pm[entity];
    final a = am[entity];

    final nextWaypoint = wayPoints.values.last;

    final diffX = pos.x - nextWaypoint.x;
    final diffY = pos.y - nextWaypoint.y;

    final angle = atan2(diffY, diffX);

    final age = world.time() - a.birthTime;
    final moveDistance = max(0.0, sin(age * 5) + 0.2) * world.delta * 50;

    pos.x -= diffX.sign * min(diffX.abs(), moveDistance * cos(angle).abs());
    pos.y -= diffY.sign * min(diffY.abs(), moveDistance * sin(angle).abs());

    if (pos.x == nextWaypoint.x && pos.y == nextWaypoint.y) {
      wayPoints.values.removeLast();
      if (wayPoints.values.length == 0) {
        entity.removeComponent(WayPoints);
        entity.changedInWorld();
      }
    }
  }
}
