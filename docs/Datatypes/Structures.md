---
sidebar_position: 2
---

# Structural Datatypes

In Pack, structural datatypes are types that do not hold their own data, but instead help you organize primitive datatypes.

## Array

An array is an ordered collection of values with the same type.  
Arrays are one-based for consistency with lua.  
Arrays have two bytes of overhead and can contain a maximum of 65,565 elements by deafult.  
The type of number the array uses to encode the length can be changed with the second argument
and should be an unsigned integer. By default this is UInt16.

```lua
Pack:DefineSchema(Pack.Array(Pack.Vector3))
```

## Dictionary

A Pack Dictionary refers to a table with predefined keys.  
This is sometimes called a struct in similar libraries.  
Dictionaries add no overhead.

```lua
Pack:DefineSchema(Pack.Dictionary({
    -- Doesn't matter which way you assign string keys
    ["A"] = Pack.Float64,
    B = Pack.Float32,
    -- You aren't limited to just strings as the key.
    -- Beware that using non-string keys may break the typing, and explicit type annotation may not be able to fix it.
    [0] = Pack.CFrame,
    -- You can nest Dictionaries and use other structural datatypes inside a dictionary
    Nested = Pack.Dictionary({
        A = Pack.String16,
    }),
}))
```

## Map

A Map is a mapping of some type of key to some type of value.  
This is very useful when used with the Union or any datatypes (WIP).  
Maps have two bytes of overhead to store the number of elements they contain.

```lua
-- Represents a table with string keys and Vector3 values
Pack:DefineSchema(Pack.Map(Pack.string8, Pack.Vector3))
```

## Nullable

The Nullable datatype indicates the value is optional and may be nil. This adds 1 byte of overhead for every nullable value.

```lua
-- A packet from this schema could be 1 bytes long or 13 bytes long, depending if the Vector3 was passed in or not.
Pack:DefineSchema(Pack.Nullable(Pack.Vector3))
```

## SparseDictionary

A Pack SparseDictionary refers to a table with predefined keys, each of which are optional.  
The second argument is for requried keys, which functions like a regular Dictionary.  
SparseDictionaries have the overhead of a BitField for all optional keys.

```lua
Pack:DefineSchema(Pack.SparseDictionary({
    -- Optional keys
    CFrame = Pack.CFrame,
    Velocity = Pack.Vector3,
    -- Do not do:
    opt = Pack.Nullable(Pack.CFrame)
    -- All keys in the optional table are already nullable
}))
```

## Union

The Union datatype indicates a value may be one of many datatypes, adding 1 byte of overhead. The order of the values is the order they will be evaluated.
