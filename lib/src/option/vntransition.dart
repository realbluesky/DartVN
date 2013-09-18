part of dartvn;

abstract class VNTransition extends Option {
  String name;
  Position position;
  var current;
  Map args;
  VN vn;
  
  VNTransition(Position position, var current, Map args) { 
    this.vn = stage.getChildByName('vn'); 
    this.position = position;
    this.current = current;
    this.args = args;
    before();
  }
  
  DisplayObjectContainer layer;
  DisplayObject prior;
  DisplayObject temp;
  var tween;
  
  void before() {
    //always need to check for prior if mode isn't add
    if(args['mode']!='add' && position.numChildren > 0) prior = position.getChildAt(0);
    during();
  }
  
  void during() {
    //print(args.toString());
  }
  
  void after() {
    //if prior was set, need to remove it
    if(prior != null) position.removeChild(prior);
    current.alpha = 1;
    if(args['wait'] == 'user') vn.prevNext = [true,true];
    else if(args['wait'] is num) vn.juggler.delayCall(()=> script.next(), args['wait']);
  }
}

//-----------------------------------------------------------------------------//
class FadeTransition extends VNTransition {  
  FadeTransition(Position position, var current, Map args) : super(position, current, args) {
    this.name = 'fade';
  }
  
  before() {
    super.before();
  }
  
  during() {
    super.during();
    current.alpha = 0;
    position.add(current);
    tween = vn.juggler.tween(current, args['dur'], TransitionFunction.easeInQuadratic);
    tween..animate.alpha.to(1.0)
         ..onComplete = after;
  }
  
  after() {
    super.after();
  }
  
}

//---------------------------------------------------------------------------------//
class FadeThruTransition extends VNTransition {  
  FadeThruTransition(Position position, var current, Map args) : super(position, current, args) {
    this.name = 'fadethru';
  }
  
  before() {
    super.before();
  }
  
  during() {
    super.during();
    temp = new Bitmap(new BitmapData(current.width.toInt(), current.height.toInt(), false, args['color']))
        ..alpha = 0
        ..filters = [new AlphaMaskFilter(current.bitmapData)]
        ..applyCache(0, 0, current.width.toInt(), current.height.toInt());
    current.alpha = 0;
    position.add(current);
    position.add(temp);

    vn.juggler.tween(temp, args['dur']/2, TransitionFunction.easeInQuadratic)
        ..animate.alpha.to(1.0)
        ..onComplete = () => current.alpha = 1;

    vn.juggler.tween(temp, args['dur']/2, TransitionFunction.easeInQuadratic)
      ..animate.alpha.to(0.0)
      ..delay = args['dur']/2
      ..onComplete = after;
    
    vn.juggler.delayCall(()=> position.removeChild(temp), args['dur']);
  }
  
  after() {
    super.after();
    
  }
  
}

//---------------------------------------------------------------------------------//
class FadeAcrossTransition extends VNTransition {  
  FadeAcrossTransition(Position position, var current, Map args) : super(position, current, args) {
    this.name = 'fadeacross';
  }
  
  before() {
    super.before();
    current.clipRectangle = new Rectangle.zero();    
  }
  
  during() {
    super.during();
    var fadePortion = 1/5;
    var stops = [0,1];
    var gradientWidthHeight = [current.width*fadePortion,0];
    var pathWidthHeight = [current.width*fadePortion,current.height];
    bool horizontal = true;
    var startStop = [-current.width*fadePortion, current.width];
    switch(args['dir']) {
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
    tween = vn.juggler.transition(startStop[0], startStop[1], args['dur'], TransitionFunction.linear, (value) {
      temp.applyCache(horizontal?value.toInt():0, horizontal?0:value.toInt(), fade.width.toInt(),fade.height.toInt());
      switch(args['dir']) {
        case 'right': current.clipRectangle = new Rectangle(0, 0, min(max(0,value+1),current.width.toInt()), current.height.toInt());
        break;
        case 'left': current.clipRectangle = new Rectangle(max(value-startStop[1]-1,0), 0, max(startStop[0]-value+startStop[1],0), current.height.toInt());
        break;
        case 'down': current.clipRectangle = new Rectangle(0, 0, current.width.toInt(), min(max(0,value+1),current.height.toInt()));
        break;
        case 'up': current.clipRectangle = new Rectangle(0, max(value-startStop[1]-1,0), current.width.toInt(), max(startStop[0]-value+startStop[1],0));
        break;
      }
    });    
    vn.juggler.delayCall(()=> position.removeChild(temp), args['dur']);
    tween.onComplete = after;
  }
  
  after() {
    super.after();
  }
  
}