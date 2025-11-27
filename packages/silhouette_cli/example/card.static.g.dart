class Card {
  static const String componentId = 'silhouette-card-377022';

  final String title;
  final String description;
  final bool highlighted;

  late final String cardClass;

  Card({this.title = 'Card Title', this.description = 'Card description goes here', this.highlighted = false}) {
    cardClass = highlighted ? 'card highlighted' : 'card';
  }

  void build(StringBuffer buffer) {
    buffer.write("<div class=\"");
    buffer.write(cardClass);
    buffer.write("\"><h3>");
    buffer.write(title);
    buffer.write("</h3><p>");
    buffer.write(description);
    buffer.write("</p></div>");
  }
}

