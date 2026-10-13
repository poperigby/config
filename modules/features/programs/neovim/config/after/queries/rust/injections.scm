; extends

(macro_invocation
  macro: [
    (identifier) @_macro
    (scoped_identifier name: (identifier) @_macro)
  ]
  (token_tree
    (raw_string_literal
      (string_content) @injection.content))
  (#eq? @_macro "raw_sql")
  (#set! injection.language "sql"))
