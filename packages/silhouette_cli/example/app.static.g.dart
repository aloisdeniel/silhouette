import 'button.static.g.dart';

class App {
  final int count;
  final String message;

  App({this.count = 0, this.message = ''});

  void build(StringBuffer buffer) {
    buffer.write("<div");
    buffer.write(" class=\"app\"");
    buffer.write(">");
    buffer.write("<h1");
    buffer.write(">");
    buffer.write("Custom Components Demo");
    buffer.write("</h1>");
    buffer.write("<div");
    buffer.write(" class=\"counter\"");
    buffer.write(">");
    buffer.write("<p");
    buffer.write(">");
    buffer.write("Count: ");
    buffer.write(count);
    buffer.write("</p>");
    buffer.write("<div");
    buffer.write(" class=\"buttons\"");
    buffer.write(">");
    Button(label: "Increment", variant: "primary").build(buffer);
    Button(label: "Decrement", variant: "secondary").build(buffer);
    Button(label: "Reset", variant: "danger").build(buffer);
    buffer.write("</div>");
    buffer.write("</div>");
    if (message.isNotEmpty) {
      buffer.write("<div");
      buffer.write(" class=\"message\"");
      buffer.write(">");
      buffer.write("<p");
      buffer.write(">");
      buffer.write(message);
      buffer.write("</p>");
      buffer.write("</div>");
    }
    buffer.write("</div>");
  }
}

