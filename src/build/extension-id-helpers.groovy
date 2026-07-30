// Shared helpers for reading and validating extension ID properties.
// Loaded via: new GroovyShell(this.class.classLoader, binding).evaluate(
//     new File(project.basedir, 'src/build/extension-id-helpers.groovy'))
// The helpers are written to the caller's binding (no 'def') so they are
// immediately usable in the calling script.

propertyValue = { propertyName ->
    def userValue = session.userProperties.getProperty(propertyName)
    userValue != null ? userValue : project.properties.getProperty(propertyName)
}

parseExtensionIds = { propertyName ->
    def raw = (propertyValue(propertyName) ?: '').trim()
    if (!raw) {
        return []
    }
    def ids = raw.split(',').collect { it.trim() }.findAll { it }
    def invalidIds = ids.findAll { !(it ==~ /[a-z][a-z0-9-]*/) }
    if (!invalidIds.isEmpty()) {
        throw new Exception("${propertyName} contains invalid extension id(s): ${invalidIds.join(', ')}. Use comma-separated ids matching [a-z][a-z0-9-]*.")
    }
    return ids.unique()
}
