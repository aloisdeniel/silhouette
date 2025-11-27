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
    buffer.write("<div><h1>");
    buffer.write(greeting);
    buffer.write("</h1><p>");
    buffer.write(displayCount);
    buffer.write("</p><p>Name is ");
    buffer.write(name);
    buffer.write("</p></div>");
  }
}

