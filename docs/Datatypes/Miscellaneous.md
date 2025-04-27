---
sidebar_position: 3
---

# Miscellaneous Datatypes

These datatypes do not fit into the category of primitive or structural.

## Custom

The `Custom` datatype is used as a simple way to create a custom datatype that will be used once.  
If performance is essential or the datatype needs to be reused, you can create an extension datatype using the exposed internal Pack types.

```lua
-- See the API reference for the Reader and Writer libraries.
-- In this example, the datatype just represents a float64
Pack:DefineSchema(
    Pack.Custom(
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

## Transformer

The `Transformer` datatype functions as a convenient wrapper for transforming raw data into a more efficient format for encoding, and reversing that process.
The `format` (usually a [Dictionary](Structures#dictionary)) is how the data will be encoded by Pack. 
The `encode` function should take some data not that would not directly be accepted by `format` and transform it such that it can be. 
The `decode` function would then bring data encoded in that `format` and turn it back into the original format

`encode` and `decode` are both optional, allowing you to use the transformer for data normalization, such as filling in defaults.

```lua
type standard = {
    color: string -- Hex string
    enabled: "True" | "False"
}

Pack:DefineSchema(
    Pack.Transformer(
        Pack.Dicitonary({
            color = Pack.Color3,
            enabled = Pack.Boolean,
        })
    ),
    function(input: standard)
        local result = {}
        result.color = Color3.FromHex(input.color)
        result.enabled = input.enabled == "True"
        
        return result
    end,
    function(input) -- The type should be inferred as the same type as the dictionary
        local result = {}
        result.color = input.color:ToHex()
        result.enabled = input.enabled and "True" or "False

        return result
    end
)
```