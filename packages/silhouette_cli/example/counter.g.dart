import 'dart:html';
import 'package:silhouette_cli/src/runtime/runtime.dart';

class Component {
  late final State<dynamic> _count;
  get count => _count.value;
  set count(value) => _count.value = value;

  late final Derived<dynamic> _double;
  get double => _double.value;

  late final Element root;

  Component() {
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

  void mount(Element target) {
    root = Element.tag("div");

    final _div_0 = Element.tag("div");
    final _h1_1 = Element.tag("h1");
    final _text_2 = Text("Counter Example");
    _h1_1.append(_text_2);
    _div_0.append(_h1_1);
    final _p_3 = Element.tag("p");
    final _text_4 = Text("Count: ");
    _p_3.append(_text_4);
    final _text_5 = Text("");
    _p_3.append(_text_5);
    effect(() {
      _text_5.text = "${count}";
    });
    _div_0.append(_p_3);
    final _p_6 = Element.tag("p");
    final _text_7 = Text("Double: ");
    _p_6.append(_text_7);
    final _text_8 = Text("");
    _p_6.append(_text_8);
    effect(() {
      _text_8.text = "${double}";
    });
    _div_0.append(_p_6);
    final _button_9 = Element.tag("button");
    _button_9.onClick.listen((event) {
      increment();
    });
    final _text_10 = Text("Increment");
    _button_9.append(_text_10);
    _div_0.append(_button_9);
    final _button_11 = Element.tag("button");
    _button_11.onClick.listen((event) {
      decrement();
    });
    final _text_12 = Text("Decrement");
    _button_11.append(_text_12);
    _div_0.append(_button_11);
    final _if_13 = Element.tag("span");
    _div_0.append(_if_13);
    effect(() {
      _if_13.children.clear();
      if (count > 10) {
        final _p_14 = Element.tag("p");
        final _text_15 = Text("Count is greater than 10!");
        _p_14.append(_text_15);
        _if_13.append(_p_14);
      } else {
        final _p_16 = Element.tag("p");
        final _text_17 = Text("Count is 10 or less");
        _p_16.append(_text_17);
        _if_13.append(_p_16);
      }
    });
    root.append(_div_0);

    target.append(root);
  }

  void destroy() {
    root.remove();
  }
}
