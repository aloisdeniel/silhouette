import 'todo.dart';

class TodoList {
  static const String componentId = 'silhouette-todolist-377381';

  final List<Todo> todos;
  final String newTodo;
  final String filter;

  late final List<Todo> filteredTodos;

  TodoList({this.todos = const <Todo>[], this.newTodo = '', this.filter = 'all'}) {
    filteredTodos = todos.where((t) => !t.completed).toList();
  }

  void build(StringBuffer buffer) {
    buffer.write("<div class=\"silhouette-todolist-377381 todo-app\"><h1>Todo List</h1><div class=\"input-group\"><input type=\"text\" placeholder=\"What needs to be done?\"></input><button>Add</button></div><div class=\"filters\"><button>All</button><button>Active</button><button>Completed</button></div>");
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

  static void style(StringBuffer buffer) {
    buffer.write(".silhouette-todolist-377381 .todo-app { \n    max-width: 600px;\n    margin: 0 auto;\n    padding: 20px;\n  }.silhouette-todolist-377381 .input-group { \n    display: flex;\n    gap: 10px;\n    margin-bottom: 20px;\n  }.silhouette-todolist-377381 .input-group input { \n    flex: 1;\n    padding: 10px;\n  }.silhouette-todolist-377381 .filters { \n    margin-bottom: 20px;\n  }.silhouette-todolist-377381 .filters button { \n    margin-right: 10px;\n  }.silhouette-todolist-377381 ul { \n    list-style: none;\n    padding: 0;\n  }.silhouette-todolist-377381 li { \n    display: flex;\n    align-items: center;\n    gap: 10px;\n    padding: 10px;\n    border-bottom: 1px solid #ccc;\n  }.silhouette-todolist-377381 li.completed span { \n    text-decoration: line-through;\n    color: #888;\n  }");
  }
}

