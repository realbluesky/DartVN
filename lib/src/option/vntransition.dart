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
  var tween;
  
  void _before() {
    //always need to check for prior if mode isn't add
    if(opts['mode']!='add' && position.numChildren > 0) prior = position.getChildAt(0);
  }
  
  void _during() {
    //print(args.toString());
  }
  
  void _after() {
    //if prior was set, need to remove it
    if(prior != null) position.removeChild(prior);
    current.alpha = 1;
    if(opts['wait'] == 'user') vn.prevNext = [true,true];
    else if(opts['wait'] is num) vn.juggler.delayCall(()=> script.next(), opts['wait']);
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
    var gradientWidthHeight = [current.width*fadePortion,0];
    var pathWidthHeight = [current.width*fadePortion,current.height];
    bool horizontal = true;
    var startStop = [-current.width*fadePortion, current.width];
    switch(opts['dir']) {
      case 'left':
        stops = new List.from(stops.reversed);
        startStop = [current.width,-current.width*fadePortion];
        break;
      case 'down':
        gradientWidthHeight = [0,current.height*fadePortion];
        pathWidthHeight = [current.width,current.height*fadePortion];
        horizontal = false;
        startStop = [-current.height*fadePortion, current.height];
        break;
      case 'up':
        stops = new List.from(stops.reversed);
        gradientWidthHeight = [0,current.height*fadePortion];
        pathWidthHeight = [current.width,current.height*fadePortion];
        horizontal = false;
        startStop = [current.height,-current.height*fadePortion];
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
        ..fillGradient(gradient);
    var alphaMask = new BitmapData(fade.width, fade.height, true, 0x00000000)
        ..draw(fade);
    temp
        ..filters = [new AlphaMaskFilter(alphaMask)]
        ..applyCache(startStop[0].toInt(),startStop[1].toInt(),fade.width.toInt(),fade.height.toInt());
    position.add(temp);
    position.add(current);
    vn.juggler.transition(startStop[0], startStop[1], opts['dur'], VN.ease[opts['ease']], (value) {
      temp.applyCache(horizontal?value.toInt():0, horizontal?0:value.toInt(), fade.width.toInt(),fade.height.toInt());
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
    }).onComplete = _after;    
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
    
    tween = vn.juggler.transition(start, horizontal?current.x:current.y, opts['dur'], VN.ease[opts['ease']], (value) {
      if(horizontal) current.x = value;
      else current.y = value;

    });
    
    tween..onStart = (() =>  current.alpha=1 )
         ..onComplete = _after; 
  }
 
}
  
