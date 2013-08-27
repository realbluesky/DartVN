library dartvn;

import 'dart:html';
import 'package:stagexl/stagexl.dart';
import 'package:yaml/yaml.dart';

part 'src/config.dart';
part 'src/character.dart';
part 'src/layer.dart';
part 'src/script.dart';

ResourceManager resourceManager;
Stage stage;
Script script;

class VN {

  Juggler _juggler;

  VN(String configYaml) {
    resourceManager = new ResourceManager();
    var config = new Config(configYaml);
    _juggler = new Juggler();
    config.onConfig = ((config) {
      
      script.next();
      /* working with flipbooks and texture atlas
      var bitmapDatas = resourceManager.getTextureAtlas('gumshoe.laughing').getBitmapDatas('laughing');
      var flipBook = new FlipBook(bitmapDatas, 5);
      flipBook.x = 200;
      flipBook.y = 200;
      flipBook.play();
      stage.addChild(flipBook);
      stage.juggler.add(flipBook);  
      */
    });
    
    
    
  }

}