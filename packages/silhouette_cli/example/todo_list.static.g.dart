import 'todo.dart';

class TodoList {
  final List<Todo> todos;
  final String newTodo;
  final String filter;

  late final List<Todo> filteredTodos;

  TodoList({this.todos = const <Todo>[], this.newTodo = '', this.filter = 'all'}) {
    filteredTodos = todos.where((t) => !t.completed).toList();
  }

  void build(StringBuffer buffer) {
    buffer.write("<div class=\"todo-app\"><h1>Todo List</h1><div class=\"input-group\"><input type=\"text\" placeholder=\"What needs to be done?\"></input><button>Add</button></div><div class=\"filters\"><button>All</button><button>Active</button><button>Completed</button></div>");
    if (filteredTodos.length > 0) {
      buffer.write("<ul>");
      for (var index = 0; index < filteredTodos.length; index++) {
        final todo = filteredTodos[index];
        buffer.write("<li class=\"");
        buffer.write(todo.completed ? 'completed' : '');
        buffer.write("\"><input type=\"checkbox\" checked=\"");
        buffer.write(todo.completed);
        buffer.write("\"></input><span>");
        buffer.write(todo.text);
        buffer.write("</span><button>Delete</button></li>");
      }
      buffer.write("</ul>");
    }
    else {
      buffer.write("<p>No todos yet!</p>");
    }
    buffer.write("</div>");
  }
}

