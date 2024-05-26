class CustomHitbox {
  CustomHitbox({
    required this.offsetX,
    required this.offsetY,
    required this.width,
    required this.height,
  });

  final double height;
  final double offsetX;
  final double offsetY;
  final double width;

  @override
  String toString() {
    return 'CustomHitbox(offsetX: $offsetX, offsetY: $offsetY, width: $width, height: $height)';
  }
}
