import 'button.static.g.dart';

class App {
  static const String componentId = 'silhouette-app-110758';

  final int count;
  final String message;

  App({this.count = 0, this.message = ''});

  void build(StringBuffer buffer) {
    buffer.write("<div class=\"app\"><h1>Custom Components Demo</h1><div class=\"counter\"><p>Count: ");
    buffer.write(count);
    buffer.write("</p><div class=\"buttons\">");
    Button(label: "Increment", variant: "primary").build(buffer);
    Button(label: "Decrement", variant: "secondary").build(buffer);
    Button(label: "Reset", variant: "danger").build(buffer);
    buffer.write("</div></div>");
    if (message.isNotEmpty) {
      buffer.write("<div class=\"message\"><p>");
      buffer.write(message);
      buffer.write("</p></div>");
    }
    buffer.write("</div>");
  }
}

