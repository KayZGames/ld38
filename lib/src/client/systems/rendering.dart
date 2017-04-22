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
      ..translate(convertX(p.x, p.y) + gsm.cameraX, convertY(p.y) + gsm.cameraY)
      ..scale(gsm.zoom, gsm.zoom)
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

  RoadRenderingSystem(this.ctx) : super(Aspect.getAspectForAllOf([Road]));

  @override
  void processEntity(Entity entity) {
    final r = rm[entity];
    final startX = convertX(r.startX, r.startY);
    final endX = convertX(r.endX, r.endY);
    final startY = convertY(r.startY);
    final endY = convertY(r.endY);

    ctx
      ..save()
      ..lineWidth = 3
      ..translate(gsm.cameraX, gsm.cameraY)
      ..scale(gsm.zoom, gsm.zoom)
      ..strokeStyle = 'brown'
      ..beginPath()
      ..moveTo(startX, startY)
      ..lineTo(endX, endY)
      ..closePath()
      ..stroke()
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
    final map = mapManager.map;
    for (int y = 0; y < map.length; y++) {
      for (int x = 0; x < map[y].length; x++) {
        Sprite sprite;
        switch (map[y][x]) {
          case Tile.carbon:
            sprite = sheet.sprites['carbon'];
            break;
          case Tile.water:
            sprite = sheet.sprites['water'];
            break;
          default:
            sprite = sheet.sprites['grass-${random.nextInt(4)}'];
        }
        var realX = convertX(x, y) - pixelPerWidth * 0.5;
        var realY = convertY(y) - pixelPerHeight * 0.5;
        bufferCtx.drawImageScaledFromSource(
            sheet.image,
            sprite.src.left,
            sprite.src.top,
            sprite.src.width,
            sprite.src.height,
            realX,
            realY,
            pixelPerWidth,
            pixelPerHeight);
      }
    }
  }

  @override
  void processSystem() {
    ctx.drawImageScaledFromSource(buffer, -gsm.cameraX, -gsm.cameraY,
        800 / gsm.zoom, 600 / gsm.zoom, 0, 0, 800, 600);
  }
}
