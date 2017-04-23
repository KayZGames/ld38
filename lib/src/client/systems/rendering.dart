part of client;

class SlimeRenderingSystem extends EntityProcessingSystem {
  GameStateManager gsm;
  Mapper<PixelPosition> pm;
  Mapper<Slime> sm;
  Mapper<Age> am;
  CanvasRenderingContext2D ctx;

  SlimeRenderingSystem(this.ctx)
      : super(Aspect.getAspectForAllOf([PixelPosition, Slime, Age]));

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    var s = sm[entity];
    var a = am[entity];

    final age = world.time() - a.birthTime;
    final jumpHeight = max(0.0, sin(age * 5) + 0.2) * 500 * world.delta;
    final squeezeFactor = max(0.8, sin(age * 5) + 0.4);

    ctx
      ..save()
      ..scale(gsm.zoom, gsm.zoom)
      ..translate(-gsm.cameraX, -gsm.cameraY)
      ..translate(p.x, p.y - jumpHeight)
      ..fillStyle = 'hsla(${s.hue},70%,40%,0.95)'
      ..beginPath()
      ..moveTo(0, 0)
      ..bezierCurveTo(5 / squeezeFactor, 0, 10 / squeezeFactor, 0,
          10 / squeezeFactor, -10 * squeezeFactor)
      ..bezierCurveTo(10 / squeezeFactor, -15 * squeezeFactor, 0,
          -15 * squeezeFactor, 0, -20 * squeezeFactor)
      ..moveTo(0, 0)
      ..bezierCurveTo(-5 / squeezeFactor, 0, -10 / squeezeFactor, 0,
          -10 / squeezeFactor, -10 * squeezeFactor)
      ..bezierCurveTo(-10 / squeezeFactor, -15 * squeezeFactor, 0,
          -15 * squeezeFactor, 0, -20 * squeezeFactor)
      ..closePath()
      ..fill()
      ..restore();
  }
}

class RoadFragmentRenderingSystem extends EntityProcessingSystem {
  GameStateManager gsm;
  Mapper<RoadFragment> rm;

  CanvasRenderingContext2D ctx;
  SpriteSheet sheet;

  RoadFragmentRenderingSystem(this.ctx, this.sheet)
      : super(Aspect.getAspectForAllOf([RoadFragment]));

  @override
  void processEntity(Entity entity) {
    final r = rm[entity];
    final startX = convertX(r.startX, r.startY) + pixelPerWidth / 2;
    final endX = convertX(r.endX, r.endY) + pixelPerWidth / 2;
    final startY = convertY(r.startY) + pixelPerHeight / 2;
    final endY = convertY(r.endY) + pixelPerHeight / 2;
    final road = sheet.sprites['road'];
    ctx
      ..save()
      ..scale(gsm.zoom, gsm.zoom)
      ..translate(-gsm.cameraX, -gsm.cameraY)
      ..translate(startX, startY)
      ..rotate(atan2(endY - startY, endX - startX))
      ..globalAlpha = r.temp ? 0.4 : 1.0
      ..drawImageScaledFromSource(
          sheet.image,
          road.src.left,
          road.src.top,
          road.src.width,
          road.src.height,
          0,
          -10,
          road.dst.width,
          road.dst.height)
      ..restore();
  }
}

class MapRenderingSystem extends VoidEntitySystem {
  CanvasRenderingContext2D ctx;
  SpriteSheet sheet;
  MapManager mapManager;
  GameStateManager gsm;
  CanvasElement buffer;
  CanvasRenderingContext2D bufferCtx;

  MapRenderingSystem(this.ctx, this.sheet);

  @override
  void initialize() {
    buffer = new CanvasElement(
        width: (100 * pixelPerWidth).ceil(),
        height: (100 * pixelPerHeight).ceil());
    bufferCtx = buffer.context2D;
    final map = mapManager.map.map;
    for (int y = 0; y < map.length; y++) {
      for (int x = 0; x < map[y].length; x++) {
        Sprite sprite;
        switch (map[y][x].type) {
          case TileType.carbon:
            sprite = sheet.sprites['carbon'];
            break;
          case TileType.water:
            sprite = sheet.sprites['water'];
            break;
          default:
            sprite = sheet.sprites['grass-${random.nextInt(4)}'];
        }
        var realX = convertX(x, y);
        var realY = convertY(y);
        bufferCtx.drawImageScaledFromSource(
            sheet.image,
            sprite.src.left + 1,
            sprite.src.top + 1,
            sprite.src.width - 2,
            sprite.src.height - 2,
            realX - 1,
            realY,
            pixelPerWidth + 2,
            pixelPerHeight);
      }
    }
  }

  @override
  void processSystem() {
    ctx.drawImageScaledFromSource(buffer, gsm.cameraX, gsm.cameraY,
        1024 / gsm.zoom, 768 / gsm.zoom, 0, 0, 1024, 768);
  }
}

class DebugCoordRenderingSystem extends VoidEntitySystem {
  CanvasRenderingContext2D ctx;
  MapManager mapManager;
  GameStateManager gsm;
  CanvasElement buffer;
  CanvasRenderingContext2D bufferCtx;

  DebugCoordRenderingSystem(this.ctx);

  @override
  void initialize() {
    buffer = new CanvasElement(
        width: (100 * pixelPerWidth).ceil(),
        height: (100 * pixelPerHeight).ceil());
    bufferCtx = buffer.context2D;
    final map = mapManager.map.map;
    for (int y = 0; y < map.length; y++) {
      for (int x = 0; x < map[y].length; x++) {
        var realX = convertX(x, y) + pixelPerWidth / 2;
        var realY = convertY(y) + pixelPerHeight / 2;

        bufferCtx.fillStyle = 'white';
        bufferCtx.fillText('$x:$y', realX, realY);
      }
    }
  }

  @override
  void processSystem() {
    ctx.drawImageScaledFromSource(buffer, gsm.cameraX, gsm.cameraY,
        1024 / gsm.zoom, 768 / gsm.zoom, 0, 0, 1024, 768);

    ctx
      ..save()
      ..strokeStyle = 'black'
      ..lineWidth = 3
      ..beginPath()
      ..moveTo(400, 0)
      ..lineTo(400, 768)
      ..closePath()
      ..stroke()
      ..beginPath()
      ..moveTo(0, 300)
      ..lineTo(1024, 300)
      ..closePath()
      ..stroke()
      ..restore();
  }
}

class BuildingRenderingSystem extends EntityProcessingSystem {
  Mapper<GridPosition> pm;
  Mapper<Building> bm;
  GameStateManager gsm;

  CanvasRenderingContext2D ctx;
  SpriteSheet sheet;
  BuildingRenderingSystem(this.ctx, this.sheet)
      : super(Aspect.getAspectForAllOf([GridPosition, Building]));

  @override
  void processEntity(Entity entity) {
    final p = pm[entity];
    final b = bm[entity];
    final sprite = sheet.sprites[b.id];

    ctx
      ..save()
      ..scale(gsm.zoom, gsm.zoom)
      ..translate(-gsm.cameraX, -gsm.cameraY)
      ..translate(convertX(p.x, p.y), convertY(p.y))
      ..drawImageScaledFromSource(
          sheet.image,
          sprite.src.left,
          sprite.src.top,
          sprite.src.width,
          sprite.src.height,
          sprite.dst.left + pixelPerWidth / 2,
          sprite.dst.top + pixelPerHeight / 2,
          sprite.dst.width,
          sprite.dst.height)
      ..restore();
  }
}

class MousePositionHighlightingSystem extends VoidEntitySystem {
  GameStateManager gsm;
  CanvasRenderingContext2D ctx;
  TagManager tm;

  MousePositionHighlightingSystem(this.ctx);

  @override
  void processSystem() {
    final x = convertX(gsm.selectedMapCoord.x, gsm.selectedMapCoord.y);
    final y = convertY(gsm.selectedMapCoord.y);
    final hasCurrentAction =
        tm.isRegistered(currentActionTag) && gsm.validAction != null;
    final hue = hasCurrentAction ? gsm.validAction ? 100 : 0 : 0;
    final saturation = hasCurrentAction ? 50 : 0;
    final lightness = hasCurrentAction ? 50 : 100;
    final alpha = hasCurrentAction ? 0.4 : 0.15;
    ctx
      ..save()
      ..scale(gsm.zoom, gsm.zoom)
      ..translate(-gsm.cameraX, -gsm.cameraY)
      ..translate(x, y)
      ..fillStyle = 'hsla($hue,$saturation%,$lightness%,$alpha)'
      ..beginPath()
      ..moveTo(pixelPerWidth / 2, 0)
      ..lineTo(pixelPerWidth, pixelPerHeight * 0.25)
      ..lineTo(pixelPerWidth, pixelPerHeight * 0.75)
      ..lineTo(pixelPerWidth / 2, pixelPerHeight)
      ..lineTo(0, pixelPerHeight * 0.75)
      ..lineTo(0, pixelPerHeight * 0.25)
      ..closePath()
      ..fill();
    if (hasCurrentAction) {
      ctx
        ..strokeStyle = 'hsla(0,0%,0%,0.5)'
        ..lineWidth = 5
        ..beginPath();
      if (gsm.validAction) {
        ctx
          ..moveTo(pixelPerWidth / 4, pixelPerHeight / 2)
          ..lineTo(pixelPerWidth / 2, pixelPerHeight * 0.65)
          ..lineTo(pixelPerWidth * 0.75, pixelPerHeight / 4);
      } else {
        ctx
          ..moveTo(pixelPerWidth * 0.25, pixelPerHeight * 0.25)
          ..lineTo(pixelPerWidth * 0.75, pixelPerHeight * 0.75)
          ..moveTo(pixelPerWidth * 0.25, pixelPerHeight * 0.75)
          ..lineTo(pixelPerWidth * 0.75, pixelPerHeight * 0.25);
      }
      ctx
        ..stroke()
        ..closePath();
    }

    ctx.restore();
  }

  @override
  bool checkProcessing() => gsm.selectedMapCoord != null;
}

class BuildingSelectionRenderingSystem extends EntityProcessingSystem {
  Mapper<BuildBuildingAction> bbam;
  GameStateManager gsm;
  MapManager mapManager;
  CanvasRenderingContext2D ctx;
  SpriteSheet sheet;

  BuildingSelectionRenderingSystem(this.ctx, this.sheet)
      : super(Aspect.getAspectForAllOf([BuildBuildingAction]).exclude(
            [ExecuteAction, AbortAction]));

  @override
  void processEntity(Entity entity) {
    final action = bbam[entity];
    final tile = mapManager.getTile(action.x, action.y);
    final baseX = convertX(action.x, action.y) - gsm.cameraX;
    final baseY = convertY(action.y) - gsm.cameraY;
    var text = 'Please select a building';
    BuildingType.buildingTypes
        .where((buildingType) => buildingType.allowedTiles.contains(tile.type))
        .forEach((buildingType) {
      final x = (baseX + pixelPerWidth * buildingType.x) * gsm.zoom;
      final y = (baseY + pixelPerHeight * buildingType.y) * gsm.zoom;
      final radius = gsm.zoom * pixelPerWidth / 4;
      final cursorInCircle =
          (gsm.mousePos.distanceTo(new Point(x, y)) < radius);
      final style = cursorInCircle ? 'green' : 'hsla(0, 0%, 80%, 0.8)';
      if (cursorInCircle) {
        text = buildingType.desciption;
      }
      final sprite = sheet.sprites[buildingType.type];

      ctx
        ..save()
        ..beginPath()
        ..lineWidth = 3
        ..fillStyle = style
        ..strokeStyle = 'black'
        ..arc(x, y, radius, 0, 2 * PI)
        ..closePath()
        ..stroke()
        ..fill()
        ..drawImageScaledFromSource(
            sheet.image,
            sprite.src.left,
            sprite.src.top,
            sprite.src.width,
            sprite.src.height,
            x + sprite.dst.left * gsm.zoom * 0.5,
            y + sprite.dst.top * gsm.zoom * 0.5,
            sprite.dst.width * gsm.zoom * 0.5,
            sprite.dst.height * gsm.zoom * 0.5)
        ..restore();
    });
    ctx
      ..save()
      ..font = '18px Verdana'
      ..textBaseline = 'bottom'
      ..globalAlpha = 0.8
      ..fillStyle = 'white';
    final textWidth = ctx.measureText(text).width;
    ctx
      ..fillText(text, gsm.mousePos.x - textWidth / 2, gsm.mousePos.y)
      ..restore();
  }
}
