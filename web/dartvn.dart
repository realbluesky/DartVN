import '../lib/vn.dart';
import 'dart:html' as html;

Map<String, VN> vns = {};

void main() {
  html.ElementList canvas = html.queryAll('canvas[data-script]');
  canvas.forEach((html.CanvasElement c) {
    vns[c.id] = new VN(c);
  });

  html.ElementList reloadLinks = html.queryAll('[data-reload]');
  reloadLinks.forEach((html.Element el) {
    el.onClick.listen((e) {
      var canvasId = el.dataset['reload'];
      if(vns.containsKey(canvasId)) {
        VN vn = vns[canvasId];
        vn.destroy();
        vns[canvasId] = new VN(html.query('#'+canvasId));
      }
    });
  });

}
