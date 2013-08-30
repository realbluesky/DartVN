library dartvn;

import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'package:yaml/yaml.dart';

part 'src/config.dart';
part 'src/character.dart';
part 'src/layer.dart';
part 'src/script.dart';

ResourceManager resourceManager;
Stage stage;
Script script;

class VN extends DisplayObjectContainer implements Animatable {

  Juggler _juggler;
  GlassPlate _glassPlate;
  Juggler get juggler => _juggler;
  List<bool> prevNext = [false,true];

  VN(String configYaml) {
    resourceManager = new ResourceManager();
    var config = new Config(configYaml, this);
    _juggler = new Juggler();
    this.name = 'vn';
    config.onConfig = ((config) {
      _glassPlate = new GlassPlate(config.config['options']['width'], config.config['options']['height']);
      _glassPlate.onMouseClick.listen(_onMouseClick);
      _glassPlate.onKeyDown.listen(_onKeyDown);
      addChild(_glassPlate);
      stage.focus = _glassPlate;
      
      script.next();

      //working with flipbooks and texture atlas
      /*
      var bitmapDatas = resourceManager.getTextureAtlas('gumshoe.laughing').getBitmapDatas('laughing');
      var flipBook = new FlipBook(bitmapDatas);
      flipBook.frameDurations = [2,.2];
      flipBook.x = 200;
      flipBook.y = 200;
      flipBook.play();
      stage.addChild(flipBook);
      stage.juggler.add(flipBook);  
      */
    });
    
  }
  
  _onMouseClick(MouseEvent me) {
    if(prevNext[1]) script.next();
  }
  
  _onKeyDown(KeyboardEvent ke) {
    final List nextKeys = [html.KeyCode.SPACE, html.KeyCode.ENTER, html.KeyCode.TAB, 
                              html.KeyCode.RIGHT, html.KeyCode.DOWN, html.KeyCode.PAGE_DOWN];
    
    final List prevKeys = [html.KeyCode.LEFT, html.KeyCode.UP, html.KeyCode.PAGE_UP];
    
    if(nextKeys.contains(ke.keyCode) && prevNext[1]) { script.next(); ke.stopImmediatePropagation(); }
    else if(prevKeys.contains(ke.keyCode) && prevNext[0]) { script.prev(); ke.stopImmediatePropagation(); }
    
  }
  
  bool advanceTime(num time) {
    _juggler.advanceTime(time);
  }

}