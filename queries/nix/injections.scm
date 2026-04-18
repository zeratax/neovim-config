; extends

((binding
  attrpath: (attrpath) @_path
  expression: (indented_string_expression
    (string_fragment) @injection.content))
 (#match? @_path "\\.kdl\"")
 (#set! injection.language "kdl")
 (#set! injection.combined))
