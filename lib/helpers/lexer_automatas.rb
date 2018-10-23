module LexerAutomatas
  DELIMITER = /\ /
  LETTER = /[a-zA-Z]/
  DIGIT = /[0-9]/
  SPECIAL = /[\!\@\#\%\¨\&\*\(\)\_\+\-\=\§\{\[\ª\}\]\º\?\/\°\`\´\^\~\<\,\>\.\:\;\|\\\“\”\"]/
  RESERVED = /ABS|ATN|COS|DATA|DIM|END|EXP|FOR|GOSUB|GOTO|IF|INT|LET|LOG|NEXT|PRINT|READ|RETURN|RND|SIN|SQR|STEP|TAN|THEN|TO/
  INT = /#{DIGIT}+/
  IDENTIFIER = /#{LETTER}#{DIGIT}?/
  CHARACTER = /#{LETTER}|#{DIGIT}|#{SPECIAL}/
  NUM = /(#{INT}(.#{DIGIT}*)?|.#{INT})(E(\+|-)?#{INT})?/
  SNUM = /(\+|-)?#{NUM}/
  SPECIAL_COMPOSED = />=|<>|<=/
  COMPOSED = /FN#{DELIMITER}#{LETTER}|GO#{DELIMITER}TO|DEF#{DELIMITER}FN#{DELIMITER}#{LETTER}|#{SPECIAL_COMPOSED}|#{NUM}|\"(#{DELIMITER}|#{CHARACTER})+\"|REM#{DELIMITER}(#{CHARACTER}|#{DELIMITER})*/
end
