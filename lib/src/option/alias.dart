part of dartvn;

class Alias extends Option {
  List alias;

  Alias(this.alias);

  List apply(List line) {
    line = new List.from(line.map((l) {
      return (l is String && (l.contains(new RegExp(r'[,:"]'))||l.contains(':'))?'"'+l+'"':l);
    }));

    var string = alias.toString();
    print(string);
    for(var i = 1; i<line.length; i++) string = string.replaceAll(':'+i.toString(), line[i].toString());
    print(string);
    return loadYaml(string);
  }

}