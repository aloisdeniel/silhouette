import 'card.static.g.dart';

class Dashboard {
  final dynamic items;
  final dynamic selectedIndex;

  Dashboard({this.items = ['Task 1: Review pull requests', 'Task 2: Update documentation', 'Task 3: Fix bug in login flow'], this.selectedIndex = -1});

  void build(StringBuffer buffer) {
    buffer.write("<div");
    buffer.write(" class=\"dashboard\"");
    buffer.write(">");
    buffer.write("<h1");
    buffer.write(">");
    buffer.write("Project Dashboard");
    buffer.write("</h1>");
    buffer.write("<div");
    buffer.write(" class=\"summary\"");
    buffer.write(">");
    Card(title: "Welcome", description: "This is a demo of Silhouette components with imports", highlighted: true).build(buffer);
    buffer.write("</div>");
    buffer.write("<div");
    buffer.write(" class=\"tasks\"");
    buffer.write(">");
    buffer.write("<h2");
    buffer.write(">");
    buffer.write("Tasks (");
    buffer.write(items.length);
    buffer.write(")");
    buffer.write("</h2>");
    for (var i = 0; i < items.length; i++) {
      final task = items[i];
      Card(title: "Task #${i + 1}", description: task, highlighted: i == selectedIndex).build(buffer);
    }
    buffer.write("</div>");
    if (items.length == 0) {
      Card(title: "No Tasks", description: "All done! Great job!", highlighted: true).build(buffer);
    }
    buffer.write("</div>");
  }
}

