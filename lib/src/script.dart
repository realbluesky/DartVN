part of dartvn;

class Script {
  List _script;
  Map<String, int> _labels = {};
  int _currentLine;
  int get numLines => _script.length;
  
  
  Script(List script) {
    _script = script;
    _currentLine = -1;
    //build label map
    for (var i = 0; i < _script.length; i++) {
      if(_script[i][0] == 'label') _labels[_script[i][1]] = i;
    }
  }
  
  dynamic next() {
    if(this.numLines>_currentLine+1) { 
      _currentLine++;
      return exec();
    } else return false;
  }
  
  dynamic prev() {
    if(_currentLine>0) { 
      _currentLine--;
      return exec();
    } else return false;
  }
  
  dynamic goto(label) {
    if(_labels.containsKey(label)) {
      _currentLine = _labels[label];
      return exec();
    }
  }
  
  dynamic exec() {
    List line;
    Map options = {};
    line = _script[_currentLine];
    
    var verb = line[0];
    List args = line.sublist(1);
    
    switch(verb) {
      case 'set': new Set(args);
        break;
      case 'label': next();
        break;
      case 'goto': goto(args[0]);
        break;
      default:
        print('Unrecognized verb, $verb');
        next();
        break;
    }
    
  }
  
     
      
    
  
  
}