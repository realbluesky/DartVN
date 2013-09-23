part of dartvn;

class Channel extends Option {
  String name;
  List<Play> plays = [];
  
  Channel(this.name);
  
  Play add(Play sound) {
    plays.add(sound);
    return sound;
  }
  
  
}