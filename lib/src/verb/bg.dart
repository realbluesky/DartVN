part of dartvn;

class bg extends Verb {
  
  bg(subverb, value, options) {
    
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
      var tween;
      var dur = options.containsKey('dur')? options['dur'] : vn.options['dur'];
      switch(options['trans']) {
        case 'fade':
          newBackground.alpha = 0;
          vn.addChild(newBackground);
          tween = vn.juggler.tween(newBackground, dur, TransitionFunction.easeInQuadratic);
          tween.animate.alpha.to(1.0);
          break;
        case 'fadethru':
          Bitmap thruBackground;
          thruBackground = new Bitmap(new BitmapData(stage.width.toInt(), stage.height.toInt(), false, options['color']));
          thruBackground.alpha = 0;
          newBackground.alpha = 0;
          vn.addChild(newBackground);
          vn.addChild(thruBackground);
          tween = vn.juggler.tween(thruBackground, dur/2, TransitionFunction.easeInQuadratic);
          tween.animate.alpha.to(1.0);
          vn.juggler.tween(thruBackground, dur/2, TransitionFunction.easeInQuadratic)
            ..animate.alpha.to(0.0)
              ..delay = dur/2;
          vn.juggler.delayCall(()=> vn.removeChild(thruBackground), dur);
          break;
        case 'fadeacross':
          var dir = options.containsKey('dir')? options['dir'] : vn.options['dir'];
          var fadePortion = 1/5;
          var stops = [0,1];
          var gradientWidthHeight = [stage.width*fadePortion,0];
          var pathWidthHeight = [stage.width*fadePortion,stage.height];
          bool horizontal = true;
          bool reverse = false;
          var startStop = [-stage.width*fadePortion, stage.width];
          switch(dir) {
            case 'left':
              stops = [1,0];
              reverse = true;
              startStop = [stage.width,-stage.width*fadePortion];
              break;
            case 'down':
              gradientWidthHeight = [0,stage.height*fadePortion];
              pathWidthHeight = [stage.width,stage.height*fadePortion];
              horizontal = false;
              startStop = [-stage.height*fadePortion, stage.height];
              break;
            case 'up':
              stops = [1,0];
              gradientWidthHeight = [0,stage.height*fadePortion];
              pathWidthHeight = [stage.width,stage.height*fadePortion];
              horizontal = false;
              reverse = true;
              startStop = [stage.height,-stage.height*fadePortion];
              break;
          }              
          Shape fade = new Shape();
          Bitmap fadeBackground = new Bitmap(newBackground.bitmapData);
          GraphicsGradient gradient = new GraphicsGradient.linear(0, 0, gradientWidthHeight[0], gradientWidthHeight[1])
            ..addColorStop(stops[0], 0xFF000000)
            ..addColorStop(stops[1], 0x00000000);
          fade.graphics
            ..beginPath()
            ..rect(0, 0, pathWidthHeight[0], pathWidthHeight[1])
            ..closePath()
            ..fillGradient(gradient);
          var alphaMask = new BitmapData(fade.width, fade.height, true, 0x00000000)
            ..draw(fade);
          fadeBackground
            ..filters = [new AlphaMaskFilter(alphaMask)]
            ..applyCache(0,0,stage.width.toInt(),stage.height.toInt());
          vn.addChild(newBackground);
          vn.addChild(fadeBackground);
          tween = vn.juggler.transition(startStop[0], startStop[1], dur, TransitionFunction.linear, (value) {
            AlphaMaskFilter gradient = fadeBackground.filters[0];
            gradient.matrix
              ..identity()
              ..translate(horizontal?value:0, horizontal?0:value);
            fadeBackground.refreshCache();
            switch(dir) {
              case 'right': newBackground.clipRectangle = new Rectangle(0, 0, min(max(0,value+1),stage.width.toInt()), stage.height.toInt());
                break;
              case 'left': newBackground.clipRectangle = new Rectangle(max(value-startStop[1]-1,0), 0, max(startStop[0]-value+startStop[1],0), stage.height.toInt());
                break;
              case 'down': newBackground.clipRectangle = new Rectangle(0, 0, stage.width.toInt(), min(max(0,value+1),stage.height.toInt()));
                break;
              case 'up': newBackground.clipRectangle = new Rectangle(0, max(value-startStop[1]-1,0), stage.width.toInt(), max(startStop[0]-value+startStop[1],0));
                break;
            }
          });    
          vn.juggler.delayCall(()=> vn.removeChild(fadeBackground), dur);
          break;
          }
          if(tween != null) tween.onComplete = () { if(currentBackground != null) { vn.removeChild(currentBackground); } newBackground.alpha = 1; vn.prevNext = [true,true]; };
          else { vn.prevNext = [true,true]; } 
        } else { //no transition
          if(currentBackground != null) vn.removeChild(currentBackground);  
          vn.addChild(newBackground);
          vn.prevNext = [true,true];
        }
  }
}