part of client;

class SlimeRenderingSystem extends EntityProcessingSystem {
  GameStateManager gsm;
  Mapper<Position> pm;
  CanvasRenderingContext2D ctx;

  SlimeRenderingSystem(this.ctx)
      : super(Aspect.getAspectForAllOf([Position, Slime]));

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];

    ctx
      ..save()
      ..translate(-gsm.cameraX, -gsm.cameraY)
      ..scale(gsm.zoom, gsm.zoom)
      ..translate(convertX(p.x, p.y), convertY(p.y))
      ..fillStyle = 'blue'
      ..beginPath()
      ..moveTo(0, 0)
      ..bezierCurveTo(5, 0, 10, 0, 10, -10)
      ..bezierCurveTo(10, -15, 0, -15, 0, -20)
      ..moveTo(0, 0)
      ..bezierCurveTo(-5, 0, -10, 0, -10, -10)
      ..bezierCurveTo(-10, -15, 0, -15, 0, -20)
      ..closePath()
      ..fill()
      ..restore();
  }
}

class RoadRenderingSystem extends EntityProcessingSystem {
  GameStateManager gsm;
  Mapper<Road> rm;

  CanvasRenderingContext2D ctx;
  SpriteSheet sheet;

  RoadRenderingSystem(this.ctx, this.sheet)
      : super(Aspect.getAspectForAllOf([Road]));

  @override
  void processEntity(Entity entity) {
    final r = rm[entity];
    final startX = convertX(r.startX, r.startY);
    final endX = convertX(r.endX, r.endY);
    final startY = convertY(r.startY);
    final endY = convertY(r.endY);
    final road = sheet.sprites['road'];
    ctx
      ..save()
      ..translate(-gsm.cameraX, -gsm.cameraY)
      ..scale(gsm.zoom, gsm.zoom)
      ..translate(startX, startY)
      ..rotate(atan2(endY - startY, endX - startX))
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
        var realX = convertX(x, y) - pixelPerWidth * 0.5;
        var realY = convertY(y) - pixelPerHeight * 0.5;
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
    ctx.drawImageScaledFromSource(buffer, gsm.cameraX / gsm.zoom,
        gsm.cameraY / gsm.zoom, 800 / gsm.zoom, 600 / gsm.zoom, 0, 0, 800, 600);
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
        var realX = convertX(x, y);
        var realY = convertY(y);
        bufferCtx.fillStyle = 'white';
        bufferCtx.fillText('$x:$y', realX, realY);
      }
    }
  }

  @override
  void processSystem() {
    ctx.drawImageScaledFromSource(buffer, gsm.cameraX / gsm.zoom,
        gsm.cameraY / gsm.zoom, 800 / gsm.zoom, 600 / gsm.zoom, 0, 0, 800, 600);
  }
}

class BuildingRenderingSystem extends EntityProcessingSystem {
  Mapper<Position> pm;
  Mapper<Building> bm;
  GameStateManager gsm;

  CanvasRenderingContext2D ctx;
  SpriteSheet sheet;
  BuildingRenderingSystem(this.ctx, this.sheet)
      : super(Aspect.getAspectForAllOf([Position, Building]));

  @override
  void processEntity(Entity entity) {
    final p = pm[entity];
    final b = bm[entity];
    final sprite = sheet.sprites[b.id];

    ctx
      ..save()
      ..translate(-gsm.cameraX, -gsm.cameraY)
      ..scale(gsm.zoom, gsm.zoom)
      ..translate(convertX(p.x, p.y), convertY(p.y))
      ..drawImageScaledFromSource(
          sheet.image,
          sprite.src.left,
          sprite.src.top,
          sprite.src.width,
          sprite.src.height,
          sprite.dst.left,
          sprite.dst.top,
          sprite.dst.width,
          sprite.dst.height)
      ..restore();
  }
}
