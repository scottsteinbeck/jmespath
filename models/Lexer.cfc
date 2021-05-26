component accessors=true singleton displayname="Lexer" {

    TOK_EOF = 'EOF';
    TOK_UNQUOTEDIDENTIFIER = 'UnquotedIdentifier';
    TOK_QUOTEDIDENTIFIER = 'QuotedIdentifier';
    TOK_RBRACKET = 'Rbracket';
    TOK_RPAREN = 'Rparen';
    TOK_COMMA = 'Comma';
    TOK_COLON = 'Colon';
    TOK_RBRACE = 'Rbrace';
    TOK_NUMBER = 'Number';
    TOK_CURRENT = 'Current';
    TOK_EXPREF = 'Expref';
    TOK_PIPE = 'Pipe';
    TOK_OR = 'Or';
    TOK_AND = 'And';
    TOK_EQ = 'EQ';
    TOK_GT = 'GT';
    TOK_LT = 'LT';
    TOK_GTE = 'GTE';
    TOK_LTE = 'LTE';
    TOK_NE = 'NE';
    TOK_FLATTEN = 'Flatten';
    TOK_STAR = 'Star';
    TOK_FILTER = 'Filter';
    TOK_DOT = 'Dot';
    TOK_NOT = 'Not';
    TOK_LBRACE = 'Lbrace';
    TOK_LBRACKET = 'Lbracket';
    TOK_LPAREN = 'Lparen';
    TOK_LITERAL = 'Literal';
    // The "&", "[", "<", ">" tokens
    // are not in basicToken because
    // there are two token variants
    // ("&&", "[?", "<=", ">=").  This is specially handled
    // below.
    basicTokens = {
        '.': TOK_DOT,
        '*': TOK_STAR,
        ',': TOK_COMMA,
        ':': TOK_COLON,
        '{': TOK_LBRACE,
        '}': TOK_RBRACE,
        ']': TOK_RBRACKET,
        '(': TOK_LPAREN,
        ')': TOK_RPAREN,
        '@': TOK_CURRENT
    };
    operatorStartToken = {
        '<': true,
        '>': true,
        '=': true,
        '!': true
    };
    skipChars = {' ': true, '#chr(13)#': true, '#chr(10)#': true};
    function nullValue() {
        return javacast('null', '');
    }
    function isAlpha(ch) {
        return (ch >= 'a' && ch <= 'z') ||
        (ch >= 'A' && ch <= 'Z') ||
        ch == '_';
    }
    function isNum(ch) {
        return (ch >= '0' && ch <= '9') ||
        ch == '-';
    }
    function isAlphaNum(ch) {
        return (ch >= 'a' && ch <= 'z') ||
        (ch >= 'A' && ch <= 'Z') ||
        (ch >= '0' && ch <= '9') ||
        ch == '_';
    }

	function lookupValue(state,stream){
		if(state._current <= stream.len()){
			return stream[state._current];
		} else {
			return nullValue();
		}
	}

	function advance(state,stream){
		state._current++;
		/* systemoutput(state._current & ' - ' & stream.len(),1);
		if(state._current  < stream.len()){
		} else {
			throw( type="JSONException", message= 'Malformed Query :''' & (stream) & '''');
		}
		return; */
	}

    function tokenize(stream) {
        var tokens = [];
        var state = {
            _current: 1
        }
        var start = '';
        var identifier = '';
        var token = '';
		var maxLength = stream.len();
        while (state._current <= maxLength) {
            if ( isAlpha( lookupValue(state,stream))) {
                start = state._current;
                identifier = _consumeUnquotedIdentifier(stream,state);
                tokens.append({type: TOK_UNQUOTEDIDENTIFIER, value: identifier, start: start});
            } else if ( lookupValue(state,stream)== '[') {
                // No need to increment state._current.  This happens
                // in _consumeLBracket
                token = _consumeLBracket(stream,state);
                tokens.append(token);
            } else if ( lookupValue(state,stream)== '"') {
                start = state._current;
                identifier = _consumeQuotedIdentifier(stream,state);
                tokens.append({type: TOK_QUOTEDIDENTIFIER, value: identifier, start: start});
            } else if ( lookupValue(state,stream)== "'") {
                start = state._current;
                identifier = _consumeRawStringLiteral(stream,state);
                tokens.append({type: TOK_LITERAL, value: identifier, start: start});
            } else if ( lookupValue(state,stream)== '`') {
                start = state._current;
                literal = _consumeLiteral(stream,state);
                tokens.append({type: TOK_LITERAL, value: literal, start: start});
            } else if (skipChars.keyExists( lookupValue(state,stream) )) {
                // Ignore whitespace.
				advance(state,stream);
            } else if (isNum(lookupValue(state, stream))) {
                token = _consumeNumber(stream, state);
                tokens.append(token);
            } else if (operatorStartToken.keyExists(lookupValue(state, stream))) {
                tokens.append(_consumeOperator(stream, state));
            } else if ( lookupValue(state,stream) == '&') {
                start = state._current;
				advance(state,stream);
                if ( lookupValue(state,stream) == '&') {
                    advance(state,stream);
                    tokens.append({type: TOK_AND, value: '&&', start: start});
                } else {
                    tokens.append({type: TOK_EXPREF, value: '&', start: start});
                }
            } else if ( lookupValue(state,stream) == '|') {
                start = state._current;
                advance(state,stream);
                if ( lookupValue(state,stream) == '|') {
                    advance(state,stream);
                    tokens.append({type: TOK_OR, value: '||', start: start});
                } else {
                    tokens.append({type: TOK_PIPE, value: '|', start: start});
                }
            } else if (!isNull(basicTokens[lookupValue(state, stream)])) {
                tokens.append({
                    type: basicTokens[lookupValue(state, stream)],
                    value: lookupValue(state, stream),
                    start: state._current
                });
                advance(state, stream);
            } else {
                throw( type="JMESError", message= 'Unknown character:(' & asc( lookupValue(state,stream)) & ')');
            }
        }

        return tokens;
    }

    function slice(str, startIndex, endIndex) {
        return mid(str, startIndex, endIndex - startIndex);
    }

    function _consumeUnquotedIdentifier(stream,state) {
        var start = state._current;
        advance(state,stream);
        while (state._current <= stream.len() && isAlphaNum( lookupValue(state,stream))) {
            advance(state,stream);
        }
        return slice(stream, start, state._current);
    }

    function _consumeQuotedIdentifier(stream,state) {
        //echo('_consumeQuotedIdentifier ' & stream);
        var start = state._current;
        advance(state,stream);
        var maxLength = stream.len();
        while ( lookupValue(state,stream) != '"') {
            // You can escape a double quote and you can escape an escape.
            var current = state._current;
            if (
                stream[current] == '\' && (
                    stream[current + 1] == '\' ||
                    stream[current + 1] == '"'
                )
            ) {
                current += 2;
            } else {
                current++;
            }
            state._current = current;
        }
        advance(state,stream);
        stream = slice(stream, start, state._current);
        //stream = CharsetDecode(stream, "utf-8");

        //echo("[" & stream & ' -- ' & start  & ' -- ' & state._current & "] ->" & val & "<br/>");
        return parseJson(stream,state);
    }

    function _consumeRawStringLiteral(stream,state) {
        //echo('_consumeRawStringLiteral ' & stream);
        var start = state._current;
        advance(state,stream);
        var maxLength = stream.len();
        while (lookupValue(state,stream) != "'") {
            // You can escape a single quote and you can escape an escape.
            var current = state._current;
            if (
                stream[current] == '\' && (
                    stream[current + 1] == '\' ||
                    stream[current + 1] == "'"
                )
            ) {
                current += 2;
            } else {
                current++;
            }
            state._current = current;
        }
        advance(state,stream);
        var literal = slice(stream, start + 1, state._current - 1);
        return replace(literal,"\\'", "'","all");
    }

    function _consumeNumber(stream,state) {
        var start = state._current;
        advance(state,stream);
        var maxLength = stream.len();
        while (state._current < maxLength && isNum( lookupValue(state,stream)) ) {
            advance(state,stream);
        }
        var value = slice(stream, start, state._current).replaceAll('[^0-9\-]', '');
        return {type: TOK_NUMBER, value: value, start: start};
    }

    function _consumeLBracket(stream,state) {
        var start = state._current;
        advance(state,stream);
        if ( lookupValue(state,stream) == '?') {
            advance(state,stream);
            return {type: TOK_FILTER, value: '[?', start: start};
        } else if ( lookupValue(state,stream) == ']') {
            advance(state,stream);
            return {type: TOK_FLATTEN, value: '[]', start: start};
        } else {
            return {type: TOK_LBRACKET, value: '[', start: start};
        }
    }

    function _consumeOperator(stream,state) {
        var start = state._current;
        var startingChar = stream[start];
        var maxLength = stream.len()
        advance(state,stream);
        if (startingChar == '!') {
            if (lookupValue(state,stream) == '=') {
                advance(state,stream);
                return {type: TOK_NE, value: '!=', start: start};
            } else {
                return {type: TOK_NOT, value: '!', start: start};
            }
        } else if (startingChar == '<') {
            if (lookupValue(state,stream) == '=') {
                advance(state,stream);
                return {type: TOK_LTE, value: '<=', start: start};
            } else {
                return {type: TOK_LT, value: '<', start: start};
            }
        } else if (startingChar == '>') {
            if (lookupValue(state,stream) == '=') {
                advance(state,stream);
                return {type: TOK_GTE, value: '>=', start: start};
            } else {
                return {type: TOK_GT, value: '>', start: start};
            }
        } else if (startingChar == '=') {
            if (lookupValue(state,stream) == '=') {
                advance(state,stream);
                return {type: TOK_EQ, value: '==', start: start};
            }
        }
    }

    function _consumeLiteral(stream,state) {
        advance(state,stream);
        var start = state._current;
        var maxLength = stream.len();
        var literal = '';
        while (lookupValue(state,stream)!= '`') {
            // You can escape a literal char or you can escape the escape.
            current = state._current;
            if (
                stream[current] == '\' && (
                    stream[current + 1] == '\' ||
                    stream[current + 1] == '`'
                )
            ) {
                current += 2;
            } else {
                current++;
            }
            state._current = current;
        }
        literalString = lTrim(slice(stream, start, state._current));
        literalString = replace(literalString,'\`', '`', 'all');


        if (_looksLikeJSON(literalString)) {
            literal = parseJson(literalString);
        } else {
            // Try to deserializeJSON it as "<literal>"
            literal = parseJson("'" & literalString & "'");
            //literal = parseJson(literal);
        }
        if(isSimpleValue(literal)){
            literal = parseJson(literal);
        }
        // +1 gets us to the ending "`", +1 to move on to the next char.
        advance(state,stream);
        return literal;
    }

    function _looksLikeJSON(literalString) {
        var startingChars = '[{';
        var jsonLiterals = ['true', 'false', 'null'];
        var numberLooking = '-0123456789';

        if (literalString == '') {
            return false;
        } else if (find(literalString[1],startingChars) > 0) {
            return true;
        } else if (arrayFind(jsonLiterals, literalString) > 0) {
            return true;
        } else if (find(literalString[1], numberLooking) > 0) {
            try {
                deserializeJSON(literalString);
                return true;
            } catch (any e) {
                return false;
            }
        } else {
            return false;
        }
    }

    /**
     * Parses a JSON token or sets the token type to "unknown" on error.
     *
     * @param array $token Token that needs parsing.
     *
     * @return array Returns a token with a parsed value.
     */
    private function parseJson(token) {
        try {
            value = deserializeJSON(token);
        } catch (any e) {
            //echo(token & " -> Error: " & e.message & "<br/>");
            //return token;
            try {
                value = deserializeJSON('"' & token & '"');
            } catch (any f) {
                //echo(token & " -> Error: " & f.message & "<br/>");
                return token;
            }
        }
        return value ?: NullValue();
    }

}
