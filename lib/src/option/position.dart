part of dartvn;

class Position extends DisplayObjectContainer {
  Map args;
  
  Position(args) {
    this.args = args;
  }
  
  void add(DisplayObject child) {
    bool hor = false;
    bool vert = false;
    num width = child.width;
    num height = child.height;
    VN vn = stage.getChildByName('vn');
    num sw = vn.options['width'];
    num sh = vn.options['height'];

    args.forEach((edge, distance) {
      if(!hor) {
        hor = true;
        switch(edge) {
          case 'left': child.x = distance;
          break;
        case 'right': child.x = sw - width - distance;
          break;
        case 'center': child.x = (sw - width)/2 + distance;
          break;
        default: hor = false;
          break;
        }
      }
      
      if(!vert) {
        vert = true;
        switch(edge) {
          case 'top': child.y = distance;
            break;
          case 'bottom': child.y = sh - height - distance;
            break;
          case 'middle': child.y = (sh - height)/2 + distance;
            break;
          default: vert = false;
            break;
        }
      }
      
    });
    
    addChild(child);
    
  }
  
  
}

