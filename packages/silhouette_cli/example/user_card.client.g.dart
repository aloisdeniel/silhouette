import 'dart:js_interop';
import 'package:web/web.dart';
import 'package:silhouette_cli/src/runtime/runtime.dart';

class UserCard {
  final String username;
  final String email;
  final int age;
  final bool isPremium;

  late final Derived<dynamic> _displayInfo;
  get displayInfo => _displayInfo.value;

  late final Derived<dynamic> _statusText;
  get statusText => _statusText.value;

  late final HTMLElement root;

  UserCard({required this.username, required this.email, this.age = 18, this.isPremium = false}) {
    _displayInfo = derived(() => '$username ($email)');
    _statusText = derived(() => isPremium ? 'Premium User' : 'Free User');
    effect(() {
    print('User card rendered for: $username');
  });
  }

  void mount(HTMLElement target) {
    root = document.createElement('div') as HTMLElement;

    final _div_0 = document.createElement('div');
    _div_0.setAttribute("class", "user-card");
    final _h2_1 = document.createElement('h2');
    final _text_2 = document.createTextNode("");
    _h2_1.appendChild(_text_2);
    effect(() {
      _text_2.textContent = "${username}";
    });
    _div_0.appendChild(_h2_1);
    final _p_3 = document.createElement('p');
    final _text_4 = document.createTextNode("Email: ");
    _p_3.appendChild(_text_4);
    final _text_5 = document.createTextNode("");
    _p_3.appendChild(_text_5);
    effect(() {
      _text_5.textContent = "${email}";
    });
    _div_0.appendChild(_p_3);
    final _p_6 = document.createElement('p');
    final _text_7 = document.createTextNode("Age: ");
    _p_6.appendChild(_text_7);
    final _text_8 = document.createTextNode("");
    _p_6.appendChild(_text_8);
    effect(() {
      _text_8.textContent = "${age}";
    });
    _div_0.appendChild(_p_6);
    final _p_9 = document.createElement('p');
    final _text_10 = document.createTextNode("Status: ");
    _p_9.appendChild(_text_10);
    final _text_11 = document.createTextNode("");
    _p_9.appendChild(_text_11);
    effect(() {
      _text_11.textContent = "${statusText}";
    });
    _div_0.appendChild(_p_9);
    final _if_12 = document.createElement('span');
    _div_0.appendChild(_if_12);
    effect(() {
      while (_if_12.firstChild != null) {
        _if_12.removeChild(_if_12.firstChild!);
      }
      if (isPremium) {
        final _div_13 = document.createElement('div');
        _div_13.setAttribute("class", "premium-badge");
        final _text_14 = document.createTextNode("⭐ Premium");
        _div_13.appendChild(_text_14);
        _if_12.appendChild(_div_13);
      }
    });
    root.appendChild(_div_0);

    target.appendChild(root);
  }

  void destroy() {
    root.remove();
  }
}

