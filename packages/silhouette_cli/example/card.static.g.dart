class Card {
  final String title;
  final String description;
  final bool highlighted;

  late final dynamic cardClass;

  Card({this.title = 'Card Title', this.description = 'Card description goes here', this.highlighted = false}) {
    cardClass = highlighted ? 'card highlighted' : 'card';
  }

  String build() {
    final buffer = StringBuffer();
    buffer.write("<div");
    buffer.write(" class=\"");
    buffer.write(cardClass);
    buffer.write("\"");
    buffer.write(">");
    buffer.write("<h3");
    buffer.write(">");
    buffer.write(title);
    buffer.write("</h3>");
    buffer.write("<p");
    buffer.write(">");
    buffer.write(description);
    buffer.write("</p>");
    buffer.write("</div>");
    return buffer.toString();
  }
}

