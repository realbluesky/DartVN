part of dartvn;

typedef void VNConfigFunction(Config config);

class Config {
  VNConfigFunction onConfig;
  Map _config;
  Map characters;
  VN _vn;
  
  Map get config => _config;
  
  Config(String configYaml, VN vn) {
    _vn = vn;
    var request = html.HttpRequest.getString(configYaml).then(configure);
  }
  
  configure(String response) {
    _config = loadYaml(response);
    
    var opt = _config['options'];
    var canvas = html.query('#${opt['stage_id']}');
    stage = new Stage('vnStage', canvas, opt['width'], opt['height']);
    //todo load these two from config yaml somehow...
    stage.scaleMode = StageScaleMode.SHOW_ALL;
    stage.align = StageAlign.NONE;
    
    var renderLoop = new RenderLoop();
    renderLoop.addStage(stage);
    
    //load assets
    if(_config.containsKey('assets')) {
      Map assets = _config['assets'];
      assets.forEach((name, url) => resourceManager.addBitmapData(name, url));
    }
    
    //add characters
    _config['characters'].forEach((String charid, Map charmap) {
      Character char = new Character(charid, charmap['name'], {});
      charmap['emotions'].forEach((String emoid, Map emomap) {
        if(emomap['atlas'] != null) resourceManager.addTextureAtlas(charid+'.'+emoid, emomap['atlas'], TextureAtlasFormat.JSONARRAY);
        resourceManager.addBitmapData(charid+'.'+emoid, emomap['src']);
        char.emotions[emoid] = new Sprite(); 
      });
      //default emotion to first emotion - keys in map are alphabetically sorted, not order in yaml?
      char.setEmotion(char.emotions.keys.first);
    });
    
    stage.addChild(_vn);
    stage.juggler.add(_vn);
    
    //add script
    script = new Script(_config['script']);
    
    resourceManager.load().then((rm) {
      if(onConfig != null) onConfig(this);
    });
      
  }


}