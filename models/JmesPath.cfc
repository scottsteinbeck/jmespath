component accessors=true {

    property name="jmesPathLexer" inject="Lexer@JMESPath";
    property name="jmesPathParser" inject="Parser@JMESPath";
    property name="jmesPathRuntime" inject="Runtime@JMESPath";
    property name="jmesPathTreeInterpreter" inject="TreeInterpreter@JMESPath";

    function init() {
        if (isNull(variables.jmesPathLexer)) {
            if (!APPLICATION.keyExists('jmesPathLexer') || 1) APPLICATION.jmesPathLexer = new Lexer();
            setJmesPathLexer(APPLICATION.jmesPathLexer);
        }
        if (isNull(variables.jmesPathParser)) {
            if (!APPLICATION.keyExists('jmesPathParser') || 1) APPLICATION.jmesPathParser = new Parser();
            setJmesPathParser(APPLICATION.jmesPathParser);
        }
        if (isNull(variables.jmesPathRuntime)) {
            if (!APPLICATION.keyExists('jmesPathRuntime') || 1) APPLICATION.jmesPathRuntime = new Runtime();
            setJmesPathRuntime(APPLICATION.jmesPathRuntime);
        }
        if (isNull(variables.jmesPathTreeInterpreter)) {
            if (!APPLICATION.keyExists('jmesPathTreeInterpreter') || 1)
                APPLICATION.jmesPathTreeInterpreter = new TreeInterpreter(jmesPathRuntime);
            setJmesPathTreeInterpreter(APPLICATION.jmesPathTreeInterpreter);
        }
        return this;
    }

    function compile(stream) {
        var ast = jmesPathParser.parse(stream);
        return ast;
    }
    function tokenize(stream) {
        return jmesPathLexer.tokenize(stream);
    }
    function search(data, expression) {
        var node = jmesPathParser.parse(expression);
        return jmesPathTreeInterpreter.search(node, data);
    }

}
