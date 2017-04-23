part of shared;

class GameStateManager extends Manager {
  num _cameraX = 0, _cameraY = 0, zoom = 0.7;
  Point mousePos;

  num get cameraX => _cameraX;
  num get cameraY => _cameraY;
  set cameraX(num value) =>
      _cameraX = min(((maxX - 1) * pixelPerWidth * zoom - 800) / zoom, max(0, value));
  set cameraY(num value) =>
      _cameraY = min(((maxY - 1) * verticalDistance * zoom - 600) / zoom, max(0, value));
}
