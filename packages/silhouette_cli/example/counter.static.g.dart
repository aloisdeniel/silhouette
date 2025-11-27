class Counter {
  final int count;

  late final int double;

  Counter({this.count = 0}) {
    double = count * 2;
  }

  void build(StringBuffer buffer) {
    buffer.write("<div");
    buffer.write(">");
    buffer.write("<h1");
    buffer.write(">");
    buffer.write("Counter Example");
    buffer.write("</h1>");
    buffer.write("<p");
    buffer.write(">");
    buffer.write("Count: ");
    buffer.write(count);
    buffer.write("</p>");
    buffer.write("<p");
    buffer.write(">");
    buffer.write("Double: ");
    buffer.write(double);
    buffer.write("</p>");
    buffer.write("<button");
    buffer.write(">");
    buffer.write("Increment");
    buffer.write("</button>");
    buffer.write("<button");
    buffer.write(">");
    buffer.write("Decrement");
    buffer.write("</button>");
    if (count > 10) {
      buffer.write("<p");
      buffer.write(">");
      buffer.write("Count is greater than 10!");
      buffer.write("</p>");
    }
    else {
      buffer.write("<p");
      buffer.write(">");
      buffer.write("Count is 10 or less");
      buffer.write("</p>");
    }
    buffer.write("</div>");
  }
}

