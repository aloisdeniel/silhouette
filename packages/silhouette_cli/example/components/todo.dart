class Todo {
  const Todo({
    required this.text,
    this.completed = false,
  });
  final String text;
  final bool completed;
}
