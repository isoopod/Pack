---
sidebar_position: 3
---

# Miscellaneous Datatypes

These datatypes do not fit into the category of primitive or structural.

## custom

The `custom` datatype is used as a simple way to create a custom datatype that will be used once.  
If performance is essential or the datatype needs to be reused, you can create an extension datatype using the exposed internal Pack types.

```lua
-- See the API reference for the Reader and Writer libraries.
-- In this example, the datatype just represents a float64
Pack:DefineSchema(
    Pack.custom(
        function(reader)
            return Pack.Reader.f64(reader)
        end,
        function(writer, val: number)
            Pack.Writer.alloc(writer, 4)
            Pack.Writer.f64(writer, val)
        end
    )
)
```