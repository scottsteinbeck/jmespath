component {

    function compile(stream) {
        variables.parser = new Parser();
        variables.ast = parser.parse(stream);
        return ast;
    }
    function tokenize(stream) {
        variables.lexer = new Lexer();
        return lexer.tokenize(stream);
    }
    function search(data, expression) {
        variables.parser = new Parser();
        // This needs to be improved.  Both the interpreter and runtime depend on
        // each other.  The runtime needs the interpreter to support exprefs.
        // There's likely a clean way to avoid the cyclic dependency.
        variables.runtime = new Runtime();
        variables.interpreter = new TreeInterpreter(variables.runtime);
        variables.node = parser.parse(expression);
        return interpreter.search(node, data);
    }

}
