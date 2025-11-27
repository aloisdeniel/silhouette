import 'dart:js_interop';
import 'package:web/web.dart';
import 'package:silhouette_cli/src/runtime/runtime.dart';

class Counter {
  late final State<int> _count;
  int get count => _count.value;
  set count(int value) => _count.value = value;

  late final Derived<int> _double;
  int get double => _double.value;

  late final HTMLElement root;

  Counter() {
    _count = state(0);
    _double = derived(() => count * 2);
    effect(() {
      print('Count is now: $count');
    });
  }

  void increment() {
    count = count + 1;
  }

  void decrement() {
    count = count - 1;
  }

  void mount(HTMLElement target) {
    root = document.createElement('div') as HTMLElement;
    root.className = 'silhouette-counter-307430';

    final _div_0 = document.createElement('div');
    _div_0.setAttribute("class", "other");
    final _h1_1 = document.createElement('h1');
    final _text_2 = document.createTextNode("Counter Example");
    _h1_1.appendChild(_text_2);
    _div_0.appendChild(_h1_1);
    final _p_3 = document.createElement('p');
    final _text_4 = document.createTextNode("Count: ");
    _p_3.appendChild(_text_4);
    final _text_5 = document.createTextNode("");
    _p_3.appendChild(_text_5);
    effect(() {
      _text_5.textContent = "${count}";
    });
    _div_0.appendChild(_p_3);
    final _p_6 = document.createElement('p');
    final _text_7 = document.createTextNode("Double: ");
    _p_6.appendChild(_text_7);
    final _text_8 = document.createTextNode("");
    _p_6.appendChild(_text_8);
    effect(() {
      _text_8.textContent = "${double}";
    });
    _div_0.appendChild(_p_6);
    final _button_9 = document.createElement('button');
    _button_9.addEventListener(
        'click',
        (Event event) {
          increment();
        }.toJS);
    final _text_10 = document.createTextNode("Increment");
    _button_9.appendChild(_text_10);
    _div_0.appendChild(_button_9);
    final _button_11 = document.createElement('button');
    _button_11.addEventListener(
        'click',
        (Event event) {
          decrement();
        }.toJS);
    final _text_12 = document.createTextNode("Decrement");
    _button_11.appendChild(_text_12);
    _div_0.appendChild(_button_11);
    final _if_13 = document.createElement('span');
    _div_0.appendChild(_if_13);
    effect(() {
      while (_if_13.firstChild != null) {
        _if_13.removeChild(_if_13.firstChild!);
      }
      if (count > 10) {
        final _p_14 = document.createElement('p');
        final _text_15 = document.createTextNode("Count is greater than 10!");
        _p_14.appendChild(_text_15);
        _if_13.appendChild(_p_14);
      } else {
        final _p_16 = document.createElement('p');
        final _text_17 = document.createTextNode("Count is 10 or less");
        _p_16.appendChild(_text_17);
        _if_13.appendChild(_p_16);
      }
    });
    root.appendChild(_div_0);

    target.appendChild(root);
  }

  void destroy() {
    root.remove();
  }
}
