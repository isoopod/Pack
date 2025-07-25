---
sidebar_position: 1
---
<!-- markdownlint-disable MD033 -->
# Primitive Datatypes

In Pack, a primitive datatype refers to datatypes that contain only their own data. By this definition, Datatypes like Vector3 are treated as primitives, where they might normally be called compound datatypes or aggregate datatypes.

## Any

```lua
Pack.Any
```

The Any datatype attempts to automatically encode any value inserted, at the cost of a much higher overhead. Currently, Any has few optimizations for tables, treating them all as arrays of any when possible (1 byte overhead for each value), otherwise falling back to a map of `[any]: any` (2 bytes of overhead for each key-value pair) and does not support metatables or functions.

## BitField

```lua
Pack.BitField(length: number)
```

A BitField is a highly compressed array of booleans, utilizing the packet bitbuffer to fix 8 booleans worth of data per byte.  
To use this datatype, you must pass in a fixed length of how many booleans it is expected to store.  
When writing to this datatype, it is in the format of an array of booleans. If the array is shorter than the expected length, the last values will be treated as false.  
Reading it will return the array of booleans in the same order.  

:::info
You should try to have the defined length as close to a multiple of eight as possible.  
If your bitfield length is a mutliple of 8 (including 0) + 1, use a regular boolean for that last bool instead.
:::

## Boolean

```lua
Pack.Boolean
```

Encodes a true/false value into a single byte.

## BrickColor

```lua
Pack.BrickColor
```

Encodes a BrickColor value in 2 bytes.

## BufferFixed

```lua
Pack.BufferFixed(bytes: number)
```

BufferFixed refers a fixed length buffer, where a buffer of a known length will encoded with zero overhead.  
The fixed length of the buffer in bytes must be passed in.

## Buffer8

```lua
Pack.Buffer8
```

Encodes a buffer of variable length between 0 and 255 bytes with 1 byte of overhead.

## Buffer16

```lua
Pack.Buffer16
```

Encodes a buffer of variable length between 0 and 65,535 bytes with 2 bytes of overhead.

## Buffer24

```lua
Pack.Buffer24
```

Encodes a buffer of variable length between 0 and 16 MiB with 3 bytes of overhead.

## Buffer32

```lua
Pack.Buffer32
```

Encodes a buffer of any length with 4 bytes of overhead. The maximum length with a buffer32 is greater than the 1 GiB size limit of buffers.

## CFrame

```lua
Pack.CFrame
```

Encodes a CFrame as either 13 or 19 bytes. A standard Vector3 is used for position. Axis-Aligned CFrames are 13 bytes, otherwise for random orientation CFrames they are encoded in 19 bytes using a Quaternion for rotation, with an average precision of 0.00461° (more than enough).

## Color3

```lua
Pack.Color3
```

Encodes a Color3 value as standard 24-bit RGB in 3 bytes.  
:::note
The Color3 Datatype actually uses 32 bit floats to store RGB, meaning sometimes colors will have RGB values above 255.  
If this is necessary, use Color3float32 instead
:::

## Color3float32

```lua
Pack.Color3float32
```

Enodes a Color3 value in full using 12 bytes. This is for when you have colors with RGB values above 255.

## DateTime

```lua
Pack.DateTime
```

Encodes a DateTime with millisecond precision using 8 bytes.

## EnumItem

```lua
Pack.EnumItem(enum: Enum)
```

Encodes an EnumItem from a provided Roblox Enum using between 1 and 2 bytes.  
Some common Enums such as Material and KeyCode use 2 bytes due to how these Enums were set up (they have items with values going past 255)

## Float16

```lua
Pack.Float16
```

Encodes a 16-bit floating point number using 2 bytes

Range:
    - Subnormal: ±6.1×10<sup>-5</sup>
    - Normal: ±6.5×10<sup>4</sup>
Precision: ~3.3 decimal places

## Float24

```lua
Pack.Float24
```

Encodes a 24-bit floating point number using 3 bytes

Range:
    - Subnormal: ±1×10<sup>-19</sup>
    - Normal: ±2×10<sup>19</sup>
Precision: ~5.9 decimal places

## Float32

:::note[Aliases]
**Float** is an alias for Float32 and can be used instead
:::

```lua
Pack.Float32
Pack.Float
```

Encodes a 32-bit floating point number using 4 bytes

Range:
    - Subnormal: ±1.2×10<sup>-38</sup>
    - Normal: ±3.4×10<sup>38</sup>
Precision: ~7.2 decimal places

## Float64

:::note[Aliases]
**Double** is an alias for Float64 and can be used instead
:::

```lua
Pack.Float64
Pack.Double
```

Enocdes a 64-bit floating point number using 8 bytes. This is the type used by lua numbers. It is also the only numeric type that can be used for UserIds, as those have passed the 32-bit unsigned integer limit.

Range:
    - Subnormal: ±2.2×10<sup>-308</sup>
    - Normal: ±1.8×10<sup>308</sup>
Precision: ~15.9 decimal places

## Instance

```lua
Pack.Instance
```

Encodes a reference to an Instance. This will place a UID tag on the instance so it can be located later. This UID is 4 bytes.  
Note that the UID tag is not removed, as
:::warning
This reference does not persist between server and client

**WRITE UNSAFE**  
Writing a reference to an Instance that does not already have a UID will synchronize the thread
:::
In saving places, references persist between server runtimes.

## Int8

:::note[Aliases]
**Byte** is an alias for Int8 and can be used instead
:::

```lua
Pack.Int8
Pack.Byte
```

Enocdes an 8-bit signed integer in a single byte.  
Range: -128 – +127

## Int16

:::note[Aliases]
**Short** is an alias for Int16 and can be used instead
:::

```lua
Pack.Int16
Pack.Short
```

Encodes a 16-bit signed integer in 2 bytes.  
Range: -32,768 – +32,767

## Int32

:::note[Aliases]
**Int** is an alias for Int32 and can be used instead
:::

```lua
Pack.Int32
Pack.Int
```

Encodes a 32-bit signed integer in 4 bytes.
Range: -2,147,483,648 – +2,147,483,647

## Int64

:::note[Aliases]
**Long** is an alias for Int64 and can be used instead
:::

```lua
Pack.Int64
Pack.Long
```

Encodes a 64-bit signed integer using 8 bytes.

This datatype is implemented using two 32-bit segments due to Luau's `number` type limitations, which only supports exact representation up to 2<sup>53</sup> − 1.
The value is split into a low and high 32-bit integer in little-endian order (low first, then high), and recombined on read.

Range (exact): −9,007,199,254,740,991 – +9,007,199,254,740,991

Values beyond this safe range lose precision due to the limitations of Luau’s number type (IEEE 754 double).
Use only for integers within ±2<sup>53</sup> for guaranteed correctness.  
See [Wikipedia](https://en.wikipedia.org/wiki/Double-precision_floating-point_format#Precision_limitations_on_integer_values) for how Doubles lose integer precision.

Int64 values used in the Roblox ecosystem, such as AssetIds and UserIds take Luau's number limitations into account, so Int64 and UInt64 can be used to store these.

## Literal

```lua
Pack.Literal(value: any)
```

Holds a literal value without any overhead. This is useful in tuples.

## Null

```lua
Pack.Null
```

Represents nothing, directly uses zero bytes. For use in the Union structure (WIP)

## Object

```lua
Pack.Object(metatable: any, data: any)
```

Allows marshalling a lua object by providing the class's metatable, and a [Dictionary](Structures/#dictionary) of members to serialize from the object.  
This should work for most common OOP patterns. An example has been provided for the classic lua OOP paradigm.

```lua
-- Example Class --
local exampleClass = {}
exampleClass.__index = exampleClass

function exampleClass:SomeMethod(val: number)
    self.someProperty = val
end

function exampleClass.new(val: number)
    local self = setmetatable({}, exampleClass)

    self.someProperty = val

    return self
end
----

-- Create a schema to marshall exampleClass by providing its metatable 
-- as well as instructions to serialize its properties
local schema = Pack:DefineSchema(Pack.object(getmetatable(exampleClass), Pack.Dictionary({
    someProperty = Pack.Double
})))
----

-- Test it with an object of exampleClass
local exampleObject = exampleClass.new(1)

print(exampleObject.someProperty) -- >>> 1
exampleObject:SomeMethod(10)
print(exampleObject.someProperty) -- >>> 10

local reconstructedObject = schema:Read(schema:Write(exampleObject))

print(reconstructedObject.someProperty) -- >>> 10
reconstructedObject:SomeMethod(100)
print(reconstructedObject.someProperty) -- >>> 100
```

## Region3

```lua
Pack.Region3
```

Encodes a Region3 as a min and max Vector3, giving a total of 24 bytes.

## Region3int16

```lua
Pack.Region3int16
```

Encodes a Region3int16 as a min and max Vector3int16, giving a total of 12 bytes.

## StringFixed

```lua
Pack.StringFixed(bytes: number)
```

StringFixed refers a fixed length string, where a string of a known length will encoded with zero overhead.  
The fixed length of the string in bytes must be passed in. (One character can take 1 to 4 bytes)

## String8

```lua
Pack.String8
```

Encodes a string of variable length between 0 and 255 bytes with 1 byte of overhead.  
Chars already have a variable length of 1-4, so this can range from 255 chars to 63 chars.

## String16

```lua
Pack.String16
```

Encodes a string of variable length between 0 and 65,535 bytes with 2 bytes of overhead.
Chars already have a variable length of 1-4, so this can range from 65,535 chars to 16,383 chars.

## String24

```lua
Pack.String24
```

Encodes a string of variable length between 0 and 16 MiB with 3 bytes of overhead.

## String32

```lua
Pack.String32
```

Encodes a string of any length with 4 bytes of overhead. The maximum length with a string32 is bigger than the 1 GiB size limit of buffers.

## UDim

```lua
Pack.UDim
```

Encodes a single UDim as 6 bytes.  
We assume the offset will be within the range of a int16. If this is not the case, you will have to send the UDim as a float32 scale and int32 offset.

## UDim2

```lua
Pack.UDim2
```

Encodes a UDim2 as 12 bytes.
We assume the offset will be within the range of a int16. If this is not the case, you will have to send the two UDims as a float32 scale and int32 offset.

## UInt8

:::note[Aliases]
**UByte** is an alias for UInt8 and can be used instead
:::

```lua
Pack.UInt8
Pack.UByte
```

Enocdes an 8-bit unsigned integer in a single byte.  
Range: [0–255]

## UInt16

:::note[Aliases]
**UShort** is an alias for UInt16 and can be used instead
:::

```lua
Pack.UInt16
Pack.UShort
```

Encodes a 16-bit unsigned integer in 2 bytes.  
Range: [0–65,565]

## UInt32

:::note[Aliases]
**UInt** is an alias for UInt32 and can be used instead
:::

```lua
Pack.UInt32
Pack.UInt
```

Encodes a 32-bit unsigned integer in 4 bytes.
Range: [0–4,294,967,295]

## UInt64

:::note[Aliases]
**ULong** is an alias for UInt56 and can be used instead
:::

```lua
Pack.UInt64
Pack.ULong
```

Encodes a 64-bit unsigned integer using 8 bytes.

Like [Int64](#int64), this is encoded by splitting the number into low and high 32-bit unsigned segments in little-endian order (low first, then high), and combining them when reading.
Range (exact): [0–9,007,199,254,740,992]

Although UInt64 can store exact integers up to 2<sup>53</sup>, Luau numbers lose precision above 2<sup>53</sup>.  
Refer to [Int64](#int64) for more info.

## Vector2float32

:::note[Aliases]
**Vector2** is an alias for Vector2float32 and can be used instead
:::

```lua
Pack.Vector2float32
Pack.Vector2
```

Encodes a 2D vector of float32s using 8 bytes.

see [Float32](#float32) for approximate range and precision of each component.

## Vector2float24

```lua
Pack.Vector2float24
```

Encodes a 2D vector of float24s using 6 bytes.  

see [Float24](#float24) for approximate range and precision of each component.

## Vector2float16

```lua
Pack.Vector2float16
```

Encodes a 2D vector of float16s with 4 bytes.

see [Float16](#float16) for approximate range and precision of each component.

## Vector2int16

```lua
Pack.Vector2int16
```

Encodes a 2D vector of int16s using 4 bytes.

## Vector3float32

:::note[Aliases]
**Vector3** is an alias for Vector3float32 and can be used instead
:::

```lua
Pack.Vector3float32
Pack.Vector3
```

Encodes a 3D vector of float32s using 12 bytes.

see [Float32](#float32) for approximate range and precision of each component.

:::note
Compatible with the Roblox Vector3 library and luau vector library.  
Will return as a luau vector, but these are interchangeable with the Vector3 library.  
(Vector3 methods can be used on vectors and vector library functions can take Vector3s)
:::

## Vector3float24

```lua
Pack.Vector3float24
```

Encodes a 3D vector of float24s using 9 bytes.  

see [Float24](#float24) for approximate range and precision of each component.

## Vector3float16

```lua
Pack.Vector3float16
```

Encodes a 3D vector of float16s with 6 bytes.  

see [Float16](#float16) for approximate range and precision of each component.

## Vector3int16

```lua
Pack.Vector3int16
```

Encodes a 3D vector of int16s with 6 bytes.
