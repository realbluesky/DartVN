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
          case 'image':
            newBackground = new Bitmap(resourceManager.getBitmapData(value));  
          break;
        }
        
        newBackground.name = 'background';
        if(options.containsKey('trans')) {
          vn.prevNext = [false,false];
          Tween tween;
          switch(options['trans']) {
            case 'fade':
              newBackground.alpha = 0;
              vn.addChild(newBackground);
              tween = vn.juggler.tween(newBackground, 1.0, TransitionFunction.easeInQuadratic);
              tween.animate.alpha.to(1.0);
              break;
            case 'fadethru':
              Bitmap thruBackground;
              thruBackground = new Bitmap(new BitmapData(stage.width.toInt(), stage.height.toInt(), false, options['color']));
              thruBackground.alpha = 0;
              newBackground.alpha = 0;
              vn.addChild(newBackground);
              vn.addChild(thruBackground);
              tween = vn.juggler.tween(thruBackground, 1.0, TransitionFunction.easeInQuadratic);
              tween.animate.alpha.to(1.0);
              vn.juggler.tween(thruBackground, 1.0, TransitionFunction.easeInQuadratic)
                ..animate.alpha.to(0.0)
                ..delay = 1;
              var delayedAction = new DelayedCall(()=> vn.removeChild(thruBackground), 2.0);
              vn.juggler.add(delayedAction);
              break;
          }
          
          tween.onComplete = () { if(currentBackground != null) { vn.removeChild(currentBackground); } newBackground.alpha = 1; vn.prevNext = [true,true]; };
        } else { //no transition
          if(currentBackground != null) vn.removeChild(currentBackground);  
          vn.addChild(newBackground);
          vn.prevNext = [true,true];
        }
        
        
        
        
        
        
        break;
      default:
        print('Unrecognized verb, $verb');
        break;
    }
    
  }
  
     
      
    
  
  
}