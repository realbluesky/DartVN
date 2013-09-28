part of dartvn;

class Play extends Verb {
  Channel channel;
  Sound sound;

  Play(List args) {
    VN vn = stage.getChildByName('vn');
    var channelName = args[0];
    var soundName = args[1];
    //add options as they present themselves - loop, crossfading, etc
    channel = vn.channels[channelName];
    sound = resourceManager.getSound(soundName);
    channel.add(sound.play());
    script.next();
  }

}