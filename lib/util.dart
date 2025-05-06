const hue = [0, 0, 0, 0, 51, 102, 154, 206, 206, 257, 257, 308, 308];

double bellHue(int bells) {
  final val = (bells <= 12) ? hue[bells] : hue[12];
  return val.toDouble();
}
