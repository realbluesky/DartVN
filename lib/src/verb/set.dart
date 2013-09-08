part of dartvn;

class Set extends Verb {
  
  Set(List args) {
    var position; var value; Map options; Map posArgs; Bitmap currentBitmap; var newName;
    VN vn = stage.getChildByName('vn');
    Layer layer = vn.getChildByName(args[0]);
    if(args.length>1) position = args[1];
    if(args.length>2) value = args[2];
    if(args.length>3) options = args[3];
    
    if(position is! Map) {
      currentBitmap = layer.getChildByName(position);
      posArgs = vn.options['positions'][position];
      newName = position;
    } else {
      posArgs = position;
      newName = value.toString();
    }
    
    //eventually add Map detection for gradients/vector shapes?
    Bitmap newBitmap = (value is int)?new Bitmap(new BitmapData(stage.width.toInt(), stage.height.toInt(), false, value)):new Bitmap(resourceManager.getBitmapData(value));  
    _setPosition(newBitmap, posArgs);
    newBitmap.name = newName;
    if(options.containsKey('trans')) {
      vn.prevNext = [false,false];
      var tween;
      var dur = options.containsKey('dur')? options['dur'] : vn.options['dur'];
      switch(options['trans']) {
        case 'fade':
          newBitmap.alpha = 0;
          layer.addChild(newBitmap);
          tween = vn.juggler.tween(newBitmap, dur, TransitionFunction.easeInQuadratic);
          tween.animate.alpha.to(1.0);
          break;
        case 'fadethru':
          Bitmap thruBitmap;
          thruBitmap = new Bitmap(new BitmapData(stage.width.toInt(), stage.height.toInt(), false, options['color']));
          thruBitmap.alpha = 0;
          newBitmap.alpha = 0;
          layer.addChild(newBitmap);
          layer.addChild(thruBitmap);
          tween = vn.juggler.tween(thruBitmap, dur/2, TransitionFunction.easeInQuadratic);
          tween.animate.alpha.to(1.0);
          vn.juggler.tween(thruBitmap, dur/2, TransitionFunction.easeInQuadratic)
            ..animate.alpha.to(0.0)
              ..delay = dur/2;
          vn.juggler.delayCall(()=> layer.removeChild(thruBitmap), dur);
          break;
        case 'fadeacross':
          var dir = options.containsKey('dir')? options['dir'] : vn.options['dir'];
          var fadePortion = 1/5;
          var stops = [0,1];
          var gradientWidthHeight = [stage.width*fadePortion,0];
          var pathWidthHeight = [stage.width*fadePortion,stage.height];
          bool horizontal = true;
          var startStop = [-stage.width*fadePortion, stage.width];
          switch(dir) {
            case 'left':
              stops = [1,0];
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
              startStop = [stage.height,-stage.height*fadePortion];
              break;
          }              
          Shape fade = new Shape();
          Bitmap fadeBackground = new Bitmap(newBitmap.bitmapData);
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
          layer.addChild(newBitmap);
          layer.addChild(fadeBackground);
          tween = vn.juggler.transition(startStop[0], startStop[1], dur, TransitionFunction.linear, (value) {
            AlphaMaskFilter gradient = fadeBackground.filters[0];
            gradient.matrix
              ..identity()
              ..translate(horizontal?value:0, horizontal?0:value);
            fadeBackground.refreshCache();
            switch(dir) {
              case 'right': newBitmap.clipRectangle = new Rectangle(0, 0, min(max(0,value+1),stage.width.toInt()), stage.height.toInt());
                break;
              case 'left': newBitmap.clipRectangle = new Rectangle(max(value-startStop[1]-1,0), 0, max(startStop[0]-value+startStop[1],0), stage.height.toInt());
                break;
              case 'down': newBitmap.clipRectangle = new Rectangle(0, 0, stage.width.toInt(), min(max(0,value+1),stage.height.toInt()));
                break;
              case 'up': newBitmap.clipRectangle = new Rectangle(0, max(value-startStop[1]-1,0), stage.width.toInt(), max(startStop[0]-value+startStop[1],0));
                break;
            }
          });    
          vn.juggler.delayCall(()=> layer.removeChild(fadeBackground), dur);
          break;
          }
          if(tween != null) tween.onComplete = () { if(currentBitmap != null) { layer.removeChild(currentBitmap); } newBitmap.alpha = 1; vn.prevNext = [true,true]; };
          else { vn.prevNext = [true,true]; } 
        } else { //no transition
          if(currentBitmap != null) layer.removeChild(currentBitmap);  
          layer.addChild(newBitmap);
          vn.prevNext = [true,true];
        }
    
  }
  
}