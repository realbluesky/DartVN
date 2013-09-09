part of dartvn;

class Set extends Verb {
  
  Set(List args) {
    var position; var value; Map options; Map posArgs; Bitmap currentBitmap; var newName;
    VN vn = stage.getChildByName('vn');
    Layer layer = vn.getChildByName(args[0]);
    if(args.length>1) position = args[1];
    if(args.length>2) value = args[2];
    options = args.length>3?args[3]:{};
    
    if(position is! Map) {
      currentBitmap = layer.getChildByName(position);
      posArgs = vn.options['positions'][position];
      newName = position;
    } else {
      posArgs = position;
      newName = value.toString();
    }
    
    //eventually add Map detection for gradients?
    Bitmap newBitmap;
    if(value is int) newBitmap = new Bitmap(new BitmapData(stage.width.toInt(), stage.height.toInt(), false, value));
    else if(vn.assets['images'].containsKey(value)) newBitmap = new Bitmap(resourceManager.getBitmapData(value));
    else if(vn.assets['shapes'].containsKey(value)) {
      Map shapeArgs = vn.assets['shapes'][value];
      Shape shape = new Shape();
      shape.graphics.beginPath();      
      switch(shapeArgs['shape']) {
        case 'rect':
          if(shapeArgs.containsKey('corner_radius')) shape.graphics.rectRound(0, 0, shapeArgs['width'], shapeArgs['height'], shapeArgs['corner_radius'], shapeArgs['corner_radius']);
          else shape.graphics.rect(0, 0, shapeArgs['width'], shapeArgs['height']);
          break;
      }
      shape.graphics.closePath();
      if(shapeArgs.containsKey('fill_color')) shape.graphics.fillColor(shapeArgs['fill_color']);
      if(shapeArgs.containsKey('stroke_color')) {
        num strokeWidth = shapeArgs.containsKey('stroke_width')?shapeArgs['stroke_width']:1;
        shape.graphics.strokeColor(shapeArgs['stroke_color'], strokeWidth);
      }
      newBitmap = new Bitmap(new BitmapData(shape.width, shape.height, true, 0x00000000)..draw(shape));
    }
    
    _setPosition(newBitmap, posArgs);
    newBitmap.name = newName;
    var trans = options.containsKey('trans')?options['trans']:vn.options['trans'];

    vn.prevNext = [false,false];
    var tween;
    var dur = options.containsKey('dur')? options['dur'] : vn.options['dur'];
    switch(trans) {
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
      case 'none':
        if(currentBitmap != null) layer.removeChild(currentBitmap);  
        layer.addChild(newBitmap);
        vn.prevNext = [true,true];
        break;
      }
      if(tween != null) tween.onComplete = () { if(currentBitmap != null) { layer.removeChild(currentBitmap); } newBitmap.alpha = 1; vn.prevNext = [true,true]; };
      else { vn.prevNext = [true,true]; }   
  }
  
}