part of dartvn;

class Set extends Verb {
  
  Set(List args) {
    var posName; var value; Map options; Map posArgs; var currentBitmap; var newName; Position position;
    VN vn = stage.getChildByName('vn');
    Layer layer = vn.getChildByName(args[0]);
    if(args.length>1) posName = args[1];
    if(args.length>2) value = args[2];
    options = args.length>3?args[3]:{};
    var trans = options.containsKey('trans')?options['trans'] : vn.options['trans'];
    var dur = options.containsKey('dur')?options['dur'] : vn.options['dur'];
    
    if(posName is String) {
      posArgs = vn.options['positions'][posName];
      if(layer.getChildByName(posName) == null) layer.addChild(new Position(posArgs)..name = posName);
      position = layer.getChildByName(posName);
      if(options['mode']!='add' && position.numChildren > 0) currentBitmap = position.getChildAt(0);
      newName = posName;
    } else if(posName is Map) {
      posArgs = posName;
      layer.addChild(new Position(posArgs)..name = value.toString());
      newName = value.toString();
    } else { //emptying this layer!
      vn.juggler.tween(layer, dur, TransitionFunction.easeInQuadratic)
        ..animate.alpha.to(0)
        ..onComplete = () {
         layer.removeChildren();
         layer.alpha = 1;
        };
      return; //free to jump out now
    }
    

    var newBitmap;
    var tween;
    //eventually add Map detection for gradients?    
    if(value is int) newBitmap = new Bitmap(new BitmapData(stage.width.toInt(), stage.height.toInt(), false, value));
    else if(vn.assets['images'].containsKey(value)) newBitmap = new Bitmap(resourceManager.getBitmapData(value));
    else if(vn.assets['shapes'].containsKey(value)) {
      Map sa = vn.assets['shapes'][value]; //shape arguments
      var sw = sa.containsKey('stroke_color')?(sa.containsKey('stroke_width')?sa['stroke_width']:1):0;
      Shape shape = new Shape();     
      shape.graphics.beginPath();
      switch(sa['shape']) {
        case 'rect':
          if(sa.containsKey('corner_radius')) shape.graphics.rectRound(sw, sw, sa['width']-sw*2, sa['height']-sw*2, sa['corner_radius']-sw, sa['corner_radius']-sw);
          else shape.graphics.rect(sw, sw, sa['width']-sw*2, sa['height']-sw*2);
          break;
        case 'ellipse':
          shape.graphics.ellipse(sa['width']/2, sa['height']/2, sa['width']-sw*2, sa['height']-sw*2);
          break;
      }
      shape.graphics.closePath();
      if(sa.containsKey('fill_color')) shape.graphics.fillColor(sa['fill_color']);
      BitmapData drawn = new BitmapData(sa['width'], sa['height'], true, 0x00000000);
      drawn.draw(shape);
      if(sa.containsKey('stroke_color')) {
        Shape stroke = new Shape();
        stroke.graphics.beginPath();
        switch(sa['shape']) {
          case 'rect':
            if(sa.containsKey('corner_radius')) stroke.graphics.rectRound(sw/2, sw/2, sa['width']-sw, sa['height']-sw, sa['corner_radius']-sw/2, sa['corner_radius']-sw/2);
            else stroke.graphics.rect(sw/2, sw/2, sa['width']-sw, sa['height']-sw);
            break;
          case 'ellipse':
            stroke.graphics.ellipse(sa['width']/2, sa['height']/2, sa['width']-sw, sa['height']-sw);
            break;
        }
        stroke.graphics.closePath();
        stroke.graphics.strokeColor(sa['stroke_color'], sw);
        drawn.draw(stroke);
      }
      newBitmap = new Bitmap(drawn); 
    } else if(value is String) { //not an image or shape, so just display the text
      List tf = vn.options['text_formats'][options['text_format']];
      newBitmap = new TextField(value, new TextFormat(tf[0], tf[1], tf[2], bold:tf[3], italic:tf[4]))..autoSize = TextFieldAutoSize.LEFT;
    } else if(currentBitmap != null) { //no value set, empty position or even empty layer if no position
      if(position != null) {
        vn.juggler.tween(position, dur, TransitionFunction.easeInQuadratic)
          ..animate.alpha.to(0)
          ..onComplete = () => layer.removeChild(position);
        return; //free to jump out 
      }
      newBitmap = new Bitmap();
    }
    
    position.add(newBitmap);
    newBitmap.name = newName;
    vn.prevNext = [false,false];
    
    switch(trans) {
      case 'fade':
        newBitmap.alpha = 0;
        position.addChild(newBitmap);
        tween = vn.juggler.tween(newBitmap, dur, TransitionFunction.easeInQuadratic);
        tween.animate.alpha.to(1.0);
        break;
      case 'fadethru':
        Bitmap thruBitmap;
        thruBitmap = new Bitmap(new BitmapData(stage.width.toInt(), stage.height.toInt(), false, options['color']));
        thruBitmap.alpha = 0;
        newBitmap.alpha = 0;
        position.addChild(newBitmap);
        position.addChild(thruBitmap);
        tween = vn.juggler.tween(thruBitmap, dur/2, TransitionFunction.easeInQuadratic);
        tween.animate.alpha.to(1.0);
        vn.juggler.tween(thruBitmap, dur/2, TransitionFunction.easeInQuadratic)
          ..animate.alpha.to(0.0)
            ..delay = dur/2;
        vn.juggler.delayCall(()=> position.removeChild(thruBitmap), dur);
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
        position.addChild(newBitmap);
        position.addChild(fadeBackground);
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
        vn.juggler.delayCall(()=> position.removeChild(fadeBackground), dur);
        break;
      case 'none':
        if(currentBitmap != null) position.removeChild(currentBitmap);  
        position.addChild(newBitmap);
        vn.prevNext = [true,true];
        break;
      }
      if(tween != null) tween.onComplete = () { if(currentBitmap != null) { position.removeChild(currentBitmap); } newBitmap.alpha = 1; vn.prevNext = [true,true]; };
      else { vn.prevNext = [true,true]; }   
  }
  
}