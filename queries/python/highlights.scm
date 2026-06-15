; extends

; Override @attribute for method calls — must come after the base query
; so it takes priority over the generic (attribute attribute: @attribute) capture
(call
  function: (attribute
    attribute: (identifier) @function.method.call))
