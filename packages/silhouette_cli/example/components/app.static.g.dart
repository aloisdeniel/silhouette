import 'button.static.g.dart';

class App {
  static const String componentId = 'silhouette-app-083646';

  final int count;
  final String message;

  App({this.count = 0, this.message = ''});

  void build(StringBuffer buffer) {
    buffer.write("<div class=\"silhouette-app-083646 app\"><h1>Custom Components Demo</h1><div class=\"counter\"><p>Count: ");
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

  static void style(StringBuffer buffer) {
    buffer.write(".silhouette-app-083646 .app { \n    max-width: 800px;\n    margin: 0 auto;\n    padding: 20px;\n    font-family: Arial, sans-serif;\n  }.silhouette-app-083646 .counter { \n    background: #f5f5f5;\n    padding: 20px;\n    border-radius: 8px;\n    margin: 20px 0;\n  }.silhouette-app-083646 .buttons { \n    display: flex;\n    gap: 10px;\n    margin-top: 10px;\n  }.silhouette-app-083646 .message { \n    background: #e7f3ff;\n    padding: 15px;\n    border-radius: 4px;\n    border-left: 4px solid #007bff;\n  }");
  }
}

