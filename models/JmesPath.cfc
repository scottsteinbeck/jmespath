component {

    function compile(stream) {
        var parser = new Parser();
        var ast = parser.parse(stream);
        return ast;
    }
    function tokenize(stream) {
        var lexer = new Lexer();
        return lexer.tokenize(stream);
    }
    function search(data, expression) {
        variables.parser = new Parser();
        // This needs to be improved.  Both the interpreter and runtime depend on
        // each other.  The runtime needs the interpreter to support exprefs.
        // There's likely a clean way to avoid the cyclic dependency.
        var runtime = new Runtime();
        var interpreter = new TreeInterpreter(runtime);
        var node = parser.parse(expression);
        return interpreter.search(node, data);
    }

}
