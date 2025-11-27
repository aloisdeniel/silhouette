import 'card.static.g.dart';

class Dashboard {
  static const String componentId = 'silhouette-dashboard-810089';

  final List<String> items;
  final int selectedIndex;

  Dashboard({this.items = const ['Task 1: Review pull requests', 'Task 2: Update documentation', 'Task 3: Fix bug in login flow'], this.selectedIndex = -1});

  void build(StringBuffer buffer) {
    buffer.write("<div class=\"silhouette-dashboard-810089 dashboard\"><h1>Project Dashboard</h1><div class=\"summary\">");
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

  static void style(StringBuffer buffer) {
    buffer.write(".silhouette-dashboard-810089 .dashboard { \n    max-width: 900px;\n    margin: 0 auto;\n    padding: 20px;\n    font-family: Arial, sans-serif;\n  }.silhouette-dashboard-810089 .dashboard h1 { \n    color: #333;\n    margin-bottom: 30px;\n  }.silhouette-dashboard-810089 .summary { \n    margin-bottom: 30px;\n  }.silhouette-dashboard-810089 .tasks h2 { \n    color: #666;\n    margin-bottom: 15px;\n  }");
  }
}

