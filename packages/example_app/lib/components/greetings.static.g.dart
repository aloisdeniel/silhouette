class Greetings {
  static const String componentId = 'silhouette-greetings-207724';

  final String name;
  final int count;

  late final String greeting;
  late final String displayCount;

  Greetings({this.name = 'World', this.count = 0}) {
    greeting = 'Hello, $name!';
    displayCount = 'Count: $count';
  }

  void html(StringBuffer buffer) {
    buffer.write("<div class=\"silhouette-greetings-207724\"><h1>");
    buffer.write(greeting);
    buffer.write("</h1><p>");
    buffer.write(displayCount);
    buffer.write("</p><p>Name is ");
    buffer.write(name);
    buffer.write("</p></div>");
  }

  static void style(StringBuffer buffer) {
    buffer.write(".silhouette-greetings-207724 div { \n    padding: 20px;\n    font-family: Arial, sans-serif;\n  }");
  }
}

