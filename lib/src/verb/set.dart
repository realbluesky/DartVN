part of dartvn;

class Set extends Verb {
  List args;

  bool mod;

  Set(List args, {this.mod: false}) {
    var posName;
    var value;
    Map posArgs;
    var priorObject;
    var newName;
    Position position;
    VN vn = stage.getChildByName('vn');
    Map opts = new Map.from(vn.options['defaults']);
    Layer layer = vn.getChildByName(args[0]);
    if(args.length>1) posName = (args[1]=="")?null:args[1];
    if(args.length>2) value = (args[2]=="")?null:args[2];
    if(args.length>3) (args[3] as Map).forEach((k,v) { opts[k] = v; });

    var newObject;

    //actually setting up, not mod[ifying]
    if(!mod) {
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
        vn.juggler.tween(layer, opts['dur'], VN.ease[opts['ease']])
          ..animate.alpha.to(0)
            ..onComplete = () {
          if(layer.numChildren>0) layer.removeChildren();
          layer.alpha = 1;
          if(opts['wait'] is num) vn.juggler.delayCall(()=> script.next(), opts['wait']);
        };
        return; //free to jump out now
      }

      //eventually add Map detection for gradients?
      if(value == null) {
        if(priorObject != null) { //no value set, empty position
          if(position != null) {
            vn.juggler.tween(position, opts['dur'], VN.ease[opts['ease']])
              ..animate.alpha.to(0)
              ..onComplete = () { layer.removeChild(position); if(opts['wait'] is num) vn.juggler.delayCall(()=> script.next(), opts['wait']); };
            if(opts['wait'] == 'none' || opts['wait'] == null) script.next();
            return; //free to jump out
          }
        newObject = new Bitmap();
        }
      }
      //color
      else if(value is num) newObject = new Bitmap(new BitmapData(stage.width.toInt(), stage.height.toInt(), false, value));
      //asset?
      else if(vn.assets != null) {
        if(vn.assets['images'].containsKey(value.split('.')[0])) {
          if(value.contains('.')) newObject = new Bitmap(resourceManager.getTextureAtlas(value.split('.')[0]).getBitmapData(value.split('.')[1]));
          else newObject = new Bitmap(resourceManager.getBitmapData(value));
        }
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
        }
      }
        //not a color or asset (image or shape), so just display the text
        else if(value is String) {
        Map tf = vn.options['text_formats'][opts['text_format']];
        newObject = new TextField(value, new TextFormat(tf['font'], tf['size'], tf['color']))
          ..multiline = true
          ..wordWrap = true
          ..defaultTextFormat.align = tf.containsKey('align')?tf['align']:TextFormatAlign.LEFT
          ..width = tf.containsKey('width')?tf['width']:stage.sourceWidth;

        if(tf.containsKey('height')) newObject.height=tf['height'];

      }

      //position.add(newObject);
      newObject.name = (value == null)?'':value.toString();


    } else { //mod[ifying]
      position = layer.getChildByName(posName);
      newObject = position.getChildByName(value);
      opts['mod'] = true;
    }

    //disable user script movement
    vn.prevNext = [false,false];


    //transition map, will be able to be moved later
    VNTransition vnt = new VNTransition(position, newObject, opts);
    Map transMap = {'fade': vnt.fadeTransition, 'fadeout': vnt.fadeOutTransition, 'fadethru': vnt.fadeThruTransition,
                    'fadeacross': vnt.fadeAcrossTransition, 'slide': vnt.slideTransition, 'scale': vnt.scaleTransition,
                    'pan': vnt.panTransition, 'crossfade': vnt.crossFadeTransition};
    if(transMap.containsKey(opts['trans'])) {
      transMap[opts['trans']]();
    }
    else {
        if(priorObject != null) position.removeChild(priorObject);
        position.addChild(newObject);
        if(opts['wait'] is num) vn.juggler.delayCall(()=> script.next(), opts['wait']);
      }

    if(opts['wait'] == 'none' || opts['wait'] == null) script.next();

  }

}