part of dartvn;

class Position extends DisplayObjectContainer {
  Map args;

  Position(Map args) {
    this.args = args;
    if(args.containsKey('width') && args.containsKey('height')) {
      List xy =_getXY(args, [args['width'], args['height']]);
      this.mask = new Mask.rectangle(xy[0], xy[1], args['width'],args['height']);
    }
  }

  void add(DisplayObject child) {
    List xy =_getXY(args, [child.width, child.height]);
    child.x = xy[0];
    child.y = xy[1];
    addChild(child);
  }

  List<num> _getXY(args, List<num> wh) {
    num x; num y;
    bool hor = false;
    bool vert = false;
    num width = wh[0];
    num height = wh[1];
    num sw = stage.sourceWidth;
    num sh = stage.sourceHeight;
    args.forEach((edge, distance) {
      if(!hor) {
        hor = true;
        switch(edge) {
          case 'left': x = distance;
          break;
        case 'right': x = sw - width - distance;
          break;
        case 'center': x = (sw - width)/2 + distance;
          break;
        default: hor = false;
          break;
        }
      }

      if(!vert) {
        vert = true;
        switch(edge) {
          case 'top': y = distance;
            break;
          case 'bottom': y = sh - height - distance;
            break;
          case 'middle': y = (sh - height)/2 + distance;
            break;
          default: vert = false;
            break;
        }
      }

    });

    return [x,y];
  }

}

