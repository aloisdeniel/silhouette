import 'card.static.g.dart';

class Dashboard {
  static const String componentId = 'silhouette-dashboard-481280';

  final List<String> items;
  final int selectedIndex;

  Dashboard({this.items = const ['Task 1: Review pull requests', 'Task 2: Update documentation', 'Task 3: Fix bug in login flow'], this.selectedIndex = -1});

  void build(StringBuffer buffer) {
    buffer.write("<div class=\"dashboard\"><h1>Project Dashboard</h1><div class=\"summary\">");
    Card(title: "Welcome", description: "This is a demo of Silhouette components with imports", highlighted: true).build(buffer);
    buffer.write("</div><div class=\"tasks\"><h2>Tasks (");
    buffer.write(items.length);
    buffer.write(")</h2>");
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

