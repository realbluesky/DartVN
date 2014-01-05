library dartvn;

import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'package:stagexl_richtextfield/stagexl_richtextfield.dart';
import 'package:yaml/yaml.dart';
import 'dart:math' show max, min;

part 'src/config.dart';
part 'src/character.dart';
part 'src/script.dart';
part 'src/option.dart';
part 'src/option/alias.dart';
part 'src/option/channel.dart';
part 'src/option/layer.dart';
part 'src/option/position.dart';
part 'src/option/vntransition.dart';
part 'src/verb.dart';
part 'src/verb/play.dart';
part 'src/verb/set.dart';

ResourceManager resourceManager;
Stage stage;
Script script;

class VN extends DisplayObjectContainer implements Animatable {

  Juggler _juggler;
  GlassPlate _glassPlate;
  Juggler get juggler => _juggler;
  List<bool> prevNext = [false,true];
  Map options;
  Map assets;
  Map<String, Channel> channels = {};
  Map<String, Alias> aliases = {};

  VN(html.CanvasElement canvas) {
    resourceManager = new ResourceManager();
    var config = new Config(canvas, this);
    _juggler = new Juggler();
    this.name = 'vn';
    config.onConfig = ((config) {
      options = config.config['options'];
      assets = config.config['assets'];
      _glassPlate = new GlassPlate(stage.sourceWidth, stage.sourceHeight);
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

  destroy() {
    //stop audio
    channels.forEach((k,v) {
      v.plays.forEach((p) => p.stop());
    });
    stage.juggler.remove(this);
    stage.removeChild(this);
  }

  bool advanceTime(num time) {
    _juggler.advanceTime(time);
  }

  static Map<String, String> scaleMode =
    {'exactFit': StageScaleMode.EXACT_FIT, 'noBorder': StageScaleMode.NO_BORDER,
     'noScale': StageScaleMode.NO_SCALE, 'showAll': StageScaleMode.SHOW_ALL};

  static Map<String, String> align =
    {'bottom': StageAlign.BOTTOM, 'bottomLeft': StageAlign.BOTTOM_LEFT, 'bottomRight': StageAlign.BOTTOM_RIGHT,
     'top': StageAlign.TOP, 'topLeft': StageAlign.TOP_LEFT, 'topRight': StageAlign.TOP_RIGHT,
     'left': StageAlign.LEFT, 'right': StageAlign.RIGHT, 'none': StageAlign.NONE};

  static Map<String, EaseFunction> ease =
    {'linear': TransitionFunction.linear, 'sine': TransitionFunction.sine,
     'cosine': TransitionFunction.cosine, 'random': TransitionFunction.random, 'easeInQuadratic': TransitionFunction.easeInQuadratic,
     'easeOutQuadratic': TransitionFunction.easeOutQuadratic, 'easeInOutQuadratic': TransitionFunction.easeInOutQuadratic,
     'easeOutInQuadratic': TransitionFunction.easeOutInQuadratic, 'easeInCubic': TransitionFunction.easeInCubic,
     'easeOutCubic': TransitionFunction.easeOutCubic, 'easeInOutCubic': TransitionFunction.easeInOutCubic,
     'easeOutInCubic': TransitionFunction.easeOutInCubic, 'easeInQuartic': TransitionFunction.easeInQuartic,
     'easeOutQuartic': TransitionFunction.easeOutQuartic, 'easeInOutQuartic': TransitionFunction.easeInOutQuartic,
     'easeOutInQuartic': TransitionFunction.easeOutInQuartic, 'easeInQuintic': TransitionFunction.easeInQuintic,
     'easeOutQuintic': TransitionFunction.easeOutQuintic, 'easeInOutQuintic': TransitionFunction.easeInOutQuintic,
     'easeOutInQuintic': TransitionFunction.easeOutInQuintic, 'easeInCircular': TransitionFunction.easeInCircular,
     'easeOutCircular': TransitionFunction.easeOutCircular, 'easeInOutCircular': TransitionFunction.easeInOutCircular,
     'easeOutInCircular': TransitionFunction.easeOutInCircular, 'easeInSine': TransitionFunction.easeInSine,
     'easeOutSine': TransitionFunction.easeOutSine, 'easeInOutSine': TransitionFunction.easeInOutSine,
     'easeOutInSine': TransitionFunction.easeOutInSine, 'easeInExponential': TransitionFunction.easeInExponential,
     'easeOutExponential': TransitionFunction.easeOutExponential, 'easeInOutExponential': TransitionFunction.easeInOutExponential,
     'easeOutInExponential': TransitionFunction.easeOutInExponential, 'easeInBack': TransitionFunction.easeInBack,
     'easeOutBack': TransitionFunction.easeOutBack, 'easeInOutBack': TransitionFunction.easeInOutBack,
     'easeOutInBack': TransitionFunction.easeOutInBack, 'easeInElastic': TransitionFunction.easeInElastic,
     'easeOutElastic': TransitionFunction.easeOutElastic, 'easeInOutElastic': TransitionFunction.easeInOutElastic,
     'easeOutInElastic': TransitionFunction.easeOutInElastic, 'easeInBounce': TransitionFunction.easeInBounce,
     'easeOutBounce': TransitionFunction.easeOutBounce, 'easeInOutBounce': TransitionFunction.easeInOutBounce,
     'easeOutInBounce': TransitionFunction.easeOutInBounce};

}