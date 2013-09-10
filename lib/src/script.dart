part of dartvn;

class Script {
  List _script;
  int currentLine;
  int get numChildren => _script.length;
  
  
  Script(List script) {
    _script = script;
    currentLine = -1;
  }
  
  dynamic next() {
    if(this.numChildren>currentLine+1) { 
      currentLine++;
      return exec();
    } else return false;
  }
  
  dynamic prev() {
    if(currentLine>0) { 
      currentLine--;
      return exec();
    } else return false;
  }
  
  dynamic exec() {
    List line;
    Map options = {};
    line = _script[currentLine];
    
    var verb = line[0];
    List args = line.sublist(1);
    
    switch(verb) {
      case 'set': new Set(args);
        break;
      default:
        print('Unrecognized verb, $verb');
        break;
    }
    
  }
  
     
      
    
  
  
}