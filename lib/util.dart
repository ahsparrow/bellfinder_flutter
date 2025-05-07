const colour = [
  0,
  0,
  0,
  0xffee675c,
  0xfffa903d,
  0xfffcc935,
  0xff5ab974,
  0xff5ab974,
  0xffaf5cf7,
  0xffaf5cf7,
  0xff4ecde6,
  0xff4ecde6,
  0xffff63b8,
];

int bellColour(int bells) {
  return (bells <= 12) ? colour[bells] : colour[12];
}
