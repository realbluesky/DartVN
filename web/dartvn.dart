import '../lib/vn.dart';
import 'dart:html' as html;

void main() {
  
  var script = html.query('meta[name=vnscript]').attributes['content'];  
  new VN(script);
  
}
