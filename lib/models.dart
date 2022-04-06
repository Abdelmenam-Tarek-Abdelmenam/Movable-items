import 'dart:ui';

class PageModel {
  List<BoxModel> devices = [];
  String name;

  PageModel(this.name, this.devices);
}

class BoxModel {
  String name;
  Color color;
  BoxModel(this.name, this.color);
}
