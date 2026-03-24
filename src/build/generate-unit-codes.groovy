import java.security.MessageDigest

/**
 * Generates a unique 6-character alphanumeric qudt:code for every unit
 * in VOCAB_QUDT-UNITS-ALL.ttl that doesn't already have one.
 *
 * The code is derived deterministically from the unit's local name
 * (the part after "unit:") using a SHA-256 hash encoded in base-36.
 *
 * Usage: groovy generate-unit-codes.groovy [path-to-units-file]
 *        Defaults to src/main/rdf/vocab/unit/VOCAB_QUDT-UNITS-ALL.ttl
 */

def CODE_LENGTH = 6
def CODE_CHARS = ('A'..'Z') + ('0'..'9')
def BASE = CODE_CHARS.size() // 36

def defaultPath = new File(getClass().protectionDomain.codeSource.location.toURI()).parentFile.parentFile.parentFile
def unitsFile = args.length > 0
    ? new File(args[0])
    : new File(defaultPath, "main/rdf/vocab/unit/VOCAB_QUDT-UNITS-ALL.ttl")

if (!unitsFile.exists()) {
    System.err.println("File not found: ${unitsFile}")
    System.exit(1)
}

def lines = unitsFile.readLines()

// Parse unit blocks, tracking multi-line literals (""") to avoid false matches
def unitPattern = ~/^unit:(\S+)\s*$/
def codePattern = ~/^\s+qudt:code\s+/
def existingCodeValuePattern = ~/^\s+qudt:code\s+"([^"]+)"/
def units = []          // list of local names in file order
def hasCode = [] as Set // local names that already have qudt:code
def usedCodes = [] as Set // codes already in use

// unitBlocks maps localName -> [startLine, endLine] (indices into lines[])
def unitEndLines = [:]  // localName -> index of the closing '.' line

String currentUnit = null
boolean inMultiLineLiteral = false

lines.eachWithIndex { line, idx ->
    // Track multi-line literals (""")
    def tripleQuoteCount = (line =~ /"""/).count
    if (inMultiLineLiteral) {
        if (tripleQuoteCount % 2 == 1) inMultiLineLiteral = false
        return
    }
    if (tripleQuoteCount % 2 == 1) {
        inMultiLineLiteral = true
        return
    }

    def m = unitPattern.matcher(line)
    if (m.matches()) {
        currentUnit = m.group(1)
        units << currentUnit
    } else if (currentUnit) {
        if (codePattern.matcher(line).find()) {
            hasCode << currentUnit
            def cm = existingCodeValuePattern.matcher(line)
            if (cm.find()) usedCodes << cm.group(1)
        }
        // A line that is just '.' or ends with ' .' (outside multi-line literals) closes the block
        if (line.trim() == '.' || (line =~ /\s\.\s*$/ && !line.trim().startsWith('#'))) {
            unitEndLines[currentUnit] = idx
            currentUnit = null
        }
    }
}

println "Found ${units.size()} units, ${hasCode.size()} already have qudt:code"

// Generate a 6-char code from a local name with an optional salt
def generateCode = { String localName, int salt = 0 ->
    def input = salt == 0 ? localName : "${localName}#${salt}"
    def digest = MessageDigest.getInstance("SHA-256").digest(input.getBytes("UTF-8"))
    def code = new StringBuilder()
    def value = BigInteger.ZERO
    for (int i = 0; i < 8; i++) {
        value = value.shiftLeft(8).or(BigInteger.valueOf(digest[i] & 0xFF))
    }
    value = value.abs()
    for (int i = 0; i < CODE_LENGTH; i++) {
        def remainder = value.mod(BigInteger.valueOf(BASE))
        code.append(CODE_CHARS[remainder.intValue()])
        value = value.divide(BigInteger.valueOf(BASE))
    }
    code.toString()
}

// Generate codes for all units that need them, resolving collisions
def codeMap = [:]  // localName -> code

units.each { localName ->
    if (hasCode.contains(localName)) return

    def salt = 0
    def code = generateCode(localName, salt)
    while (usedCodes.contains(code)) {
        salt++
        code = generateCode(localName, salt)
        if (salt > 100) {
            System.err.println("ERROR: Could not generate unique code for unit:${localName} after 100 attempts")
            System.exit(1)
        }
    }
    usedCodes << code
    codeMap[localName] = code
}

println "Generated ${codeMap.size()} new codes"
if (codeMap.isEmpty()) {
    println "Nothing to do."
    return
}

// Build output: for each unit that needs a code, insert qudt:code before the closing '.'
// The closing line (e.g. '  skos:altLabel "amp" .') gets its ' .' changed to ' ;'
// and a new line '  qudt:code "XXXXXX" .' is appended after it.
def outputLines = []
def insertionPoints = [:] as Map // line index -> code to insert

codeMap.each { localName, code ->
    def endIdx = unitEndLines[localName]
    if (endIdx != null) insertionPoints[endIdx] = code
}

lines.eachWithIndex { line, idx ->
    if (insertionPoints.containsKey(idx)) {
        def code = insertionPoints[idx]
        if (line.trim() == '.') {
            // Bare dot — not common but handle it: just insert code line before it
            outputLines << "  qudt:code \"${code}\" ;"
            outputLines << line
        } else {
            // Property line ending with ' .' — change to ' ;'
            def fixedLine = line.replaceFirst(/\s*\.\s*$/, ' ;')
            outputLines << fixedLine
            outputLines << "  qudt:code \"${code}\" ."
        }
    } else {
        outputLines << line
    }
}

unitsFile.text = outputLines.join('\n') + '\n'
println "Updated ${unitsFile}"
