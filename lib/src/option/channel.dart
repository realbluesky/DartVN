part of dartvn;

class Channel extends Option {
  String name;
  List<SoundChannel> plays = [];

  Channel(this.name);

  SoundChannel add(SoundChannel sound) {
    plays.add(sound);
    return sound;
  }


}