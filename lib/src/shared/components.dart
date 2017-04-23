part of shared;

class GridPosition extends Component {
  num x, y;
  GridPosition(this.x, this.y);
}
class PixelPosition extends Component {
  num x, y;
  PixelPosition(this.x, this.y);
}

class Slime extends Component {
  int hue;
  Slime(this.hue);
}

class Age extends Component {
  double birthTime;
  Age(this.birthTime);
}

class RoadFragment extends Component {
  int startX, startY, endX, endY;
  bool temp;

  RoadFragment(this.startX, this.startY, this.endX, this.endY,
      {this.temp: false});
}

class Patrol extends Component {
  int startX, startY, endX, endY;

  Patrol(this.startX, this.startY, this.endX, this.endY);
}

class Building extends Component {
  String id;
  Building(this.id);
}

class BuildRoadAction extends Component {
  int startX, startY, endX, endY;
  BuildRoadAction(this.startX, this.startY, this.endX, this.endY);
}

class BuildBuildingAction extends Component {
  int x, y;
  BuildBuildingAction(this.x, this.y);
}

class AbortAction extends Component {}

class ExecuteAction extends Component {}

class WayPoints extends Component {
  List<Point<double>> values;
  WayPoints(this.values);
}