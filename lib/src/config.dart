part of dartvn;

typedef void VNConfigFunction(Config config);

class Config {
  VNConfigFunction onConfig;
  Map _config;
  Map characters;
  html.CanvasElement _canvas;
  VN _vn;

  Map get config => _config;

  Config(html.CanvasElement canvas, VN vn) {
    _canvas = canvas;
    _vn = vn;
    var script = _canvas.attributes['data-script'];
    if(script.endsWith('.yaml') || script.endsWith('.yml') || script.endsWith('.json'))
      var request = html.HttpRequest.getString(script).then(configure);
    else { //probably not ok to assume a textarea here, but most times it should be...?
      html.TextAreaElement txt = html.querySelector(script);
      configure(txt.value);
    }
  }

  configure(String response) {
    _config = loadYaml(response);

    //set some defaults where not provided
    Map defaults = {'dur': 1.0, 'dir': 'right', 'gap': 'none', 'wait': 'none','trans': 'crossfade'};
    _config['options'].putIfAbsent('webgl', ()=>true);
    _config['options'].putIfAbsent('defaults', ()=>{});
    defaults.forEach((k,v) {
      _config['options']['defaults'].putIfAbsent(k, ()=>v);
    });

    //add channels for audio, stored in vn object for later access
    if(_config['options'].containsKey('channels')) {
      _config['options']['channels'].forEach((v) => _vn.channels[v] = new Channel(v));
    }

    //add aliases if present
    if(_config['options'].containsKey('aliases')) {
      _config['options']['aliases'].forEach((a,v) => _vn.aliases[a] = new Alias(v));
    }

    //add layers, glassplate added onConfig so it is always on top
    _config['options'].putIfAbsent('layers', ()=>['bg']);
    _config['options']['layers'].forEach((v) => _vn.addChild(new Layer()..name = v));

    var opt = _config['options'];
    if(opt.containsKey('width') && opt.containsKey('height')) stage = new Stage(_canvas, webGL: opt['webgl'], width: opt['width'], height: opt['height']);
    else stage = new Stage(_canvas, webGL: opt['webgl']);
    stage.scaleMode = opt.containsKey('scale')?VN.scaleMode[opt['scale']]:StageScaleMode.NO_SCALE;
    stage.align = opt.containsKey('align')?VN.align[opt['align']]:StageAlign.NONE;

    var renderLoop = new RenderLoop();
    renderLoop.addStage(stage);

    //load assets
    if(_config.containsKey('assets')) {
      Map assets = _config['assets'];
      var imagePath = assets.containsKey('image_path')?assets['image_path']:'';
      //TODO can't assume assets have images key...all these ifs containsKeys are nuts, gotta be a better way
      if(assets.containsKey('images')) assets['images'].forEach((name, String url) {
        if(url.endsWith('.json')) resourceManager.addTextureAtlas(name, imagePath + url, TextureAtlasFormat.JSONARRAY);
        else resourceManager.addBitmapData(name, imagePath + url);
      });
      var soundPath = assets.containsKey('sound_path')?assets['sound_path']:'';
      if(assets.containsKey('sounds')) assets['sounds'].forEach((name, url) => resourceManager.addSound(name, soundPath + url));
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

    _vn.mask = new Mask.rectangle(0, 0, stage.sourceWidth, stage.sourceHeight);
    stage.addChild(_vn);
    stage.juggler.add(_vn);

    //add script
    script = new Script(_config['script']);

    resourceManager.load().then((rm) {
      if(onConfig != null) onConfig(this);
    });
    
    //loading indicator
    resourceManager.onProgress.listen((e) {
      var finished = resourceManager.finishedResources;
      var pending = resourceManager.pendingResources;
      var failed = resourceManager.failedResources;
      print("Resource Progress -> finished: ${finished.length}, pending:${pending.length}, failed:${failed.length}");
    });

  }


}