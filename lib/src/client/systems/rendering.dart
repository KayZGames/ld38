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
      ..translate(p.x * unitToPixel + gsm.cameraX, p.y * unitToPixel + gsm.cameraY)
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
    final startX = r.startY % 2 == 0 ? r.startX * unitToPixel : r.startX * unitToPixel - 5;
    final endX = r.endY % 2 == 0 ? r.endX * unitToPixel : r.endX * unitToPixel - 5;
    final startY = r.startY * unitToPixel * 0.75;
    final endY = r.endY * unitToPixel * 0.75;

    ctx..save()
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