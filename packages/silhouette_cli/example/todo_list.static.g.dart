import 'todo.dart';

class TodoList {
  final List<Todo> todos;
  final String newTodo;
  final String filter;

  late final List<Todo> filteredTodos;

  TodoList({this.todos = [], this.newTodo = '', this.filter = 'all'}) {
    filteredTodos = todos.where((t) => !t.completed).toList();
  }

  void build(StringBuffer buffer) {
    buffer.write("<div");
    buffer.write(" class=\"todo-app\"");
    buffer.write(">");
    buffer.write("<h1");
    buffer.write(">");
    buffer.write("Todo List");
    buffer.write("</h1>");
    buffer.write("<div");
    buffer.write(" class=\"input-group\"");
    buffer.write(">");
    buffer.write("<input");
    buffer.write(" type=\"text\"");
    buffer.write(" placeholder=\"What needs to be done?\"");
    buffer.write(">");
    buffer.write("</input>");
    buffer.write("<button");
    buffer.write(">");
    buffer.write("Add");
    buffer.write("</button>");
    buffer.write("</div>");
    buffer.write("<div");
    buffer.write(" class=\"filters\"");
    buffer.write(">");
    buffer.write("<button");
    buffer.write(">");
    buffer.write("All");
    buffer.write("</button>");
    buffer.write("<button");
    buffer.write(">");
    buffer.write("Active");
    buffer.write("</button>");
    buffer.write("<button");
    buffer.write(">");
    buffer.write("Completed");
    buffer.write("</button>");
    buffer.write("</div>");
    if (filteredTodos.length > 0) {
      buffer.write("<ul");
      buffer.write(">");
      for (var index = 0; index < filteredTodos.length; index++) {
        final todo = filteredTodos[index];
        buffer.write("<li");
        buffer.write(" class=\"");
        buffer.write(todo.completed ? 'completed' : '');
        buffer.write("\"");
        buffer.write(">");
        buffer.write("<input");
        buffer.write(" type=\"checkbox\"");
        buffer.write(" checked=\"");
        buffer.write(todo.completed);
        buffer.write("\"");
        buffer.write(">");
        buffer.write("</input>");
        buffer.write("<span");
        buffer.write(">");
        buffer.write(todo.text);
        buffer.write("</span>");
        buffer.write("<button");
        buffer.write(">");
        buffer.write("Delete");
        buffer.write("</button>");
        buffer.write("</li>");
      }
      buffer.write("</ul>");
    }
    else {
      buffer.write("<p");
      buffer.write(">");
      buffer.write("No todos yet!");
      buffer.write("</p>");
    }
    buffer.write("</div>");
  }
}

