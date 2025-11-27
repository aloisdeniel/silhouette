import 'package:example_app/components/greetings.static.g.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

void main(List<String> arguments) async {
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(_router);

  final server = await io.serve(handler, 'localhost', 8080);
  print('Server listening on port ${server.port}');
}

Response _router(Request request) {
  if (request.url.path == 'styles.css') {
    return _handleStylesCss(request);
  } else if (request.url.path == 'index.html' || request.url.path == '') {
    return _handleIndexHtml(request);
  }
  return Response.notFound('Not found');
}

Response _handleStylesCss(Request request) {
  final buffer = StringBuffer();
  Greetings.style(buffer);
  return Response.ok(buffer.toString(), headers: {'content-type': 'text/css'});
}

Response _handleIndexHtml(Request request) {
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
  Greetings(
    name: request.requestedUri.queryParameters['name'] ?? 'Unknown',
    count:
        int.tryParse(request.requestedUri.queryParameters['count'] ?? '0') ?? 0,
  ).build(html);
  html.write('''
</body>
</html>
''');
  return Response.ok(html.toString(), headers: {'content-type': 'text/html'});
}
