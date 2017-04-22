part of client;

class SlimeRenderingSystem extends EntityProcessingSystem {
  Mapper<Position> pm;
  CanvasRenderingContext2D ctx;

  SlimeRenderingSystem(this.ctx)
      : super(Aspect.getAspectForAllOf([Position, Slime]));

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];

    ctx
      ..save()
      ..translate(400, 400)
      ..scale(100, 100)
      ..beginPath()
      ..moveTo(p.x, p.y)
      ..bezierCurveTo(0.5, 0, 1, 0, 1, -1)
      ..bezierCurveTo(1, -1.5, 0, -1.5, 0, -2)
      ..bezierCurveTo(0, -1.5, -1, -1.5, -1, -1)
      ..bezierCurveTo(-1, 0, -0.5, 0, 0, 0)
      ..lineWidth = 0.05
      ..strokeStyle = 'black'
      ..fillStyle = 'blue'
      ..closePath()
      ..fill()
      ..stroke()
      ..restore();
  }
}
