part of dartvn;

class VNTransition extends Option {
  String name;
  Position position;
  var current;
  Map opts;
  VN vn;

  VNTransition(Position position, var current, Map args) {
    this.vn = stage.getChildByName('vn');
    this.position = position;
    this.current = current;
    this.opts = args;
  }

  DisplayObjectContainer layer;
  DisplayObject prior;
  DisplayObject temp;
  Tween tween;

  void _before() {
    //always need to check for prior if mode isn't add
    if(opts['mode']!='add' && position.numChildren > 0) prior = position.getChildAt(0);
  }

  void _during() {
    //print(args.toString());
  }

  void _after() {
    //if prior was set, need to remove it
    if(prior != null && prior != current && position.getChildByName(prior.name) != null) position.removeChild(prior);
    current.alpha = 1;
    if(opts['for'] == 'user') vn.prevNext = [true,true];
    else if(opts['for'] is num) vn.juggler.delayCall(()=> script.next(), opts['for']);
  }

//-----------------------------------------------------------------------------//
 void fadeTransition() {
   name = 'fade';
   _before();
    _during();
    current.alpha = 0;
    position.add(current);
    tween = vn.juggler.tween(current, opts['dur'], VN.ease[opts['ease']]);
    tween..animate.alpha.to(1.0)
         ..onComplete = _after;
  }

//-----------------------------------------------------------------------------//
 void crossFadeTransition() {
    name = 'crossfade';
    _before();
    _during();
    current.alpha = 0;
    position.add(current);

    if(prior != null) vn.juggler.tween(prior, opts['dur']/2, VN.ease[opts['ease']])
      ..animate.alpha.to(0)
      ..onComplete = () => position.removeChild(prior);

    tween = vn.juggler.tween(current, opts['dur'], VN.ease[opts['ease']]);
    if(opts['gap'] is num) tween.delay = opts['dur'] + opts['gap'];
    tween..animate.alpha.to(1.0)
         ..onComplete = _after;
  }

//-----------------------------------------------------------------------------//
void fadeOutTransition() {
  name = 'fadeout';
  if(opts['mod'] == null) {
    _before();
    position.add(current);
  }

  tween = vn.juggler.tween(current, opts['dur'], VN.ease[opts['ease']]);
  tween..animate.alpha.to(0)
       ..onComplete = () {
         position.removeChild(current);
         if(opts['for'] == 'user') vn.prevNext = [true,true];
         else if(opts['for'] is num) vn.juggler.delayCall(()=> script.next(), opts['for']);
       };
}

//---------------------------------------------------------------------------------//
  void fadeThruTransition() {
    name = 'fadethru';
    _before();
    _during();
    if(current is! Bitmap) current = new Bitmap(new BitmapData(current.width.toInt(), current.height.toInt(), true, 0x00000000)..draw(current));
    temp = new Bitmap(new BitmapData(current.width.toInt(), current.height.toInt(), false, opts['color']))
        ..alpha = 0
        ..filters = [new AlphaMaskFilter(current.bitmapData)]
        ..applyCache(0, 0, current.width.toInt(), current.height.toInt());
    current.alpha = 0;
    position.add(current);
    position.add(temp);

    vn.juggler.tween(temp, opts['dur']/2, VN.ease[opts['ease']])
        ..animate.alpha.to(1.0)
        ..onComplete = () => current.alpha = 1;

    vn.juggler.tween(temp, opts['dur']/2, VN.ease[opts['ease']])
      ..animate.alpha.to(0.0)
      ..delay = opts['dur']/2
      ..onComplete = _after;

    vn.juggler.delayCall(()=> position.removeChild(temp), opts['dur']);
  }


//---------------------------------------------------------------------------------//
  void fadeAcrossTransition() {
    name = 'fadeacross';
    _before();
    _during();
    if(current is! Bitmap) current = new Bitmap(new BitmapData(current.width.toInt(), current.height.toInt(), true, 0x00000000)..draw(current));
    current.clipRectangle = new Rectangle.zero();
    var fadePortion = 1/5;
    var stops = [0,1];
    var gradientWidthHeight = [(current.width*fadePortion).toInt(),0];
    var pathWidthHeight = [(current.width*fadePortion).toInt(),current.height.toInt()];
    bool horizontal = true;
    var startStop = [(-current.width*fadePortion).toInt(), current.width.toInt()];
    switch(opts['dir']) {
      case 'left':
        stops = new List.from(stops.reversed);
        startStop = [current.width.toInt(),(-current.width*fadePortion).toInt()];
        break;
      case 'down':
        gradientWidthHeight = [0,(current.height*fadePortion).toInt()];
        pathWidthHeight = [current.width.toInt(),(current.height*fadePortion).toInt()];
        horizontal = false;
        startStop = [(-current.height*fadePortion).toInt(), current.height.toInt()];
        break;
      case 'up':
        stops = new List.from(stops.reversed);
        gradientWidthHeight = [0,(current.height*fadePortion).toInt()];
        pathWidthHeight = [current.width.toInt(),(current.height*fadePortion).toInt()];
        horizontal = false;
        startStop = [current.height.toInt(),(-current.height*fadePortion).toInt()];
        break;
    }
    Shape fade = new Shape();
    temp = new Bitmap(current.bitmapData);
    GraphicsGradient gradient = new GraphicsGradient.linear(0, 0, gradientWidthHeight[0], gradientWidthHeight[1])
      ..addColorStop(stops[0], 0xFF000000)
      ..addColorStop(stops[1], 0x00000000);
    fade.graphics
        ..beginPath()
        ..rect(0, 0, pathWidthHeight[0], pathWidthHeight[1])
        ..closePath()
        ..fillGradient(gradient)
        ;
    var alphaMask = new BitmapData(fade.width.toInt(), fade.height.toInt(), true, 0x00000000)
        ..draw(fade);
    var alphaMaskFilter = new AlphaMaskFilter(alphaMask); 
    temp
        ..filters = [alphaMaskFilter]
        //..applyCache(current.x.toInt(),current.y.toInt(),current.width.toInt(),current.height.toInt(), debugBorder: true);
        ..applyCache(startStop[0].toInt(),startStop[1].toInt(),fade.width.toInt(),fade.height.toInt(), debugBorder: true);
    position.add(temp);
    position.add(current);
    vn.juggler.transition(startStop[0], startStop[1], opts['dur'], VN.ease[opts['ease']], (value) {
            
      alphaMaskFilter.matrix
        ..identity()
        ..translate(horizontal?value:0, horizontal?0:value)
        ;
      temp.applyCache(horizontal?value:0, horizontal?0:value, fade.width.toInt(), fade.height.toInt(), debugBorder: true);
      
      //temp.refreshCache();

      switch(opts['dir']) {
        case 'right': current.clipRectangle = new Rectangle(0, 0, min(max(0,value+1),current.width.toInt()), current.height.toInt());
        break;
        case 'left': current.clipRectangle = new Rectangle(max(value-startStop[1]-1,0), 0, max(startStop[0]-value+startStop[1],0), current.height.toInt());
        break;
        case 'down': current.clipRectangle = new Rectangle(0, 0, current.width.toInt(), min(max(0,value+1),current.height.toInt()));
        break;
        case 'up': current.clipRectangle = new Rectangle(0, max(value-startStop[1]-1,0), current.width.toInt(), max(startStop[0]-value+startStop[1],0));
        break;
      }
      
      
    })..onComplete = _after
      ..roundToInt = true;
    vn.juggler.delayCall(()=> position.removeChild(temp), opts['dur']);
  }


//-----------------------------------------------------------------------------//
  void slideTransition() {
    name = 'slide';
    _before();
    _during();
    current.alpha=0;
    position.add(current); //sets current final position
    var start = { 'right': -current.width,
                  'left':   stage.width,
                  'up':     stage.height,
                  'down':  -current.height}[opts['dir']];
    var horizontal = ['right','left'].contains(opts['dir']);

    var trans = vn.juggler.transition(start, horizontal?current.x:current.y, opts['dur'], VN.ease[opts['ease']], (value) {
      if(horizontal) current.x = value;
      else current.y = value;

    });

    trans..onStart = (() =>  current.alpha=1 )
         ..onComplete = _after;
  }

//-----------------------------------------------------------------------------//
  void scaleTransition() {
    name = 'scale';
    if(opts['mod'] == null) {
      _before();
      position.add(current);
    }

    current.pivotX = current.width/2;
    current.pivotY = current.height/2;
    current.x += current.width/2;
    current.y += current.height/2;
    current.scaleX = current.scaleY = opts['range'][0];


    vn.juggler.tween(current, opts['dur'], VN.ease[opts['ease']])
      ..animate.scaleX.to(opts['range'][1])
      ..animate.scaleY.to(opts['range'][1])
      ..onComplete = _after;

  }

  void panTransition() {
    name = 'pan';
    //Bitmap current;

    if(opts['mod'] == null) {
      _before();
      position.add(current);
    }
    var nx = current.x + opts['dist'][0];
    var ny = current.y + opts['dist'][1];

    tween = vn.juggler.tween(current, opts['dur'], VN.ease[opts['ease']]);
    if(nx!=current.x) tween.animate.x.to(nx);
    if(ny!=current.y) tween.animate.y.to(ny);

    tween.onComplete = _after;

  }

}

