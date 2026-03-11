;; extends
(macro_invocation
  macro: (identifier) @name (#any-of? @name "css" "style" "styled")
  (token_tree
    (raw_string_literal
      (string_content) @content))
  (#set! injection.language "css")
  (#set! injection.content_type "declaration_list"))
