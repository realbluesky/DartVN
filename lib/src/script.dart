part of dartvn;

class Script {
  List _script;
  int currentLine;
  int get numChildren => _script.length;
  
  Script(List script) {
    _script = script;
    currentLine = 0;
  }
  
  dynamic next() {
    var line;
    if(this.numChildren>currentLine) line = _script[currentLine++];
    else return false;
    
    var verb = line[0];
    var a1 = line[1];
    if(line.length>2) var a2 = line[2];
    if(line.length>3) var a3 = line[3];
    
    switch(verb) {
      case 'bg':
        Layer bgc = stage.getChildByName('background');
        var bg = new Bitmap(new BitmapData(stage.width.toInt(), stage.height.toInt(), false, a1));
        if(bgc.numChildren>0) bgc.removeChildren();
        bgc.addChild(bg);
        break;
      default:
        print('Unrecognized verb, $verb');
        break;
    }
    
  }
  
     
      
    
  
  
}