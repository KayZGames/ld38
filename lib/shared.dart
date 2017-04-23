library shared;

import 'package:gamedev_helpers/gamedev_helpers_shared.dart';
import 'package:a_star/a_star.dart';
part 'src/shared/components.dart';
//part 'src/shared/systems/name.dart';
part 'src/shared/game_state_manager.dart';
part 'src/shared/map_manager.dart';
part 'src/shared/systems/logic.dart';

const maxX = 40;
const maxY = 40;
const String cameraTag = 'camera';
const double hexSize = pixelPerHeight / 2;
const double pixelPerHeight = 148.0;
const double verticalDistance = pixelPerHeight * 0.75;
const double pixelPerWidth = pixelPerHeight * 1.732 / 2;

num convertX(num x, int y) =>
    y % 2 == 0 ? x * pixelPerWidth : x * pixelPerWidth - 0.5 * pixelPerWidth;
num convertY(num y) => y * verticalDistance;

int convertToXCoord(num x, num y) {
  return x ~/ pixelPerWidth;
}

int convertToYCoord(num x, num y) {
  return y ~/ verticalDistance;
}

List<int> convertPixelToHex(num x, num y) {
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

  return [column, row];
}
