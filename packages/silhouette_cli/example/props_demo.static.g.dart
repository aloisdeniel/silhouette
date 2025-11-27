class PropsDemo {
  final String title;
  final String subtitle;
  final int maxItems;
  final bool showHeader;

  late final dynamic headerText;
  late final dynamic itemLimit;
  late final dynamic isOverLimit;

  PropsDemo({required this.title, this.subtitle = 'No subtitle', this.maxItems = 10, this.showHeader = true}) {
    headerText = showHeader ? title : '';
    itemLimit = 'Showing up to $maxItems items';
    isOverLimit = currentCount > maxItems;
  }

  void build(StringBuffer buffer) {
    buffer.write("<div");
    buffer.write(" class=\"props-demo\"");
    buffer.write(">");
    if (showHeader) {
      buffer.write("<div");
      buffer.write(" class=\"header\"");
      buffer.write(">");
      buffer.write("<h1");
      buffer.write(">");
      buffer.write(title);
      buffer.write("</h1>");
      buffer.write("<h2");
      buffer.write(">");
      buffer.write(subtitle);
      buffer.write("</h2>");
      buffer.write("</div>");
    }
    buffer.write("<div");
    buffer.write(" class=\"content\"");
    buffer.write(">");
    buffer.write("<p");
    buffer.write(">");
    buffer.write(itemLimit);
    buffer.write("</p>");
    buffer.write("<p");
    buffer.write(">");
    buffer.write("Current count: ");
    buffer.write(currentCount);
    buffer.write("</p>");
    if (isOverLimit) {
      buffer.write("<p");
      buffer.write(" class=\"warning\"");
      buffer.write(">");
      buffer.write("Warning: Over the limit!");
      buffer.write("</p>");
    }
    buffer.write("<button");
    buffer.write(">");
    buffer.write("Add Item");
    buffer.write("</button>");
    buffer.write("</div>");
    buffer.write("</div>");
  }
}

