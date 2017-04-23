part of shared;

class Position extends Component {
  num x, y;
  Position(this.x, this.y);
}

class Slime extends Component {}

class RoadFragment extends Component {
  int startX, startY, endX, endY;
  bool temp;

  RoadFragment(this.startX, this.startY, this.endX, this.endY,
      {this.temp: false});
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
