part of client;


class MouseInputSystem extends VoidEntitySystem {
  CanvasElement canvas;
  bool leftMousePressed = false;
  GameStateManager gsm;

  MouseInputSystem(this.canvas);

  @override
  void initialize() {
    canvas.onMouseDown.listen(_handleMouseDown);
    canvas.onMouseUp.listen(_handleMouseUp);
    canvas.onMouseMove.listen(_handleMouseMove);
  }

  @override
  void processSystem() {
  }

  _handleMouseDown(MouseEvent event) {
    if (event.button == 0) {
      leftMousePressed = true;
    }
  }
  _handleMouseUp(MouseEvent event) {
    if (event.button == 0) {
      leftMousePressed = false;
    }
  }
  _handleMouseMove(MouseEvent event) {
    if (event.buttons == 1) {
      gsm.cameraX = min((maxX - 1.01) * pixelPerWidth - 800, max(0, gsm.cameraX + -event.movement.x));
      gsm.cameraY = min((maxY - 1) * verticalDistance - 600, max(0, gsm.cameraY + -event.movement.y));
    }
  }
}