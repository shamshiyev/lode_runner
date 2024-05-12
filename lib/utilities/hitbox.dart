class CustomHitbox {
  final double offsetX;
  final double offsetY;
  final double width;
  final double height;

  CustomHitbox({
    required this.offsetX,
    required this.offsetY,
    required this.width,
    required this.height,
  });

  @override
  String toString() {
    return 'CustomHitbox(offsetX: $offsetX, offsetY: $offsetY, width: $width, height: $height)';
  }
}
