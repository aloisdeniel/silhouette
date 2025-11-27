class Button {
  static const String componentId = 'silhouette-button-044925';

  final String label;
  final String variant;

  late final String buttonClass;

  Button({this.label = 'Click me', this.variant = 'primary'}) {
    buttonClass = 'btn btn-$variant';
  }

  void html(StringBuffer buffer) {
    buffer.write("<button class=\"$componentId ");
    buffer.write(buttonClass);
    buffer.write("\">");
    buffer.write(label);
    buffer.write("</button>");
  }

  static void style(StringBuffer buffer) {
    buffer.write(".btn.$componentId { \n    padding: 10px 20px;\n    border: none;\n    border-radius: 4px;\n    cursor: pointer;\n    font-size: 16px;\n  }.btn-primary.$componentId { \n    background-color: #007bff;\n    color: white;\n  }.btn-secondary.$componentId { \n    background-color: #6c757d;\n    color: white;\n  }.btn-danger.$componentId { \n    background-color: #dc3545;\n    color: white;\n  }");
  }
}

