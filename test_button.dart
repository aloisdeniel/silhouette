class Button {
  final String label;
  final String variant;

  late final dynamic buttonClass;

  Button({this.label = 'Click me', this.variant = 'primary') {
    buttonClass = 'btn btn-$variant';
  }

  String build() {
    final buffer = StringBuffer();
    buffer.write("<button");
    buffer.write(" class=\"");
    buffer.write(buttonClass);
    buffer.write("\"");
    buffer.write(">");
    buffer.write(label);
    buffer.write("</button>");
    return buffer.toString();
  }
}



void main() { print(Button().buttonClass); }
