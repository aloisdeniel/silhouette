/// Abstract Syntax Tree node definitions for Silhouette components
library;

/// Base class for all AST nodes
abstract class AstNode {
  final int start;
  final int end;

  AstNode(this.start, this.end);
}

/// Root node representing a complete component
class RootNode extends AstNode {
  final ScriptNode? script;
  final ScriptNode? moduleScript;
  final StyleNode? style;
  final FragmentNode fragment;

  RootNode({
    required this.script,
    required this.moduleScript,
    required this.style,
    required this.fragment,
    required int start,
    required int end,
  }) : super(start, end);
}

/// Script block node (<script> or <script context="module">)
class ScriptNode extends AstNode {
  final String content;
  final bool isModule;

  ScriptNode({
    required this.content,
    required this.isModule,
    required int start,
    required int end,
  }) : super(start, end);
}

/// Style block node (<style>)
class StyleNode extends AstNode {
  final String content;
  final bool scoped;

  StyleNode({
    required this.content,
    required this.scoped,
    required int start,
    required int end,
  }) : super(start, end);
}

/// Fragment node containing template nodes
class FragmentNode extends AstNode {
  final List<TemplateNode> nodes;

  FragmentNode({
    required this.nodes,
    required int start,
    required int end,
  }) : super(start, end);
}

/// Base class for template nodes
abstract class TemplateNode extends AstNode {
  String? componentId;
  
  TemplateNode(super.start, super.end, {this.componentId});
}

/// Text node
class TextNode extends TemplateNode {
  final String data;

  TextNode({
    required this.data,
    required int start,
    required int end,
    super.componentId,
  }) : super(start, end);
}

/// Expression tag node {expression}
class ExpressionTagNode extends TemplateNode {
  final String expression;

  ExpressionTagNode({
    required this.expression,
    required int start,
    required int end,
    super.componentId,
  }) : super(start, end);
}

/// HTML tag node {@html expression}
class HtmlTagNode extends TemplateNode {
  final String expression;

  HtmlTagNode({
    required this.expression,
    required int start,
    required int end,
    super.componentId,
  }) : super(start, end);
}

/// Element node (HTML element or component)
class ElementNode extends TemplateNode {
  final String name;
  final List<AttributeNode> attributes;
  final List<TemplateNode> children;
  final bool isComponent;

  ElementNode({
    required this.name,
    required this.attributes,
    required this.children,
    required this.isComponent,
    required int start,
    required int end,
    super.componentId,
  }) : super(start, end);
}

/// Attribute node
abstract class AttributeNode extends AstNode {
  AttributeNode(super.start, super.end);
}

/// Regular attribute
class RegularAttribute extends AttributeNode {
  final String name;
  final List<AttributeValue> value;

  RegularAttribute({
    required this.name,
    required this.value,
    required int start,
    required int end,
  }) : super(start, end);
}

/// Attribute value (can be text or expression)
abstract class AttributeValue extends AstNode {
  AttributeValue(super.start, super.end);
}

class TextAttributeValue extends AttributeValue {
  final String text;

  TextAttributeValue({
    required this.text,
    required int start,
    required int end,
  }) : super(start, end);
}

class ExpressionAttributeValue extends AttributeValue {
  final String expression;

  ExpressionAttributeValue({
    required this.expression,
    required int start,
    required int end,
  }) : super(start, end);
}

/// Spread attribute {...props}
class SpreadAttribute extends AttributeNode {
  final String expression;

  SpreadAttribute({
    required this.expression,
    required int start,
    required int end,
  }) : super(start, end);
}

/// Event handler attribute on:event={handler}
class EventAttribute extends AttributeNode {
  final String event;
  final String? handler;

  EventAttribute({
    required this.event,
    required this.handler,
    required int start,
    required int end,
  }) : super(start, end);
}

/// Bind directive bind:property={value}
class BindDirective extends AttributeNode {
  final String property;
  final String value;

  BindDirective({
    required this.property,
    required this.value,
    required int start,
    required int end,
  }) : super(start, end);
}

/// Control flow blocks
abstract class BlockNode extends TemplateNode {
  BlockNode(super.start, super.end, {super.componentId});
}

/// If block {#if condition}...{:else}...{/if}
class IfBlockNode extends BlockNode {
  final String condition;
  final List<TemplateNode> consequent;
  final List<TemplateNode>? alternate;

  IfBlockNode({
    required this.condition,
    required this.consequent,
    required this.alternate,
    required int start,
    required int end,
    super.componentId,
  }) : super(start, end);
}

/// Each block {#each items as item, index (key)}...{/each}
class EachBlockNode extends BlockNode {
  final String expression;
  final String itemName;
  final String? indexName;
  final String? keyExpression;
  final List<TemplateNode> body;
  final List<TemplateNode>? fallback;

  EachBlockNode({
    required this.expression,
    required this.itemName,
    required this.indexName,
    required this.keyExpression,
    required this.body,
    required this.fallback,
    required int start,
    required int end,
    super.componentId,
  }) : super(start, end);
}

/// Await block {#await promise}...{:then value}...{:catch error}...{/await}
class AwaitBlockNode extends BlockNode {
  final String expression;
  final String? thenVariable;
  final String? catchVariable;
  final List<TemplateNode>? pending;
  final List<TemplateNode>? then;
  final List<TemplateNode>? catchBlock;

  AwaitBlockNode({
    required this.expression,
    required this.thenVariable,
    required this.catchVariable,
    required this.pending,
    required this.then,
    required this.catchBlock,
    required int start,
    required int end,
    super.componentId,
  }) : super(start, end);
}

/// Snippet block {#snippet name(params)}...{/snippet}
class SnippetBlockNode extends BlockNode {
  final String name;
  final String parameters;
  final List<TemplateNode> body;

  SnippetBlockNode({
    required this.name,
    required this.parameters,
    required this.body,
    required int start,
    required int end,
    super.componentId,
  }) : super(start, end);
}

/// Render tag {@render expression}
class RenderTagNode extends TemplateNode {
  final String expression;

  RenderTagNode({
    required this.expression,
    required int start,
    required int end,
    super.componentId,
  }) : super(start, end);
}
