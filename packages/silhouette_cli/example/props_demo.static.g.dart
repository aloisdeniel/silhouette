class PropsDemo {
  static const String componentId = 'silhouette-propsdemo-952536';

  final String title;
  final String subtitle;
  final int maxItems;
  final bool showHeader;

  final int currentCount;

  late final String headerText;
  late final String itemLimit;
  late final bool isOverLimit;

  PropsDemo({required this.title, this.subtitle = 'No subtitle', this.maxItems = 10, this.showHeader = true, this.currentCount = 0}) {
    headerText = showHeader ? title : '';
    itemLimit = 'Showing up to $maxItems items';
    isOverLimit = currentCount > maxItems;
  }

  void build(StringBuffer buffer) {
    buffer.write("<div class=\"silhouette-propsdemo-952536 props-demo\">");
    if (showHeader) {
      buffer.write("<div class=\"header\"><h1>");
      buffer.write(title);
      buffer.write("</h1><h2>");
      buffer.write(subtitle);
      buffer.write("</h2></div>");
    }
    buffer.write("<div class=\"content\"><p>");
    buffer.write(itemLimit);
    buffer.write("</p><p>Current count: ");
    buffer.write(currentCount);
    buffer.write("</p>");
    if (isOverLimit) {
      buffer.write("<p class=\"warning\">Warning: Over the limit!</p>");
    }
    buffer.write("<button>Add Item</button></div></div>");
  }
}

