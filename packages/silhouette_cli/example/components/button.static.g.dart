class Button {
  static const String componentId = 'silhouette-button-636291';

  final String label;
  final String variant;

  late final String buttonClass;

  Button({this.label = 'Click me', this.variant = 'primary'}) {
    buttonClass = 'btn btn-$variant';
  }

  void build(StringBuffer buffer) {
    buffer.write("<button class=\"silhouette-button-636291 ");
    buffer.write(buttonClass);
    buffer.write("\">");
    buffer.write(label);
    buffer.write("</button>");
  }

  static void style(StringBuffer buffer) {
    buffer.write(".silhouette-button-636291 .btn { \n    padding: 10px 20px;\n    border: none;\n    border-radius: 4px;\n    cursor: pointer;\n    font-size: 16px;\n  }.silhouette-button-636291 .btn-primary { \n    background-color: #007bff;\n    color: white;\n  }.silhouette-button-636291 .btn-secondary { \n    background-color: #6c757d;\n    color: white;\n  }.silhouette-button-636291 .btn-danger { \n    background-color: #dc3545;\n    color: white;\n  }");
  }
}

