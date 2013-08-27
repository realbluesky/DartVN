part of dartvn;

class Character extends Sprite {
  String id;
  String name;
  Map<String, Sprite> emotions = {}; 
  Sprite curEmotion;
  
  Character(this.id, this.name, this.emotions);
  
  setEmotion(String emotion) {
    curEmotion = emotions[emotion];
  }
 
}