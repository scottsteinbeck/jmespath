<cfscript>
    fileContent = fileRead(expandPath("./testbox.json"), "utf-8")
    jmespath = new models.jmespath();
    result = jmespath.search(deserializeJSON(fileContent),'to_entries(dependencies)[?contains(key,`co`)].key');
    writedump(serializeJSON(result))
</cfscript>