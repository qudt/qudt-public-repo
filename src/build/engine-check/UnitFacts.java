import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.HashSet;
import java.util.Set;
import org.apache.jena.rdf.model.*;
import org.apache.jena.riot.RDFDataMgr;
import org.apache.jena.riot.RDFFormat;
import org.apache.jena.vocabulary.RDF;

/**
 * Extracts, from the built unit and quantity-kind vocabularies in target/dist, the facts the
 * unit/quantity-kind consistency checks need for the units and quantity kinds the examples mention:
 * each one's qudt:hasDimensionVector, and the qudt:applicableUnit links between them, which the
 * build infers and the source vocabularies do not hold. So that the main schema's shapes find
 * nothing missing, each dimension vector reached is copied whole, and the quantity kind it
 * references is typed and given its dimension vector.
 * Arguments: units file, quantity-kinds file, dimension-vectors file, stub file (whose subjects are
 * the IRIs wanted), output.
 */
public class UnitFacts {
    static final String QUDT = "http://qudt.org/schema/qudt/";

    public static void main(String[] args) throws IOException {
        Model units = RDFDataMgr.loadModel(args[0]);
        Model quantityKinds = RDFDataMgr.loadModel(args[1]);
        Model dimensionVectors = RDFDataMgr.loadModel(args[2]);
        Model stub = RDFDataMgr.loadModel(args[3]);
        Set<Resource> wanted = new HashSet<>(stub.listSubjects().toList());

        Property dimension = stub.createProperty(QUDT + "hasDimensionVector");
        Property applicableUnit = stub.createProperty(QUDT + "applicableUnit");
        Property referenceQuantityKind = stub.createProperty(QUDT + "hasReferenceQuantityKind");
        Resource quantityKind = stub.createResource(QUDT + "QuantityKind");
        Model facts = ModelFactory.createDefaultModel();
        facts.setNsPrefixes(stub.getNsPrefixMap());
        for (Resource r : wanted) {
            facts.add(units.listStatements(r, dimension, (RDFNode) null));
            facts.add(quantityKinds.listStatements(r, dimension, (RDFNode) null));
            for (Statement s : quantityKinds.listStatements(r, applicableUnit, (RDFNode) null).toList()) {
                if (wanted.contains(s.getResource())) facts.add(s);
            }
        }
        // Copy each dimension vector reached whole, and type its reference quantity kind and give
        // it its dimension vector, as the stub types the units and quantity kinds
        for (RDFNode v : facts.listObjectsOfProperty(dimension).toList()) {
            facts.add(dimensionVectors.listStatements(v.asResource(), null, (RDFNode) null));
        }
        for (RDFNode q : facts.listObjectsOfProperty(referenceQuantityKind).toList()) {
            facts.add(q.asResource(), RDF.type, quantityKind);
            facts.add(quantityKinds.listStatements(q.asResource(), dimension, (RDFNode) null));
        }
        Files.createDirectories(Paths.get(args[4]).toAbsolutePath().getParent());
        try (OutputStream out = new FileOutputStream(args[4])) {
            RDFDataMgr.write(out, facts, RDFFormat.TURTLE_PRETTY);
        }
        System.err.println("unit and quantity-kind facts: " + facts.size());
    }
}
