import 'dart:js_interop';
import 'package:web/web.dart';
import 'package:silhouette_cli/src/runtime/runtime.dart';

class Component {
  String title;
  String subtitle;
  int maxItems;
  bool showHeader;

  late final State<dynamic> _currentCount;
  get currentCount => _currentCount.value;
  set currentCount(value) => _currentCount.value = value;

  late final Derived<dynamic> _headerText;
  get headerText => _headerText.value;

  late final Derived<dynamic> _itemLimit;
  get itemLimit => _itemLimit.value;

  late final Derived<dynamic> _isOverLimit;
  get isOverLimit => _isOverLimit.value;

  late final HTMLElement root;

  Component({required this.title, this.subtitle = 'No subtitle', this.maxItems = 10, this.showHeader = true}) {
    _currentCount = state(0);
    _headerText = derived(() => showHeader ? title : '');
    _itemLimit = derived(() => 'Showing up to $maxItems items');
    _isOverLimit = derived(() => currentCount > maxItems);
    effect(() {
    print('Component rendered with title: $title');
  });
  }

  void incrementCount() {
    currentCount = currentCount + 1;
  }

  void mount(HTMLElement target) {
    root = document.createElement('div') as HTMLElement;

    final _div_0 = document.createElement('div');
    _div_0.setAttribute("class", "props-demo");
    final _if_1 = document.createElement('span');
    _div_0.appendChild(_if_1);
    effect(() {
      while (_if_1.firstChild != null) {
        _if_1.removeChild(_if_1.firstChild!);
      }
      if (showHeader) {
        final _div_2 = document.createElement('div');
        _div_2.setAttribute("class", "header");
        final _h1_3 = document.createElement('h1');
        final _text_4 = document.createTextNode("");
        _h1_3.appendChild(_text_4);
        effect(() {
          _text_4.textContent = "${title}";
        });
        _div_2.appendChild(_h1_3);
        final _h2_5 = document.createElement('h2');
        final _text_6 = document.createTextNode("");
        _h2_5.appendChild(_text_6);
        effect(() {
          _text_6.textContent = "${subtitle}";
        });
        _div_2.appendChild(_h2_5);
        _if_1.appendChild(_div_2);
      }
    });
    final _div_7 = document.createElement('div');
    _div_7.setAttribute("class", "content");
    final _p_8 = document.createElement('p');
    final _text_9 = document.createTextNode("");
    _p_8.appendChild(_text_9);
    effect(() {
      _text_9.textContent = "${itemLimit}";
    });
    _div_7.appendChild(_p_8);
    final _p_10 = document.createElement('p');
    final _text_11 = document.createTextNode("Current count: ");
    _p_10.appendChild(_text_11);
    final _text_12 = document.createTextNode("");
    _p_10.appendChild(_text_12);
    effect(() {
      _text_12.textContent = "${currentCount}";
    });
    _div_7.appendChild(_p_10);
    final _if_13 = document.createElement('span');
    _div_7.appendChild(_if_13);
    effect(() {
      while (_if_13.firstChild != null) {
        _if_13.removeChild(_if_13.firstChild!);
      }
      if (isOverLimit) {
        final _p_14 = document.createElement('p');
        _p_14.setAttribute("class", "warning");
        final _text_15 = document.createTextNode("Warning: Over the limit!");
        _p_14.appendChild(_text_15);
        _if_13.appendChild(_p_14);
      }
    });
    final _button_16 = document.createElement('button');
    _button_16.addEventListener('click', (Event event) {
      incrementCount();
    }.toJS);
    final _text_17 = document.createTextNode("Add Item");
    _button_16.appendChild(_text_17);
    _div_7.appendChild(_button_16);
    _div_0.appendChild(_div_7);
    root.appendChild(_div_0);

    target.appendChild(root);
  }

  void destroy() {
    root.remove();
  }
}
