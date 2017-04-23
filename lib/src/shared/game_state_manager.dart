part of shared;

class GameStateManager extends Manager {
  num _cameraX = 0, _cameraY = 0, zoom = 0.7;
  Point<int> selectedMapCoord;
  bool validAction;
  bool buildActionActive = false;
  Point<double> mousePos;

  num get cameraX => _cameraX;
  num get cameraY => _cameraY;

  set cameraX(num value) =>
      _cameraX = min(((maxX - 1) * pixelPerWidth * zoom - 1024) / zoom, max(0, value));
  set cameraY(num value) =>
      _cameraY = min(((maxY - 1) * verticalDistance * zoom - 768) / zoom, max(0, value));
}
