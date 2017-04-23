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
    canvas.onMouseWheel.listen(_handleMouseWheel);
  }

  @override
  void processSystem() {}

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

  _handleMouseWheel(WheelEvent event) {
    event.preventDefault();
    final oldZoom = gsm.zoom;
    gsm.zoom = min(2.0, max(0.5, gsm.zoom - event.deltaY / 1000));
    gsm.cameraX += (800 / oldZoom - 800 / gsm.zoom) / 2;
    gsm.cameraY += (600 / oldZoom - 600 / gsm.zoom) / 2;
  }

  _handleMouseMove(MouseEvent event) {
    if (event.buttons == 1) {
      gsm.cameraX = gsm.cameraX + -event.movement.x;
      gsm.cameraY = gsm.cameraY + -event.movement.y;
    }
  }
}
