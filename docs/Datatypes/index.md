---
sidebar_position: 1
---

# Datatypes

Datatypes are accessed through Pack with the dot operator. E.g.,

```lua
Pack.String32
```

Most datatypes—like String32—are just indexed directly; however more complex or customizable datatypes may require you to call them as functions. E.g.,

```lua
-- Bitfield requires a length to be given
Pack.Bitfield(8)

-- Many datatypes take other datatypes as an argument
Pack.Array(Pack.String32)
```

Some datatypes can be both directly indexed and called as a function, such as Vector3. Datatypes like this will use a default when indexed directly.

```lua
-- This is a Vector3 using Float32 components
Pack.Vector3

-- But we can also make one that uses Int32 components
Pack.Vector3(Pack.Int32)
```

Datatypes in Pack may fall into one of following categories:

## Primitive Datatypes

In Pack, a primitive datatype refers to datatypes that contain only their own data. By this definition, Datatypes like Vector3 are treated as primitives, where they might normally be called compound datatypes or aggregate datatypes.

## Structural Datatypes

In Pack, structural datatypes are types that do not hold their own data, but instead help you organize primitive datatypes. This includes data structures like Arrays and Maps, as well as datatypes that help you structure your data such as Dictionary (lets you create structured data), Nullable, and Union.

## Miscellaneous Datatypes

These datatypes do not fit into the category of primitive or structural.
