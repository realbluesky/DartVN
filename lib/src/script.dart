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
    var line;
    Map options = {};
    line = _script[currentLine];
    
    var verb = line[0];
    var subverb = line[1];
    var value = line[2];
    if(line.length>3) options = line[3];
    
    switch(verb) {
      case 'bg': new bg(subverb, value, options);        
        break;
      default:
        print('Unrecognized verb, $verb');
        break;
    }
    
  }
  
     
      
    
  
  
}