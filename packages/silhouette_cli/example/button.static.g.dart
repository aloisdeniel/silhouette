class Button {
  static const String componentId = 'silhouette-button-522198';

  final String label;
  final String variant;

  late final String buttonClass;

  Button({this.label = 'Click me', this.variant = 'primary'}) {
    buttonClass = 'btn btn-$variant';
  }

  void build(StringBuffer buffer) {
    buffer.write("<button class=\"silhouette-button-522198 ");
    buffer.write(buttonClass);
    buffer.write("\">");
    buffer.write(label);
    buffer.write("</button>");
  }
}

