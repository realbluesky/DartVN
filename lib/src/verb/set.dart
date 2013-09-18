part of dartvn;

class Set extends Verb {
  
  Set(List args) {
    var posName; 
    var value; 
    Map posArgs; 
    var priorObject; 
    var newName; 
    Position position;
    VN vn = stage.getChildByName('vn');
    Map opts = {};// = vn.options; can restore this when addAll is implemented
    Layer layer = vn.getChildByName(args[0]);
    if(args.length>1) posName = args[1];
    if(args.length>2) value = (args[2]=="")?null:args[2];
    if(args.length>3) {
      //can't do this yet because YamlMap doesn't implement addAll, instead have below 5 lines
      //opts.addAll(args[3]);
      opts = args[3];
      vn.options['defaults'].forEach((k,v) {
        opts.putIfAbsent(k, ()=>v);  
      });
    } else {
      opts = vn.options['defaults'];
    }
        
    if(posName is String) {
      posArgs = vn.options['positions'][posName];
      if(layer.getChildByName(posName) == null) layer.addChild(new Position(posArgs)..name = posName);
      position = layer.getChildByName(posName);
      if(opts['mode']!='add' && position.numChildren > 0) priorObject = position.getChildAt(0);
      newName = posName;
    } else if(posName is Map) { //single-use position specified
      posArgs = posName;
      layer.addChild(new Position(posArgs)..name = value.toString());
      newName = value.toString();
    } else { //no position/value specified, emptying this layer
      vn.juggler.tween(layer, opts['dur'], TransitionFunction.easeInQuadratic)
        ..animate.alpha.to(0)
        ..onComplete = () {
         if(layer.numChildren>0) layer.removeChildren();
         layer.alpha = 1;
         if(opts['wait'] is num) vn.juggler.delayCall(()=> script.next(), opts['wait']);
        };     
        return; //free to jump out now
    }
    
    var newObject;
    //eventually add Map detection for gradients?    
    if(value is num) newObject = new Bitmap(new BitmapData(stage.width.toInt(), stage.height.toInt(), false, value));
    else if(vn.assets['images'].containsKey(value)) newObject = new Bitmap(resourceManager.getBitmapData(value));
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
      newObject = new Bitmap(drawn); 
    } else if(value is String) { //not an image or shape, so just display the text
      List tf = vn.options['text_formats'][opts['text_format']];
      newObject = new TextField(value, new TextFormat(tf[0], tf[1], tf[2], bold:tf[3], italic:tf[4]))..autoSize = TextFieldAutoSize.LEFT;
    } else if(priorObject != null) { //no value set, empty position
      if(position != null) {
        vn.juggler.tween(position, opts['dur'], TransitionFunction.easeInQuadratic)
          ..animate.alpha.to(0)
          ..onComplete = () { layer.removeChild(position); if(opts['wait'] is num) vn.juggler.delayCall(()=> script.next(), opts['wait']); };
        if(opts['wait'] == 'none' || opts['wait'] == null) script.next();
        return; //free to jump out 
      }
      newObject = new Bitmap();
    }
    
    //position.add(newObject);
    newObject.name = newName;
    
    //disable user script movement
    vn.prevNext = [false,false];
    
    switch(opts['trans']) {
      case 'fade': new FadeTransition(position, newObject, opts);
        break;
      case 'fadethru': new FadeThruTransition(position, newObject, opts);
        break;
      case 'fadeacross': new FadeAcrossTransition(position, newObject, opts);       
        break;
      case 'none':
        if(priorObject != null) position.removeChild(priorObject);  
        position.addChild(newObject);
        if(opts['wait'] is num) vn.juggler.delayCall(()=> script.next(), opts['wait']);
        break;
      }
    
    if(opts['wait'] == 'none' || opts['wait'] == null) script.next();
      
  }
  
}