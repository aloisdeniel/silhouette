import 'dart:js_interop';
import 'package:web/web.dart';
import 'package:silhouette_cli/src/runtime/runtime.dart';

class Button {
  final String label;
  final String variant;

  late final Derived<String> _buttonClass;
  String get buttonClass => _buttonClass.value;

  late final HTMLElement root;

  Button({this.label = 'Click me', this.variant = 'primary'}) {
    _buttonClass = derived(() => 'btn btn-$variant');
    effect(() {
    print('Button rendered: $label');
  });
  }

  void mount(HTMLElement target) {
    root = document.createElement('div') as HTMLElement;

    final _button_0 = document.createElement('button');
    effect(() {
      _button_0.setAttribute("class", "${buttonClass}");
    });
    final _text_1 = document.createTextNode("");
    _button_0.appendChild(_text_1);
    effect(() {
      _text_1.textContent = "${label}";
    });
    root.appendChild(_button_0);

    target.appendChild(root);
  }

  void destroy() {
    root.remove();
  }
}

