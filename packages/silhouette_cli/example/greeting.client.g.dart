import 'dart:js_interop';
import 'package:web/web.dart';
import 'package:silhouette_cli/src/runtime/runtime.dart';

class Greeting {
  final String name;
  final int count;

  late final Derived<String> _greeting;
  String get greeting => _greeting.value;

  late final Derived<String> _displayCount;
  String get displayCount => _displayCount.value;

  late final HTMLElement root;

  Greeting({this.name = 'World', this.count = 0}) {
    _greeting = derived(() => 'Hello, $name!');
    _displayCount = derived(() => 'Count: $count');
    effect(() {
    print('Greeting changed: $greeting');
  });
  }

  void mount(HTMLElement target) {
    root = document.createElement('div') as HTMLElement;
    root.className = 'silhouette-greeting-868898';

    final _div_0 = document.createElement('div');
    final _h1_1 = document.createElement('h1');
    final _text_2 = document.createTextNode("");
    _h1_1.appendChild(_text_2);
    effect(() {
      _text_2.textContent = "${greeting}";
    });
    _div_0.appendChild(_h1_1);
    final _p_3 = document.createElement('p');
    final _text_4 = document.createTextNode("");
    _p_3.appendChild(_text_4);
    effect(() {
      _text_4.textContent = "${displayCount}";
    });
    _div_0.appendChild(_p_3);
    final _p_5 = document.createElement('p');
    final _text_6 = document.createTextNode("Name is ");
    _p_5.appendChild(_text_6);
    final _text_7 = document.createTextNode("");
    _p_5.appendChild(_text_7);
    effect(() {
      _text_7.textContent = "${name}";
    });
    _div_0.appendChild(_p_5);
    root.appendChild(_div_0);

    target.appendChild(root);
  }

  void destroy() {
    root.remove();
  }
}

