---
sidebar_position: 4
---
<!-- markdownlint-disable MD033 -->
# Vector Datatypes

Vectors are used to represent multi-dimensional numeric data, such as positions, directions, or velocities in 2D or 3D space. Each component of a vector is stored using a numeric datatype, which determines its range, precision, and memory usage.

* **Vector2** represents a 2-dimensional vector `(x, y)`.
* **Vector3** represents a 3-dimensional vector `(x, y, z)`.

By default, vectors use **Float32** for each component, which matches the behaviour of Luau vectors and provides sufficient precision for most applications. However, you can choose a different numeric type for each component if needed (for example, `Float24` or `Int16`) to reduce memory usage or enforce specific constraints.

* **int16 vectors** (`Vector2int16`, `Vector3int16`) store each component as a fixed-size integer. These vectors use less memory and exist for compatibility with the Roblox datatypes, but Roblox’s integer-based vectors are much slower than regular Vector3s so they should generally be avoided. Try to use `Pack.Vector3(Pack.Int16)` instead.

---

## Vector2

```lua
Pack.Vector2 -- Uses Float32 by default (8 bytes total)
Pack.Vector2(Pack.Float24) -- Can be called with any other numeric datatype
```

Encodes a 2D vector of any numeric datatype.

Vector2 uses a Float32 when not provided another datatype, which is consistent with Luau vectors (Making a Vector2 with Float64s will not increase precision).
see [Float32](./Numeric.md#float32) for approximate range and precision of each component.

---

## Vector2int16

```lua
Pack.Vector2int16
```

Encodes a 2D vector of int16s using 4 bytes.

---

## Vector3

```lua
Pack.Vector3 -- Uses Float32 by default (12 bytes total)
Pack.Vector3(Pack.Float24) -- Can be called with any other numeric datatype
```

Encodes a 3D vector of any numeric datatype.

Vector3 uses a Float32 when not provided another datatype, which is consistent with Luau vectors (Making a Vector3 with Float64s will not increase precision).  
see [Float32](./Numeric.md#float32) for approximate range and precision of each component.

:::note
Compatible with the Roblox Vector3 library and luau vector library.  
Will return as a luau vector, but these are interchangeable with the Vector3 library.  
(Vector3 methods can be used on vectors and vector library functions can take Vector3s)
:::

---

## Vector3int16

```lua
Pack.Vector3int16
```

Encodes a 3D vector of int16s with 6 bytes.

:::note
You should try to avoid using the Vector3int16 datatype in general because it is much slower than Vector3.
:::
