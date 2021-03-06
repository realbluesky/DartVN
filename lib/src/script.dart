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

    //check for alias
    VN vn = stage.getChildByName('vn');
    if(vn.aliases.containsKey(line[0])) line = vn.aliases[line[0]].apply(line);

    //every line is a yaml array starting with a verb and followed by a number of arguments
    var verb = line[0];
    List args = line.sublist(1);

    switch(verb) {
      case 'play': new Play(args);
        break;
      case 'set': new Set(args);
        break;
      case 'mod': new Set(args, mod: true);
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