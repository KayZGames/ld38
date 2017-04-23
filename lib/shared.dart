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
const double pixelPerHeight = 148.0;
const double verticalDistance = pixelPerHeight * 0.75;
const double pixelPerWidth = pixelPerHeight * 1.732/2;

num convertX(num x, int y) => y % 2 == 0 ? x * pixelPerWidth : x * pixelPerWidth - 0.5 * pixelPerWidth;
num convertY(num y) => y * verticalDistance;