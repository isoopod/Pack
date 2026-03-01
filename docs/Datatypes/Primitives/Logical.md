---
sidebar_position: 3
---
<!-- markdownlint-disable MD033 -->
# Logical (Boolean & Nil) Datatypes

These datatypes are for logical values (**true**, **false**, **nil**). [Boolean](#boolean) is the most important datatype in this category.

See [Structures](../Structures.md/#nullable) for the `Nullable` datatype, which makes values optional.

---

## BitField

```lua
Pack.BitField(length: number)
```

A BitField is good for storing fixed length arrays of booleans. Because [Booleans](#boolean) already only use 1 bit, there is minimal reason to use this over several Boolean fields.

To use this datatype, you must pass in a fixed length of how many booleans it is expected to store.  
When writing to this datatype, it is in the format of an array of booleans. If the array is shorter than the expected length, the last values will be treated as false.  
Reading it will return the array of booleans in the same order.  

---

## Boolean

```lua
Pack.Boolean
```

Encodes a true/false value into a single bit by using the packet's bitbuffer.

---

## Null

```lua
Pack.Null
```

Represents nothing, uses zero bytes. For use in the [Union](../Structures.md/#union) structure.
