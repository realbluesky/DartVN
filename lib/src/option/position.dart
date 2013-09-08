part of dartvn;

void _setPosition(Bitmap object, Map args) {
  bool hor = false;
  bool vert = false;
  num width = object.width;
  num height = object.height;
  num sw = stage.width;
  num sh = stage.height;
  args.forEach((edge, distance) {
    if(!hor) {
      hor = true;
      switch(edge) {
        case 'left': object.x = distance;
          break;
        case 'right': object.x = sw - width - distance;
          break;
        case 'center': object.x = (sw - width)/2 + distance;
          break;
        default: hor = false;
          break;
      }
      
    }
    
    if(!vert) {
      vert = true;
      switch(edge) {
        case 'top': object.y = distance;
          break;
        case 'bottom': object.y = sh - height - distance;
          break;
        case 'middle': object.y = (sh - height)/2 + distance;
          break;
        default: vert = false;
          break;
      }
      
    }
  });
  
}