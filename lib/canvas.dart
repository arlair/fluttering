import 'dart:typed_data';
import 'dart:ui';
import 'dart:math';
import 'package:flutter/services.dart';
Color color;
List<Offset> _points = [];
List<Color> _color = [];
List<double> _size = [];
Random random = Random();
Rect paintBounds = Offset.zero & (window.physicalSize / window.devicePixelRatio);
Picture paint(Rect paintBounds) {
  final PictureRecorder recorder = PictureRecorder();
  final Canvas canvas = Canvas(recorder, paintBounds);
  loop( (p) {
    canvas.drawCircle(
      _points[p],
      _size[p],
      Paint()
        ..color = _color[p],
    );
  });
  return recorder.endRecording();
}
void loop(Function f) {
  for (var p = 0; p < 999; p++) {
    f(p);
  }
}
Scene composite(Picture picture, Rect paintBounds) {
  final double devicePixelRatio = window.devicePixelRatio;

  final Float64List deviceTransform = Float64List(16)
    ..[0] = devicePixelRatio
    ..[5] = devicePixelRatio
    ..[10] = 1.0
    ..[15] = 1.0;
  final SceneBuilder sceneBuilder = SceneBuilder()
    ..pushTransform(deviceTransform)
    ..addPicture(Offset.zero, picture)
    ..pop();
  return sceneBuilder.build();
}
void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    loop( (p) {
      _points.add(Offset(random.nextDouble() * paintBounds.width, random.nextDouble() * paintBounds.height));
      _size.add(random.nextDouble() * 3);
      _color.add(Color(random.nextInt(2147483647)));
    });
    window.onBeginFrame = (Duration timeStamp) {
      loop( (p) {
        _color[p] = _color[p].withAlpha(max(0, min(255, _color[p].alpha + random.nextInt(19) - 9)));
      });
      final Picture picture = paint(paintBounds);
      final Scene scene = composite(picture, paintBounds);
      window.render(scene);
      window.scheduleFrame();
    };
    window.scheduleFrame();
  });
}