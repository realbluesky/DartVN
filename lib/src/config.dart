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
    
    //set some defaults where not provided
    Map defaults = {'dur': 1.0, 'dir': 'right', 'trans': 'fade', 'width':1920, 'height':1080, 'layers': ['bg']};
    defaults.forEach((k,v) {
      _config['options'].putIfAbsent(k, ()=>v);  
    });
    
    //add layers, glassplate added onConfig so it is always on top
    _config['options']['layers'].forEach((v) => _vn.addChild(new Layer()..name = v));
    
    var opt = _config['options'];
    var canvas = html.query('#${opt['stage_id']}');
    stage = new Stage('vnStage', canvas, opt['width'], opt['height']);
    stage.scaleMode = VN.scaleMode[opt['scale']];
    stage.align = VN.align[opt['align']];
    
    var renderLoop = new RenderLoop();
    renderLoop.addStage(stage);
    
    //load assets
    if(_config.containsKey('assets')) {
      Map assets = _config['assets'];
      var imagePath = assets.containsKey('image_path')?assets['image_path']:'';
      if(assets.containsKey('images')) assets['images'].forEach((name, String url) {
        if(url.endsWith('.json')) resourceManager.addTextureAtlas(name, imagePath + url, TextureAtlasFormat.JSONARRAY);
        else resourceManager.addBitmapData(name, imagePath + url); 
      });
      if(assets.containsKey('sounds')) assets['sounds'].forEach((name, url) => resourceManager.addSound(name, imagePath + url));
    }
    
    //add characters
    /*
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
    */
    
    _vn.mask = new Mask.rectangle(0, 0, opt['width'], opt['height']);
    stage.addChild(_vn);
    stage.juggler.add(_vn);
    
    //add script
    script = new Script(_config['script']);
    
    resourceManager.load().then((rm) {
      if(onConfig != null) onConfig(this);
    });
      
  }


}