class Greeting {
  final String name;
  final int count;

  late final String greeting;
  late final String displayCount;

  Greeting({this.name = 'World', this.count = 0}) {
    greeting = 'Hello, $name!';
    displayCount = 'Count: $count';
  }

  void build(StringBuffer buffer) {
    buffer.write("<div");
    buffer.write(">");
    buffer.write("<h1");
    buffer.write(">");
    buffer.write(greeting);
    buffer.write("</h1>");
    buffer.write("<p");
    buffer.write(">");
    buffer.write(displayCount);
    buffer.write("</p>");
    buffer.write("<p");
    buffer.write(">");
    buffer.write("Name is ");
    buffer.write(name);
    buffer.write("</p>");
    buffer.write("</div>");
  }
}

