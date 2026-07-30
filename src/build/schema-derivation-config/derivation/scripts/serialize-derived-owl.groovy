import org.apache.jena.rdf.model.Model
import org.apache.jena.rdf.model.ModelFactory
import org.apache.jena.rdf.model.RDFNode
import org.apache.jena.rdf.model.ResourceFactory
import org.apache.jena.rdf.model.Resource
import org.apache.jena.rdf.model.Statement
import org.apache.jena.riot.RDFDataMgr
import org.apache.jena.riot.RDFFormat
import org.apache.jena.vocabulary.OWL
import org.apache.jena.vocabulary.RDF

import java.nio.charset.StandardCharsets
import java.util.Locale

if (!binding.hasVariable('inputFile') || !binding.hasVariable('prefixFile')) {
    throw new IllegalArgumentException('serialize-derived-owl.groovy requires inputFile and prefixFile bindings')
}

def logger = binding.hasVariable('log') ? binding.getVariable('log') : null
File input = binding.getVariable('inputFile') as File
File output = binding.hasVariable('outputFile') ? binding.getVariable('outputFile') as File : input
File prefixFile = binding.getVariable('prefixFile') as File
String ontologyIri = binding.hasVariable('ontologyIri') ? binding.getVariable('ontologyIri') as String : null

if (!input.exists()) {
    throw new IllegalArgumentException("Derived OWL input file not found: ${input}")
}
if (!prefixFile.exists()) {
    throw new IllegalArgumentException("OWL derivation prefix file not found: ${prefixFile}")
}

def prefixLines = prefixFile.readLines(StandardCharsets.UTF_8.name())
    .findAll { it.trim().startsWith('@prefix ') }

if (prefixLines.isEmpty()) {
    throw new IllegalStateException("No @prefix declarations found in ${prefixFile}")
}

def prefixMap = new LinkedHashMap<String, String>()
prefixLines.each { line ->
    def matcher = (line =~ /^@prefix\s+([^\s:]+):\s+<([^>]+)>\s+\.$/)
    if (!matcher.matches()) {
        throw new IllegalStateException("Could not parse prefix declaration: ${line}")
    }
    prefixMap.put(matcher.group(1), matcher.group(2))
}

def sourceModel = ModelFactory.createDefaultModel()
RDFDataMgr.read(sourceModel, input.absolutePath)
prefixMap.each { prefix, namespace -> sourceModel.setNsPrefix(prefix, namespace) }

def ontologyCandidates = sourceModel.listResourcesWithProperty(RDF.type, OWL.Ontology).toList().findAll { it.isURIResource() }
Resource ontology = null
if (ontologyIri != null) {
    ontology = ontologyCandidates.find { it.getURI() == ontologyIri }
}
if (ontology == null) {
    if (ontologyCandidates.size() != 1) {
        throw new IllegalStateException("Expected exactly one owl:Ontology in ${input} but found ${ontologyCandidates.size()}")
    }
    ontology = ontologyCandidates[0]
}

def collectSubjectClosure = { Model model, Resource root ->
    def queue = new ArrayDeque<Resource>()
    def seen = new LinkedHashSet<Resource>()
    def statements = new LinkedHashSet<Statement>()
    queue.add(root)
    while (!queue.isEmpty()) {
        def current = queue.removeFirst()
        if (!seen.add(current)) {
            continue
        }
        model.listStatements(current, null, (RDFNode) null).toList().each { st ->
            statements.add(st)
            if (st.getObject().isAnon()) {
                queue.add(st.getObject().asResource())
            }
        }
    }
    return new ArrayList<Statement>(statements)
}

def ontologyStatements = collectSubjectClosure(sourceModel, ontology)
if (ontologyStatements.isEmpty()) {
    throw new IllegalStateException("No statements found for ontology ${ontology.getURI()} in ${input}")
}

def hasGraphMetadata = ResourceFactory.createProperty('http://www.linkedmodel.org/schema/vaem#hasGraphMetadata')
Resource graphMetadata = sourceModel.listStatements(ontology, hasGraphMetadata, (RDFNode) null)
    .toList()
    .findResult { st -> st.getObject().isResource() ? st.getObject().asResource() : null }
def graphMetadataStatements = (graphMetadata != null && graphMetadata.isURIResource())
    ? collectSubjectClosure(sourceModel, graphMetadata)
    : []

def ontologyModel = ModelFactory.createDefaultModel()
def graphMetadataModel = ModelFactory.createDefaultModel()
def remainderModel = ModelFactory.createDefaultModel()
prefixMap.each { prefix, namespace ->
    ontologyModel.setNsPrefix(prefix, namespace)
    graphMetadataModel.setNsPrefix(prefix, namespace)
    remainderModel.setNsPrefix(prefix, namespace)
}
ontologyStatements.each { ontologyModel.add(it) }
graphMetadataStatements.each { graphMetadataModel.add(it) }
remainderModel.add(sourceModel)
remainderModel.remove(ontologyStatements)
if (!graphMetadataStatements.isEmpty()) {
    remainderModel.remove(graphMetadataStatements)
}

def renderBody = { Model model ->
    if (model.isEmpty()) {
        return ''
    }
    def out = new ByteArrayOutputStream()
    RDFDataMgr.write(out, model, RDFFormat.TURTLE_PRETTY)
    def serialized = out.toString(StandardCharsets.UTF_8.name())
    serialized = serialized.replaceFirst(/(?s)^((@prefix|PREFIX)[^\n]*\n)+\n*/, '')
    return serialized.trim()
}

def sortBlocksBySubject = { String body ->
    if (body == null || body.isBlank()) {
        return ''
    }
    def blocks = body.trim().split(/\n\s*\n+/).findAll { !it.isBlank() }
    blocks.sort { a, b ->
        def firstLineA = a.readLines().find { !it.trim().isEmpty() }?.trim() ?: ''
        def firstLineB = b.readLines().find { !it.trim().isEmpty() }?.trim() ?: ''
        def tokenA = firstLineA.tokenize(' \t')[0] ?: ''
        def tokenB = firstLineB.tokenize(' \t')[0] ?: ''
        def rankA = (tokenA.startsWith('[') || tokenA.startsWith('_:')) ? '1' : '0'
        def rankB = (tokenB.startsWith('[') || tokenB.startsWith('_:')) ? '1' : '0'
        def keyA = "${rankA}|${tokenA.toLowerCase(Locale.ROOT)}|${tokenA}"
        def keyB = "${rankB}|${tokenB.toLowerCase(Locale.ROOT)}|${tokenB}"
        keyA <=> keyB
    }
    blocks.join('\n\n')
}

def ontologyBody = renderBody(ontologyModel)
def graphMetadataBody = renderBody(graphMetadataModel)
def remainderBody = sortBlocksBySubject(renderBody(remainderModel))

def builder = new StringBuilder()
prefixLines.each { builder.append(it).append('\n') }
builder.append('\n')
builder.append(ontologyBody).append('\n')
if (!graphMetadataBody.isEmpty()) {
    builder.append('\n').append(graphMetadataBody).append('\n')
}
if (!remainderBody.isEmpty()) {
    builder.append('\n').append(remainderBody).append('\n')
}

output.parentFile.mkdirs()
output.setText(builder.toString(), StandardCharsets.UTF_8.name())

def message = "Serialized derived OWL file ${output} with controlled prefixes and ontology block first"
if (logger != null) {
    logger.info(message)
} else {
    println(message)
}
