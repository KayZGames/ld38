part of shared;


class Position extends Component {
  num x, y;
  Position(this.x, this.y);
}

class Slime extends Component {}

class Road extends Component {
  int startX, startY, endX, endY;
  Road(this.startX, this.startY, this.endX, this.endY);
}