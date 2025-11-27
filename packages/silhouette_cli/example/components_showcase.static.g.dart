import 'card.client.g.dart';
import 'button.client.g.dart';

class ComponentsShowcase {
  late final dynamic counterText;
  late final dynamic hasClicked;

  ComponentsShowcase() {
    counterText = 'Counter: $counter';
    hasClicked = counter > 0;
  }

  void build(StringBuffer buffer) {
    buffer.write("<div");
    buffer.write(" class=\"showcase\"");
    buffer.write(">");
    buffer.write("<h1");
    buffer.write(">");
    buffer.write("Silhouette Components Showcase");
    buffer.write("</h1>");
    buffer.write("<section");
    buffer.write(">");
    buffer.write("<h2");
    buffer.write(">");
    buffer.write("Component Composition");
    buffer.write("</h2>");
    buffer.write("<p");
    buffer.write(">");
    buffer.write("Demonstrating imported components with props");
    buffer.write("</p>");
    Card(title: "Welcome Card", description: "This card is a reusable component", highlighted: counter > 5).build(buffer);
    buffer.write("</section>");
    buffer.write("<section");
    buffer.write(">");
    buffer.write("<h2");
    buffer.write(">");
    buffer.write("Dynamic Components in Loops");
    buffer.write("</h2>");
    for (var i = 0; i < ['Feature 1', 'Feature 2', 'Feature 3'].length; i++) {
      final feature = ['Feature 1', 'Feature 2', 'Feature 3'][i];
      Card(title: feature, description: "Card number ${i + 1}", highlighted: i == selectedCard).build(buffer);
    }
    buffer.write("</section>");
    buffer.write("<section");
    buffer.write(">");
    buffer.write("<h2");
    buffer.write(">");
    buffer.write("Interactive Components");
    buffer.write("</h2>");
    buffer.write("<p");
    buffer.write(">");
    buffer.write(counterText);
    buffer.write("</p>");
    if (hasClicked) {
      Card(title: "You've clicked!", description: "The counter is now at ${counter}", highlighted: true).build(buffer);
    }
    buffer.write("</section>");
    buffer.write("</div>");
  }
}

