import 'package:test/test.dart';
import 'package:silhouette_cli/src/compiler/parser.dart';
import 'package:silhouette_cli/src/compiler/ast.dart';

void main() {
  group('Parser', () {
    test('parses snippet and render tags', () {
      final source = '''
        {#snippet mySnippet(arg)}
          <div>{arg}</div>
        {/snippet}

        {@render mySnippet("hello")}
      ''';
      
      final parser = Parser(source);
      final root = parser.parse();
      
      // The nodes are:
      // 0: SnippetBlockNode
      // 1: RenderTagNode
      // (whitespace is skipped)
      
      final nodes = root.fragment.nodes.where((n) => n is! TextNode || n.data.trim().isNotEmpty).toList();
      
      expect(nodes.length, 2);
      
      final snippet = nodes[0] as SnippetBlockNode;
      expect(snippet.name, 'mySnippet');
      expect(snippet.parameters, 'arg');
      
      // Inside snippet:
      // ElementNode (div)
      expect(snippet.body.length, 1); 
      
      final render = nodes[1] as RenderTagNode;
      expect(render.expression, 'mySnippet("hello")');
    });

     test('parses snippet without params', () {
      final source = '''
        {#snippet mySnippet}
          <div>Content</div>
        {/snippet}
      ''';
      
      final parser = Parser(source);
      final root = parser.parse();
      
      final nodes = root.fragment.nodes.where((n) => n is! TextNode || n.data.trim().isNotEmpty).toList();
      final snippet = nodes[0] as SnippetBlockNode;
      expect(snippet.name, 'mySnippet');
      expect(snippet.parameters, isEmpty);
    });

    test('parses snippet with empty params', () {
      final source = '''
        {#snippet mySnippet()}
          <div>Content</div>
        {/snippet}
      ''';
      
      final parser = Parser(source);
      final root = parser.parse();
      
      final nodes = root.fragment.nodes.where((n) => n is! TextNode || n.data.trim().isNotEmpty).toList();
      final snippet = nodes[0] as SnippetBlockNode;
      expect(snippet.name, 'mySnippet');
      expect(snippet.parameters, isEmpty);
    });
  });
}
