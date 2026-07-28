The biggest difference you will see in this release is our scrubbing of the QuantityKind vocabulary to remove commensurability inconsistencies and missing or spurious `qudt:applicableUnit` assertions.

**Breaking:** `unit:BIT`, `unit:BYTE`, `unit:OCTET` and their prefixed/compound ladder are now counting/storage units rather than information-entropy units; consumers using them for information content should switch to `unit:SHANNON`.
