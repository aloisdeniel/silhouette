class Card {
  static const String componentId = 'silhouette-card-717706';

  final String title;
  final String description;
  final bool highlighted;

  late final String cardClass;

  Card({this.title = 'Card Title', this.description = 'Card description goes here', this.highlighted = false}) {
    cardClass = highlighted ? 'card highlighted' : 'card';
  }

  void html(StringBuffer buffer) {
    buffer.write("<div class=\"$componentId ");
    buffer.write(cardClass);
    buffer.write("\"><h3>");
    buffer.write(title);
    buffer.write("</h3><p>");
    buffer.write(description);
    buffer.write("</p></div>");
  }

  static void style(StringBuffer buffer) {
    buffer.write(".card.$componentId { \n    border: 1px solid #ddd;\n    border-radius: 8px;\n    padding: 20px;\n    margin: 10px 0;\n    background: white;\n    box-shadow: 0 2px 4px rgba(0,0,0,0.1);\n  }.card.highlighted.$componentId { \n    border-color: #007bff;\n    box-shadow: 0 4px 8px rgba(0,123,255,0.2);\n  }.card h3.$componentId { \n    margin-top: 0;\n    color: #333;\n  }.card p.$componentId { \n    color: #666;\n    margin-bottom: 0;\n  }");
  }
}

