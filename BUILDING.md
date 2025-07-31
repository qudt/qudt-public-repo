# BUILDING.md

Welcome, contributor! This file explains how to build and modify the QUDT Quantities Units Dimensions andTypes
ontology using the tools in this repository. If you're comfortable with RDF, SHACL, and ontologies but new to Maven or Git, don’t worry—we’ll walk you through it. Think of this as a recipe for turning our RDF sources into a polished, validated set of files, with some handy shortcuts for common tasks.

## What This Build Does

The QUDT project uses Maven (a build tool) to:
- **Validate** RDF files against SHACL shapes (like checking if your triples follow the rules).
- **Infer** new triples e.g., `qudt:applicableUnit`, `qudt:hasFactorUnit`, `qudt:scalingOf` using SHACL rules.
- **Merge** those triples into the right places (like updating `VOCAB_QUDT-UNITS-ALL.ttl`).
- **Format** RDF files to keep them neat and consistent.
- **Package** everything into a ZIP file for distribution (optional).
The process is driven by a `pom.xml` file, which is like a blueprint for Maven. You’ll run commands to trigger specific steps, and we’ll explain the key ones below.

(A detailed description can be seen [here](https://github.com/qudt/qudt-public-repo/wiki/QUDT_Build_Execution_Flow))

## Prerequisites

- **Java**: Version 11 or higher (Maven needs this to run).
- **Maven**: Version 3.6.0 or higher install it from [here](https://maven.apache.org/download.cgi).
- **Git**: To get the code install it from [here](https://git-scm.com/downloads).
- A terminal or command-line tool e.g., Terminal on macOS/Linux, Command Prompt or PowerShell on Windows.

## Setting Up

1. **Fork the Repository**
   Before grabbing the code, go to [https://github.com/qudt/qudt-public-repo](https://github.com/qudt/qudt-public-repo) on GitHub, click the "Fork" button (top right), and create a copy under your own GitHub account. This lets you work on your own version and submit changes later.
2. **Get Your Forked Repository**
   Open your terminal and run replace `YOUR-USERNAME` with your GitHub username:

   ```bash
   git clone https://github.com/YOUR-USERNAME/qudt-public-repo.git
   cd qudt-public-repo
   ```

   This downloads your forked project and moves you into its folder. If you’re new to Git, this is like getting a personal copy of all the RDF files and scripts.

3. **Check Your Tools**
   Run these to make sure everything’s ready:

   ```bash
   java -version  # Should show 11 or higher
   mvn -version   # Should show 3.6.0 or higher
   git --version  # Should show something like 2.x.x
   ```

## Basic Build Commands

Here’s how to work with the RDF data using Maven. Each command runs a series of steps, like validating or inferring triples.

### Full Build

```bash
mvn install
```

- **What it does**: Checks the RDF sources, infers triples e.g., applicable units, merges them into output files, validates everything with SHACL, and puts the results in `target/dist`.
- **When to use**: To test the whole process or prepare a fresh set of files.
- **Output**: Look in `target/dist/vocab/` for the processed RDF files (e.g., `VOCAB_QUDT-UNITS-ALL.ttl`).

### Build with ZIP

```bash
mvn -Pzip install
```

- **What it does**: Same as above, plus bundles `target/dist` into a ZIP file (e.g., `qudt-public-repo-3.0.1-SNAPSHOT.zip`).
- **When to use**: When you’re ready to share the ontology with others.
- **Output**: The ZIP file appears in the project root.

### Fix Sources Early

```bash
mvn -Pfix install
```

- **What it does**: Runs all source-modifying tasks (inference and formatting) right at the start, then completes the full build.
- **When to use**: If you’ve added new units or prefixes and need to update `VOCAB_QUDT-UNITS-ALL.ttl` before validation.

## Special Commands for RDF Tasks

These commands are for specific ontology tasks—like inferring new triples—and aren’t part of the automatic build. They’re perfect for tweaking the RDF data directly. Run them as needed.
1. **Update All Source Inferences and Formatting**

```bash
mvn seq:run@infer-and-format
```

- **What it does**: Infers `qudt:hasFactorUnit` and `qudt:scalingOf` triples, merges them into `src/main/rdf/vocab/unit/VOCAB_QUDT-UNITS-ALL.ttl`, and formats the result.
- **When to use**: To refresh all inferred data in the source file at once e.g., after adding new units or prefixes.

2. **Infer and Merge Factor Units**

   ```bash
   mvn seq:run@infer-factorUnits
   ```

   - **What it does**: Infers `qudt:hasFactorUnit` triples e.g., relationships between units like "meter per second", merges them into `VOCAB_QUDT-UNITS-ALL.ttl`, and formats it.
   - **When to use**: If validation fails and says factor units are missing or wrong (check `target/validation/validationReportSrc-factorUnits.ttl`).
3. **Infer and Merge Scaling Relationships**

   ```bash
   mvn seq:run@infer-scalingOf
   ```

   - **What it does**: Infers `qudt:scalingOf` triples e.g., how units scale with prefixes like "kilo", merges them into `VOCAB_QUDT-UNITS-ALL.ttl`, and formats it.
   - **When to use**: If validation flags scaling issues (check `target/validation/validationReportSrc-factorUnits.ttl`).

## How It Works: Key Steps

The build process is split into stages (Maven calls them "phases"). Here’s what happens, in terms an RDF expert might appreciate:
- **Validate**: Sets up properties like the version `3.0.1-SNAPSHOT` and prepares SHACL templates from `src/build/sparql2shacl/`.
- **Process Sources**: Checks that all `.ttl` files in `src/` are formatted and valid against SHACL shapes (e.g., `QUDT_SRC_QA_TESTS.ttl`).
- **Compile**: Infers triples like `qudt:applicableUnit` and merges them into `target/dist/` files.
- **Process Resources**: Adds links to IEC standards e.g., `qudt:informativeReference` for units.
- **Test**: Validates the final output in `target/dist/` against stricter SHACL tests.
- **Install** (with `-Pzip`): Optionally creates the ZIP.
The special commands above like `mvn seq:run@infer-factorUnits` let you run inference and merging steps manually, updating the source files directly instead of waiting for the full build.

(A detailed description can be seen [here](https://github.com/qudt/qudt-public-repo/wiki/QUDT_Build_Execution_Flow))

## Troubleshooting

- **TL;DR**: If you don't know or don't want to dig deep, run:

  ```
  mvn -Pfix clean install
  ```

  The build might take a while longer than by using any of the options below, doing some things that aren't necessary, but it will most likely succeed.

- **Formatting Issues**: If the build stops at "check-source-format," your `.ttl` files might not be neat enough. Run:

  ```bash
  mvn spotless:apply
  ```

  Then check the changes with `git status` and commit them.

- **Validation Fails**: Look at the report files in `target/validation/`. If it mentions factor units or scaling, run the matching special command (e.g., `mvn seq:run@infer-factorUnits`).

- **Missing Files**: Make sure `src/main/rdf/` and `src/build/` have all the expected `.ttl` files. If not, you might need to pull the latest changes:

  ```bash
  git pull
  ```

## Contributing

1. **Edit RDF Files**: Work in `src/main/rdf/` (e.g., add units to `VOCAB_QUDT-UNITS-ALL.ttl` or prefixes to `VOCAB_QUDT-PREFIXES.ttl`).
2. **Run Inferences**: Use the special commands to update inferred triples.
3. **Test Locally**: Run `mvn install` to validate your changes.
4. **Commit Changes**: Use Git:

   ```bash
   git add .
   git commit -m "Added new unit X"
   git push origin your-branch
   ```

   Then submit a pull request from your forked repository on GitHub to the original `qudt/qudt-public-repo`.
   If Git’s new to you, think of it as a way to save and share your ontology updates—ask a teammate for help if needed!

## Questions?

This setup might feel like a lot if you’re new to Maven, but it’s all about automating the tedious parts of ontology work—validation, inference, and formatting. Reach out via GitHub issues if you get stuck, and happy building!
