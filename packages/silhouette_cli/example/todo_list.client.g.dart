import 'dart:js_interop';
import 'package:web/web.dart';
import 'package:silhouette_cli/src/runtime/runtime.dart';
import 'todo.dart';

class TodoList {
  late final State<List<Todo>> _todos;
  List<Todo> get todos => _todos.value;
  set todos(List<Todo> value) => _todos.value = value;

  late final State<String> _newTodo;
  String get newTodo => _newTodo.value;
  set newTodo(String value) => _newTodo.value = value;

  late final State<String> _filter;
  String get filter => _filter.value;
  set filter(String value) => _filter.value = value;

  late final Derived<List<Todo>> _filteredTodos;
  List<Todo> get filteredTodos => _filteredTodos.value;

  late final HTMLElement root;

  TodoList() {
    _todos = state(const <Todo>[]);
    _newTodo = state('');
    _filter = state('all');
    _filteredTodos = derived(() {
    if (filter == 'active') {
      return todos.where((t) => !t.completed).toList();
    } else if (filter == 'completed') {
      return todos.where((t) => t.completed).toList();
    }
    return todos;
  });
  }

  void addTodo() {
    if (newTodo.trim().isEmpty) return;
    todos = [...todos, Todo(text: newTodo, completed: false)];
    newTodo = '';
  }

  void toggleTodo(int index) {
    final todo = todos[index];
    todos[index] = Todo(text: todo.text, completed: !todo.completed);
  }

  void removeTodo(int index) {
    todos = [...todos.sublist(0, index), ...todos.sublist(index + 1)];
  }

  void mount(HTMLElement target) {
    root = document.createElement('div') as HTMLElement;

    final _div_0 = document.createElement('div');
    _div_0.setAttribute("class", "todo-app");
    final _h1_1 = document.createElement('h1');
    final _text_2 = document.createTextNode("Todo List");
    _h1_1.appendChild(_text_2);
    _div_0.appendChild(_h1_1);
    final _div_3 = document.createElement('div');
    _div_3.setAttribute("class", "input-group");
    final _input_4 = document.createElement('input');
    _input_4.setAttribute("type", "text");
    effect(() {
      if (_input_4.isA<HTMLInputElement>()) {
        (_input_4 as HTMLInputElement).value = newTodo.toString();
      }
    });
    _input_4.addEventListener('input', (Event event) {
      if (_input_4.isA<HTMLInputElement>()) {
        newTodo = (_input_4 as HTMLInputElement).value;
      }
    }.toJS);
    _input_4.setAttribute("placeholder", "What needs to be done?");
    _div_3.appendChild(_input_4);
    final _button_5 = document.createElement('button');
    _button_5.addEventListener('click', (Event event) {
      addTodo();
    }.toJS);
    final _text_6 = document.createTextNode("Add");
    _button_5.appendChild(_text_6);
    _div_3.appendChild(_button_5);
    _div_0.appendChild(_div_3);
    final _div_7 = document.createElement('div');
    _div_7.setAttribute("class", "filters");
    final _button_8 = document.createElement('button');
    _button_8.addEventListener('click', (Event event) {
      filter = 'all';
    }.toJS);
    final _text_9 = document.createTextNode("All");
    _button_8.appendChild(_text_9);
    _div_7.appendChild(_button_8);
    final _button_10 = document.createElement('button');
    _button_10.addEventListener('click', (Event event) {
      filter = 'active';
    }.toJS);
    final _text_11 = document.createTextNode("Active");
    _button_10.appendChild(_text_11);
    _div_7.appendChild(_button_10);
    final _button_12 = document.createElement('button');
    _button_12.addEventListener('click', (Event event) {
      filter = 'completed';
    }.toJS);
    final _text_13 = document.createTextNode("Completed");
    _button_12.appendChild(_text_13);
    _div_7.appendChild(_button_12);
    _div_0.appendChild(_div_7);
    final _if_14 = document.createElement('span');
    _div_0.appendChild(_if_14);
    effect(() {
      while (_if_14.firstChild != null) {
        _if_14.removeChild(_if_14.firstChild!);
      }
      if (filteredTodos.length > 0) {
        final _ul_15 = document.createElement('ul');
        final _each_16 = document.createElement('span');
        _ul_15.appendChild(_each_16);
        effect(() {
          while (_each_16.firstChild != null) {
            _each_16.removeChild(_each_16.firstChild!);
          }
          for (var index = 0; index < filteredTodos.length; index++) {
            final todo = filteredTodos[index];
            final _li_17 = document.createElement('li');
            effect(() {
              _li_17.setAttribute("class", "${todo.completed ? 'completed' : ''}");
            });
            final _input_18 = document.createElement('input');
            _input_18.setAttribute("type", "checkbox");
            effect(() {
              _input_18.setAttribute("checked", "${todo.completed}");
            });
            _input_18.addEventListener('click', (Event event) {
              toggleTodo(index);
            }.toJS);
            _li_17.appendChild(_input_18);
            final _span_19 = document.createElement('span');
            final _text_20 = document.createTextNode("");
            _span_19.appendChild(_text_20);
            effect(() {
              _text_20.textContent = "${todo.text}";
            });
            _li_17.appendChild(_span_19);
            final _button_21 = document.createElement('button');
            _button_21.addEventListener('click', (Event event) {
              removeTodo(index);
            }.toJS);
            final _text_22 = document.createTextNode("Delete");
            _button_21.appendChild(_text_22);
            _li_17.appendChild(_button_21);
            _each_16.appendChild(_li_17);
          }
        });
        _if_14.appendChild(_ul_15);
      }
      else {
        final _p_23 = document.createElement('p');
        final _text_24 = document.createTextNode("No todos yet!");
        _p_23.appendChild(_text_24);
        _if_14.appendChild(_p_23);
      }
    });
    root.appendChild(_div_0);

    target.appendChild(root);
  }

  void destroy() {
    root.remove();
  }
}

