import org.apache.jena.rdf.model.*;
import org.apache.jena.riot.RDFDataMgr;
import org.topbraid.shacl.validation.ValidationEngineConfiguration;
import org.topbraid.shacl.validation.ValidationUtil;

/**
 * Runs the build's SHACL engine (TopBraid, via the same jars as shacl-maven-plugin) with report
 * details off — the plugin hard-codes them on, which breaks on the schema shapes.
 * Prints one TSV line per result: focus node, severity, source constraint, message, value, path.
 */
public class EngineCheck {
    static final String SH = "http://www.w3.org/ns/shacl#";

    public static void main(String[] args) {
        Model shapes = RDFDataMgr.loadModel(args[0]);
        Model data = RDFDataMgr.loadModel(args[1]);
        ValidationEngineConfiguration conf =
                new ValidationEngineConfiguration().setReportDetails(false).setValidateShapes(false);
        Resource report = ValidationUtil.validateModel(data, shapes, conf);
        Property result = report.getModel().createProperty(SH + "result");
        int n = 0;
        for (StmtIterator it = report.listProperties(result); it.hasNext(); n++) {
            Resource r = it.next().getResource();
            String source = text(data, r, "sourceConstraint");
            if (source.isEmpty() || source.equals("_:blank")) source = text(data, r, "sourceConstraintComponent");
            System.out.println(String.join("\t", text(data, r, "focusNode"), text(data, r, "resultSeverity"),
                    source, text(data, r, "resultMessage").replace('\n', ' '), text(data, r, "value"),
                    text(data, r, "resultPath")));
        }
        System.err.println("results: " + n);
    }

    static String text(Model prefixes, Resource r, String localName) {
        Statement s = r.getProperty(r.getModel().createProperty(SH + localName));
        if (s == null) return "";
        RDFNode o = s.getObject();
        if (o.isURIResource()) return prefixes.shortForm(o.asResource().getURI());
        if (o.isLiteral()) return o.asLiteral().getLexicalForm();
        return "_:blank";
    }
}
