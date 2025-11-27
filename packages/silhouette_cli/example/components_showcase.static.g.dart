import 'card.static.g.dart';
import 'button.static.g.dart';

class ComponentsShowcase {
  static const String componentId = 'silhouette-componentsshowcase-612339';

  final int counter;
  final int selectedCard;

  late final String counterText;
  late final bool hasClicked;

  ComponentsShowcase({this.counter = 0, this.selectedCard = 0}) {
    counterText = 'Counter: $counter';
    hasClicked = counter > 0;
  }

  void build(StringBuffer buffer) {
    buffer.write("<div class=\"showcase\"><h1>Silhouette Components Showcase</h1><section><h2>Component Composition</h2><p>Demonstrating imported components with props</p>");
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
}

