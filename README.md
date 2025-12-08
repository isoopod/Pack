# Pack

## [Documentation](https://isoopod.github.io/Pack/)

Schematized buffer serialization library for Roblox.

Pack enables the definition of complex data structures using schemas, which describe the layout of the input data (parallel data). It serializes these structures into compact buffers (serial data) and can later deserialize them to accurately reconstruct the original values.

Pack focuses on efficient data compression, making it suitable for networking and storage scenarios while maintaining clear, schema-driven structure for reliable data interchange.

This project implements a high-performance binary serialization framework for Roblox, designed for precise control over data layout, efficient memory usage, and deterministic encoding across a wide range of datatypes. It provides a unified system for describing packet structures, defining custom datatypes, and encoding or decoding structured data at byte- and bit-level granularity.

Schemas and datatype interfaces form the core of the typing model. A schema defines the structure of a packet, specifying the expected fields and their types. Both static and dynamic datatypes are supported, allowing primitives, arrays, structs, unions, and more advanced constructs to be composed declaratively.

## Roadmap

*These features are planned or partially implemented, but not in the current release or not completely finished.*  
*Ticked features are partially implemented*

- [x] Full test coverage with Jest-Lua
- [ ] Full instance marshalling (instead of baked references)
- [x] Documentation (comprehensive rewrite in the works)
