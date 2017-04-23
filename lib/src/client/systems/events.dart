part of client;

class MouseInputSystem extends VoidEntitySystem {
  CanvasElement canvas;
  GameStateManager gsm;
  Point<double> mousePos;
  ActionTriggerSystem ats;
  TagManager tagManager;

  MouseInputSystem(this.canvas);

  @override
  void initialize() {
    canvas.onMouseUp.listen(_handleMouseUp);
    canvas.onMouseMove.listen(_handleMouseMove);
    canvas.onMouseWheel.listen(_handleMouseWheel);
    canvas.onContextMenu.listen((event) => event.preventDefault());
    window.onKeyUp.listen(_handleKeyUp);
  }

  @override
  void processSystem() {
    gsm.mousePos = mousePos;
    if (!gsm.buildActionActive) {
      gsm.selectedMapCoord = _convertPixelToMapCoord();
    }
  }

  _handleKeyUp(KeyboardEvent event) {
    if (event.keyCode == KeyCode.ESC) {
      ats.abortAction = true;
    }
  }

  _handleMouseUp(MouseEvent event) {
    event.preventDefault();
    if (event.button == 0) {
      ats.triggerAction = true;
    }
  }

  _handleMouseWheel(WheelEvent event) {
    event.preventDefault();
    final oldZoom = gsm.zoom;
    gsm.zoom = min(2.0, max(0.5, gsm.zoom - event.deltaY / 1000));
    gsm.cameraX += (1024 / oldZoom - 1024 / gsm.zoom) / 2;
    gsm.cameraY += (768 / oldZoom - 768 / gsm.zoom) / 2;
  }

  _handleMouseMove(MouseEvent event) {
    // 1 == left button
    // 2 == right button
    if (event.buttons & 2 != 0) {
      gsm.cameraX = gsm.cameraX + -event.movement.x / gsm.zoom;
      gsm.cameraY = gsm.cameraY + -event.movement.y / gsm.zoom;
    }
    mousePos = event.offset;
  }

  @override
  bool checkProcessing() => mousePos != null;

  Point<int> _convertPixelToMapCoord() {
    final x = gsm.cameraX + mousePos.x / gsm.zoom;
    final y = gsm.cameraY + mousePos.y / gsm.zoom;
    // Find the row and column of the box that the point falls in.
    int row = (y ~/ verticalDistance);
    int column;

    bool rowIsOdd = row % 2 == 1;

    // Is the row an odd number?
    if (rowIsOdd) // Yes: Offset x to match the indent of the row
      column = ((x + pixelPerWidth / 2) ~/ pixelPerWidth);
    else // No: Calculate normally
      column = (x ~/ pixelPerWidth);

    double relY = y - (row * verticalDistance);
    double relX;

    if (rowIsOdd)
      relX = (x - (column * pixelPerWidth)) + pixelPerWidth / 2;
    else
      relX = x - (column * pixelPerWidth);

    var c = 0.25 * pixelPerHeight;
    var m = c / (pixelPerWidth / 2);
    // Work out if the point is above either of the hexagon's top edges
    if (relY < (-m * relX) + c) {
      // LEFT edge
      row--;
      if (rowIsOdd) column--;
    } else if (relY < (m * relX) - c) {
      // RIGHT edge
      row--;
      if (!rowIsOdd) column++;
    }

    return new Point(column, row);
  }
}
