# Profiles

## Overview

### What are profiles?

A **profile** is a subset of QUDT. It is distributed along with QUDT. For each
file in the QUDT distribution, there may be a file in the profile that overrides it.
If there is no such file, the profile uses the QUDT file.

### Specifying Profiles

A profile is defined by configuration files:

Folder `src/build/profile` contains the defaults:
- `default-includes.ttl`: defines how resources are included
- `default-excludes.ttl`: defines how resources are excluded

Folder `src/main/profile/[profilename]` contains the profile-specific configuration:
- `includes.ttl`: lists included resources, modifies how more resources are included via the `default-includes`.
- `excludes.ttl`: lists excluded resources, modifies how more resources are excluded via the `default-includes`.

When the standard distribution files are generated (see `target/dist/`),
the profile algorithm can be executed (using `mvn rdfio:pipeline@profile`, which is triggered
during a normal build)

Example: [Construction Domain Profile](./construction)

### Profile Algorithm

`?profile`: an RDF resource identifying the profile, defined in `includes.ttl` and `excludes.ttl`
`?resource`: placeholder for any RDF resource in QUDT that is either included in or excluded from the profile

1. Create an empty graph `<currentState>`
2. Add all explicit includes from `includes.ttl` to `<currentState>` (these are triples `?profile qudt:includes ?resource`)
3. Loop: Using SHACL-AF inference with `default-includes.ttl` and `includes.ttl`:
   1. Infer `?profile qudt:includes ?resource`
   2. Infer `?profile qudt:blocksIncludes ?resource` (this is a profile-specific configuration - profiles may choose to block certain inferences)
   3. Add all `qudt:includes` triples that are not blocked via `qudt:blocksIncludes` are added to `<currentState>`
   4. If no more triples are found, break the loop
4. Add all explicit excludes from `excludes.ttl` to `<currentState>` (these are triples `?profile qudt:excludes ?resource`)
5. Using SHACL validation with shapes in `excludes.ttl`:
   7. Add `?profile qudt:excludes ?resource` for any resource that causes a violation
6. Loop: Using SHACL-AF inference with `default-excludes.ttl` and `excludes.ttl`:
   1. Infer `?profile qudt:excludes ?resource`
   2. Infer `?profile qudt:blocksExcludes ?resource` (this is a profile-specific configuration - profiles may choose to block certain inferences)
   3. Add all `qudt:excludes` triples that are not blocked via `qudt:blocksExcludes` are added to `<currentState>`
   4. If no more triples are found, break the loop
7. In all files (id, RDF graphs) in `target/dist`:
   If the graph contains a `?resource` that is `?profile ?qudt:includes ?resource`
   and not `?profile ?qudt:excludes ?resource` in `<currentState>`, the resource and its direct triples
   (including blank nodes and their triples) are added to the coresponding file in the profile

Profile-specific files are found under `target/dist/profile/[profilename]`.
