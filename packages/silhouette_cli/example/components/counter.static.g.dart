class Counter {
  static const String componentId = 'silhouette-counter-309995';

  final int count;

  late final int double;

  Counter({this.count = 0}) {
    double = count * 2;
  }

  void build(StringBuffer buffer) {
    buffer.write("<div class=\"silhouette-counter-309995 other\"><h1>Counter Example</h1><p>Count: ");
    buffer.write(count);
    buffer.write("</p><p>Double: ");
    buffer.write(double);
    buffer.write("</p><button>Increment</button><button>Decrement</button>");
    if (count > 10) {
      buffer.write("<p>Count is greater than 10!</p>");
    }
    else {
      buffer.write("<p>Count is 10 or less</p>");
    }
    buffer.write("</div>");
  }

  static void style(StringBuffer buffer) {
    buffer.write(".silhouette-counter-309995 div { \n    padding: 20px;\n    font-family: Arial, sans-serif;\n  }.silhouette-counter-309995 button { \n    margin: 5px;\n    padding: 10px 20px;\n    cursor: pointer;\n  }");
  }
}

