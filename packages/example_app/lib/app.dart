class App {
  String render(Function(StringBuffer buffer) body) {
    final html = StringBuffer('''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Example App</title>
  <link rel="stylesheet" href="/styles.css">
</head>
<body>''');
    body(html);
    html.write('''
</body>
</html>
''');
    return html.toString();
  }
}
