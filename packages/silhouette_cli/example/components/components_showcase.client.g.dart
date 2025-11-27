import 'dart:js_interop';
import 'package:web/web.dart';
import 'package:silhouette_cli/src/runtime/runtime.dart';
import 'card.client.g.dart';
import 'button.client.g.dart';

class ComponentsShowcase {
  late final State<int> _counter;
  int get counter => _counter.value;
  set counter(int value) => _counter.value = value;

  late final State<int> _selectedCard;
  int get selectedCard => _selectedCard.value;
  set selectedCard(int value) => _selectedCard.value = value;

  late final Derived<String> _counterText;
  String get counterText => _counterText.value;

  late final Derived<bool> _hasClicked;
  bool get hasClicked => _hasClicked.value;

  late final HTMLElement root;

  ComponentsShowcase() {
    _counter = state(0);
    _selectedCard = state(0);
    _counterText = derived(() => 'Counter: $counter');
    _hasClicked = derived(() => counter > 0);
    effect(() {
    print('Showcase: counter=$counter, selectedCard=$selectedCard');
  });
  }

  void handleIncrement() {
    counter = counter + 1;
  }

  void selectCard(int index) {
    selectedCard = index;
  }

  void mount(HTMLElement target) {
    root = document.createElement('div') as HTMLElement;
    root.className = 'silhouette-componentsshowcase-442859';

    final _div_0 = document.createElement('div');
    _div_0.setAttribute("class", "showcase");
    final _h1_1 = document.createElement('h1');
    final _text_2 = document.createTextNode("Silhouette Components Showcase");
    _h1_1.appendChild(_text_2);
    _div_0.appendChild(_h1_1);
    final _section_3 = document.createElement('section');
    final _h2_4 = document.createElement('h2');
    final _text_5 = document.createTextNode("Component Composition");
    _h2_4.appendChild(_text_5);
    _section_3.appendChild(_h2_4);
    final _p_6 = document.createElement('p');
    final _text_7 = document.createTextNode("Demonstrating imported components with props");
    _p_6.appendChild(_text_7);
    _section_3.appendChild(_p_6);
    final _card_8 = Card(
      title: "Welcome Card",
      description: "This card is a reusable component",
      highlighted: counter > 5
    );
    _card_8.mount(_section_3 as HTMLElement);
    _div_0.appendChild(_section_3);
    final _section_9 = document.createElement('section');
    final _h2_10 = document.createElement('h2');
    final _text_11 = document.createTextNode("Dynamic Components in Loops");
    _h2_10.appendChild(_text_11);
    _section_9.appendChild(_h2_10);
    final _each_12 = document.createElement('span');
    _section_9.appendChild(_each_12);
    effect(() {
      while (_each_12.firstChild != null) {
        _each_12.removeChild(_each_12.firstChild!);
      }
      for (var i = 0; i < ['Feature 1', 'Feature 2', 'Feature 3'].length; i++) {
        final feature = ['Feature 1', 'Feature 2', 'Feature 3'][i];
        final _card_13 = Card(
          title: feature,
          description: "Card number ${i + 1}",
          highlighted: i == selectedCard
        );
        _card_13.mount(_each_12 as HTMLElement);
      }
    });
    _div_0.appendChild(_section_9);
    final _section_14 = document.createElement('section');
    final _h2_15 = document.createElement('h2');
    final _text_16 = document.createTextNode("Interactive Components");
    _h2_15.appendChild(_text_16);
    _section_14.appendChild(_h2_15);
    final _p_17 = document.createElement('p');
    final _text_18 = document.createTextNode("");
    _p_17.appendChild(_text_18);
    effect(() {
      _text_18.textContent = "${counterText}";
    });
    _section_14.appendChild(_p_17);
    final _if_19 = document.createElement('span');
    _section_14.appendChild(_if_19);
    effect(() {
      while (_if_19.firstChild != null) {
        _if_19.removeChild(_if_19.firstChild!);
      }
      if (hasClicked) {
        final _card_20 = Card(
          title: "You've clicked!",
          description: "The counter is now at ${counter}",
          highlighted: true
        );
        _card_20.mount(_if_19 as HTMLElement);
      }
    });
    _div_0.appendChild(_section_14);
    root.appendChild(_div_0);

    target.appendChild(root);
  }

  void destroy() {
    root.remove();
  }
}

