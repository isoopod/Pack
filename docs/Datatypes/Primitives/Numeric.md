---
sidebar_position: 1
---
<!-- markdownlint-disable MD033 -->
# Numeric Datatypes

All of the following datatypes can be used to represent numbers in Luau. By default, Luau uses [Float64](#float64) for most numeric values. This is the most flexible and precise option, but also the largest in terms of memory usage. Depending on your needs, other numeric types may be more appropriate.

There are two main categories of numeric datatypes:

* **Floating-point numbers (Floats):** These can represent numbers with decimal points, making them useful when precision with fractions is required (e.g. `3.14`, `-2.75`). However, floating-point values can be less efficient and are subject to rounding errors at very high or very precise values.

* **Integers (Ints and UInts):** These represent whole numbers only. Integers are often faster and more efficient than floats.

  * **Ints (signed integers):** Can store both negative and positive whole numbers.
  * **UInts (unsigned integers):** Can only store positive whole numbers (including zero), but their maximum value is twice as high as the equivalent signed integer.

Choosing the correct type is important for both performance and correctness. For example, use floats when working with measurements or fractions, and integers when counting objects or using values that will always be whole numbers.

---

## Float16

:::note
The use case for this datatype is very niche.
:::

```lua
Pack.Float16
```

Encodes a 16-bit floating point number using 2 bytes

Range:
    - Subnormal: ±6.1×10<sup>-5</sup>
    - Normal: ±6.5×10<sup>4</sup>
Precision: ~3.3 decimal places

---

## Float24

:::note
The use case for this datatype is very niche.
:::

```lua
Pack.Float24
```

Encodes a 24-bit floating point number using 3 bytes

Range:
    - Subnormal: ±1×10<sup>-19</sup>
    - Normal: ±2×10<sup>19</sup>
Precision: ~5.9 decimal places

---

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

---

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

---

## Fraction

:::note[Aliases]
**Frac** is an alias for Fraction and can be used instead
:::

```lua
Pack.Fraction
```

Encodes a proper fraction (positive real number between 0 and 1) with a fixed precision of 1/2<sup>16</sup> (0.00001525878).

:::warning
Fraction stores a number between 0–1 (1 **inclusive**) so you will have to handle that if using this for storing the fractional part of a number. The reason Fraction includes 1 is because there are many situations where you need a value between 0 and 1.
:::

---

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

---

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

---

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

---

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

---

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

---

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

---

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

---

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
