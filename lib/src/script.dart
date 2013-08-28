part of dartvn;

class Script {
  List _script;
  int currentLine;
  int get numChildren => _script.length;
  
  
  Script(List script) {
    _script = script;
    currentLine = -1;
  }
  
  dynamic next() {
    if(this.numChildren>currentLine+1) { 
      currentLine++;
      return exec();
    } else return false;
  }
  
  dynamic prev() {
    if(currentLine>0) { 
      currentLine--;
      return exec();
    } else return false;
  }
  
  dynamic exec() {
    var line;
    Map options = {};
    line = _script[currentLine];
    
    var verb = line[0];
    var subverb = line[1];
    var value = line[2];
    if(line.length>3) options = line[3];
    
    switch(verb) {
      case 'bg':
        Bitmap newBackground;
        VN vn = stage.getChildByName('vn');
        var currentBackground = vn.getChildByName('background');
        switch(subverb) {
          case 'color':
            newBackground = new Bitmap(new BitmapData(stage.width.toInt(), stage.height.toInt(), false, value));
          break;
        }
        
        newBackground.name = 'background';
        if(options.containsKey('trans')) {
          switch(options['trans']) {
            case 'fade':
              print('fading');
              newBackground.alpha = 0;
              vn.addChild(newBackground);
              vn.juggler.tween(newBackground, 1.0, TransitionFunction.easeInQuadratic).animate.alpha.to(1.0);
              if(currentBackground != null) vn.juggler
                ..tween(currentBackground, 1.0, TransitionFunction.easeInQuadratic).animate.alpha.to(0.0)
                ..delayCall(() => vn.removeChild(currentBackground), 1.0);
              break;
          }
        } else { //no transition
          if(currentBackground != null) vn.removeChild(currentBackground);  
          vn.addChild(newBackground);
        }
        
        
        
        
        
        
        break;
      default:
        print('Unrecognized verb, $verb');
        break;
    }
    
  }
  
     
      
    
  
  
}