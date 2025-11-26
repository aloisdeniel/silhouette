import 'dart:js_interop';
import 'package:web/web.dart';
import 'package:silhouette_cli/src/runtime/runtime.dart';
import 'card.g.dart';

class Dashboard {
  late final State<dynamic> _items;
  get items => _items.value;
  set items(value) => _items.value = value;

  late final State<dynamic> _selectedIndex;
  get selectedIndex => _selectedIndex.value;
  set selectedIndex(value) => _selectedIndex.value = value;

  late final HTMLElement root;

  Dashboard() {
    _items = state(['Task 1: Review pull requests', 'Task 2: Update documentation', 'Task 3: Fix bug in login flow']);
    _selectedIndex = state(-1);
  }

  void mount(HTMLElement target) {
    root = document.createElement('div') as HTMLElement;

    final _div_0 = document.createElement('div');
    _div_0.setAttribute("class", "dashboard");
    final _h1_1 = document.createElement('h1');
    final _text_2 = document.createTextNode("Project Dashboard");
    _h1_1.appendChild(_text_2);
    _div_0.appendChild(_h1_1);
    final _div_3 = document.createElement('div');
    _div_3.setAttribute("class", "summary");
    final _card_4 = Card(
      title: "Welcome",
      description: "This is a demo of Silhouette components with imports",
      highlighted: true
    );
    _card_4.mount(_div_3 as HTMLElement);
    _div_0.appendChild(_div_3);
    final _div_5 = document.createElement('div');
    _div_5.setAttribute("class", "tasks");
    final _h2_6 = document.createElement('h2');
    final _text_7 = document.createTextNode("Tasks (");
    _h2_6.appendChild(_text_7);
    final _text_8 = document.createTextNode("");
    _h2_6.appendChild(_text_8);
    effect(() {
      _text_8.textContent = "${items.length}";
    });
    final _text_9 = document.createTextNode(")");
    _h2_6.appendChild(_text_9);
    _div_5.appendChild(_h2_6);
    final _each_10 = document.createElement('span');
    _div_5.appendChild(_each_10);
    effect(() {
      while (_each_10.firstChild != null) {
        _each_10.removeChild(_each_10.firstChild!);
      }
      for (var i = 0; i < items.length; i++) {
        final task = items[i];
        final _card_11 = Card(
          title: "Task #${i + 1}",
          description: task,
          highlighted: i == selectedIndex
        );
        _card_11.mount(_each_10 as HTMLElement);
      }
    });
    _div_0.appendChild(_div_5);
    final _if_12 = document.createElement('span');
    _div_0.appendChild(_if_12);
    effect(() {
      while (_if_12.firstChild != null) {
        _if_12.removeChild(_if_12.firstChild!);
      }
      if (items.length == 0) {
        final _card_13 = Card(
          title: "No Tasks",
          description: "All done! Great job!",
          highlighted: true
        );
        _card_13.mount(_if_12 as HTMLElement);
      }
    });
    root.appendChild(_div_0);

    target.appendChild(root);
  }

  void destroy() {
    root.remove();
  }
}

