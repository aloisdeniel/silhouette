import 'dart:js_interop';
import 'package:web/web.dart';
import 'package:silhouette_cli/src/runtime/runtime.dart';
import 'button.client.g.dart';

class App {
  late final State<int> _count;
  int get count => _count.value;
  set count(int value) => _count.value = value;

  late final State<String> _message;
  String get message => _message.value;
  set message(String value) => _message.value = value;

  late final HTMLElement root;

  App() {
    _count = state(0);
    _message = state('');
    effect(() {
    print('App state - count: $count, message: $message');
  });
  }

  void increment() {
    count = count + 1;
    message = 'Count increased to $count';
  }

  void decrement() {
    count = count - 1;
    message = 'Count decreased to $count';
  }

  void reset() {
    count = 0;
    message = 'Count reset!';
  }

  void mount(HTMLElement target) {
    root = document.createElement('div') as HTMLElement;
    root.className = 'silhouette-app-095443';

    final _div_0 = document.createElement('div');
    _div_0.setAttribute("class", "app");
    final _h1_1 = document.createElement('h1');
    final _text_2 = document.createTextNode("Custom Components Demo");
    _h1_1.appendChild(_text_2);
    _div_0.appendChild(_h1_1);
    final _div_3 = document.createElement('div');
    _div_3.setAttribute("class", "counter");
    final _p_4 = document.createElement('p');
    final _text_5 = document.createTextNode("Count: ");
    _p_4.appendChild(_text_5);
    final _text_6 = document.createTextNode("");
    _p_4.appendChild(_text_6);
    effect(() {
      _text_6.textContent = "${count}";
    });
    _div_3.appendChild(_p_4);
    final _div_7 = document.createElement('div');
    _div_7.setAttribute("class", "buttons");
    final _button_8 = Button(
      label: "Increment",
      variant: "primary"
    );
    _button_8.mount(_div_7 as HTMLElement);
    final _button_9 = Button(
      label: "Decrement",
      variant: "secondary"
    );
    _button_9.mount(_div_7 as HTMLElement);
    final _button_10 = Button(
      label: "Reset",
      variant: "danger"
    );
    _button_10.mount(_div_7 as HTMLElement);
    _div_3.appendChild(_div_7);
    _div_0.appendChild(_div_3);
    final _if_11 = document.createElement('span');
    _div_0.appendChild(_if_11);
    effect(() {
      while (_if_11.firstChild != null) {
        _if_11.removeChild(_if_11.firstChild!);
      }
      if (message.isNotEmpty) {
        final _div_12 = document.createElement('div');
        _div_12.setAttribute("class", "message");
        final _p_13 = document.createElement('p');
        final _text_14 = document.createTextNode("");
        _p_13.appendChild(_text_14);
        effect(() {
          _text_14.textContent = "${message}";
        });
        _div_12.appendChild(_p_13);
        _if_11.appendChild(_div_12);
      }
    });
    root.appendChild(_div_0);

    target.appendChild(root);
  }

  void destroy() {
    root.remove();
  }
}

