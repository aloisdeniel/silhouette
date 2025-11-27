import 'dart:js_interop';
import 'package:web/web.dart';
import 'package:silhouette_cli/src/runtime/runtime.dart';

class Card {
  final String title;
  final String description;
  final bool highlighted;

  late final Derived<String> _cardClass;
  String get cardClass => _cardClass.value;

  late final HTMLElement root;

  Card({this.title = 'Card Title', this.description = 'Card description goes here', this.highlighted = false}) {
    _cardClass = derived(() => highlighted ? 'card highlighted' : 'card');
    effect(() {
    print('Card rendered: $title');
  });
  }

  void mount(HTMLElement target) {
    root = document.createElement('div') as HTMLElement;
    root.className = 'silhouette-card-766638';

    final _div_0 = document.createElement('div');
    effect(() {
      _div_0.setAttribute("class", "${cardClass}");
    });
    final _h3_1 = document.createElement('h3');
    final _text_2 = document.createTextNode("");
    _h3_1.appendChild(_text_2);
    effect(() {
      _text_2.textContent = "${title}";
    });
    _div_0.appendChild(_h3_1);
    final _p_3 = document.createElement('p');
    final _text_4 = document.createTextNode("");
    _p_3.appendChild(_text_4);
    effect(() {
      _text_4.textContent = "${description}";
    });
    _div_0.appendChild(_p_3);
    root.appendChild(_div_0);

    target.appendChild(root);
  }

  void destroy() {
    root.remove();
  }
}

