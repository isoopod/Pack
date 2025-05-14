# Pack

## [Documentation](https://isoopod.github.io/Pack/)

Schematized Luau buffer serialization library.

Pack allows you to define complex data (refered to as parallel data) structures through schemas, which represents the structure of the data you pass through,
and serializes it into a packet (as a buffer, refered to as serial data), and later deserialize it to reconstruct the original data.

Pack empathises data compression, which is optimal for networking and data storage, but also features alternative data structures that empathise speed, aimed
towards parallel luau. This allows you to represent more versatile data structures within shared tables without the performance impact of nesting shared tables.

## Roadmap

*These features are planned/implemented, but not in the current release or not completely finished.*  

- [ ] Proper test coverage with Jest-Lua
- [x] Datatype evaluators for infered datatypes (union, any)
- [ ] Full instance marshalling (instead of baked references)
- [x] Documentation
