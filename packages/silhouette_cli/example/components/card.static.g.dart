class Card {
  static const String componentId = 'silhouette-card-383274';

  final String title;
  final String description;
  final bool highlighted;

  late final String cardClass;

  Card({this.title = 'Card Title', this.description = 'Card description goes here', this.highlighted = false}) {
    cardClass = highlighted ? 'card highlighted' : 'card';
  }

  void build(StringBuffer buffer) {
    buffer.write("<div class=\"silhouette-card-383274 ");
    buffer.write(cardClass);
    buffer.write("\"><h3>");
    buffer.write(title);
    buffer.write("</h3><p>");
    buffer.write(description);
    buffer.write("</p></div>");
  }

  static void style(StringBuffer buffer) {
    buffer.write(".silhouette-card-383274 .card { \n    border: 1px solid #ddd;\n    border-radius: 8px;\n    padding: 20px;\n    margin: 10px 0;\n    background: white;\n    box-shadow: 0 2px 4px rgba(0,0,0,0.1);\n  }.silhouette-card-383274 .card.highlighted { \n    border-color: #007bff;\n    box-shadow: 0 4px 8px rgba(0,123,255,0.2);\n  }.silhouette-card-383274 .card h3 { \n    margin-top: 0;\n    color: #333;\n  }.silhouette-card-383274 .card p { \n    color: #666;\n    margin-bottom: 0;\n  }");
  }
}

