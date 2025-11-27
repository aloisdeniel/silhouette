import 'card.static.g.dart';
import 'button.static.g.dart';

class ComponentsShowcase {
  static const String componentId = 'silhouette-componentsshowcase-896988';

  final int counter;
  final int selectedCard;

  late final String counterText;
  late final bool hasClicked;

  ComponentsShowcase({this.counter = 0, this.selectedCard = 0}) {
    counterText = 'Counter: $counter';
    hasClicked = counter > 0;
  }

  void build(StringBuffer buffer) {
    buffer.write("<div class=\"silhouette-componentsshowcase-896988 showcase\"><h1>Silhouette Components Showcase</h1><section><h2>Component Composition</h2><p>Demonstrating imported components with props</p>");
    Card(title: "Welcome Card", description: "This card is a reusable component", highlighted: counter > 5).build(buffer);
    buffer.write("</section><section><h2>Dynamic Components in Loops</h2>");
    for (var i = 0; i < ['Feature 1', 'Feature 2', 'Feature 3'].length; i++) {
      final feature = ['Feature 1', 'Feature 2', 'Feature 3'][i];
      Card(title: feature, description: "Card number ${i + 1}", highlighted: i == selectedCard).build(buffer);
    }
    buffer.write("</section><section><h2>Interactive Components</h2><p>");
    buffer.write(counterText);
    buffer.write("</p>");
    if (hasClicked) {
      Card(title: "You've clicked!", description: "The counter is now at ${counter}", highlighted: true).build(buffer);
    }
    buffer.write("</section></div>");
  }

  static void style(StringBuffer buffer) {
    buffer.write(".silhouette-componentsshowcase-896988 .showcase { \n    max-width: 1000px;\n    margin: 0 auto;\n    padding: 40px 20px;\n    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\n  }.silhouette-componentsshowcase-896988 .showcase h1 { \n    color: #2c3e50;\n    margin-bottom: 40px;\n    text-align: center;\n  }.silhouette-componentsshowcase-896988 .showcase section { \n    margin-bottom: 40px;\n  }.silhouette-componentsshowcase-896988 .showcase h2 { \n    color: #34495e;\n    margin-bottom: 20px;\n    padding-bottom: 10px;\n    border-bottom: 2px solid #ecf0f1;\n  }.silhouette-componentsshowcase-896988 .showcase p { \n    color: #7f8c8d;\n    margin-bottom: 20px;\n  }");
  }
}

