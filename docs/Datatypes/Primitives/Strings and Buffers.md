---
sidebar_position: 2
---
<!-- markdownlint-disable MD033 -->
# String & Buffer Datatypes

Strings and buffers are both ways of representing sequences of bytes. The main difference is in how those bytes are interpreted:

* **Strings** are intended for text. They represent characters encoded as one or more bytes (usually between 1 and 4 bytes per character). Strings therefore need to account for the fact that character length and byte length are not always the same.
* **Buffers** are intended for raw binary data. They represent bytes directly, without any interpretation as characters. This makes them ideal for storing arbitrary data, files, or encoded values.

Both strings and buffers can be stored in fixed or variable-length formats:

* **Fixed-length types** (e.g. `StringFixed`, `BufferFixed`) require you to specify the size in advance, and they store values with no extra overhead.
* **Variable-length types** (e.g. `String8`, `Buffer16`, `String32`) include a small amount of overhead to store the length, but they allow more flexibility since the size can change at runtime.

---

## BufferFixed

```lua
Pack.BufferFixed(bytes: number)
```

BufferFixed refers a fixed length buffer, where a buffer of a known length will encoded with zero overhead.  
The fixed length of the buffer in bytes must be passed in.

---

## Buffer8

```lua
Pack.Buffer8
```

Encodes a buffer of variable length between 0 and 255 bytes with 1 byte of overhead.

---

## Buffer16

```lua
Pack.Buffer16
```

Encodes a buffer of variable length between 0 and 65,535 bytes with 2 bytes of overhead.

---

## Buffer24

```lua
Pack.Buffer24
```

Encodes a buffer of variable length between 0 and 16 MiB with 3 bytes of overhead.

---

## Buffer32

```lua
Pack.Buffer32
```

Encodes a buffer of any length with 4 bytes of overhead. The maximum length with a buffer32 is greater than the 1 GiB size limit of buffers.

---

## StringFixed

```lua
Pack.StringFixed(bytes: number)
```

StringFixed refers a fixed length string, where a string of a known length will encoded with zero overhead.  
The fixed length of the string in bytes must be passed in. (One character can take 1 to 4 bytes)

:::info
StringFixed will error if a string is passed in that does not match the expected length. You can store shorter strings in a StringFixed field by padding it:

```lua
-- Truncate or pad `str` so that it fits exactly in `n` bytes.
local function toFixedLength(str: string, n: number): string
    if #str > n then return string.sub(str, 1, n) end

    local padCount = n - #str
    return str .. string.rep("\0", padCount)
end
```

Note that the null characters `\0` will need to be removed for the string to display correctly later.

```lua
str:gsub("\0", "")
```

:::

---

## String8

```lua
Pack.String8
```

Encodes a string of variable length between 0 and 255 bytes with 1 byte of overhead.  
Chars already have a variable length of 1-4, so this can range from 255 chars to 63 chars.

---

## String16

```lua
Pack.String16
```

Encodes a string of variable length between 0 and 65,535 bytes with 2 bytes of overhead.
Chars already have a variable length of 1-4, so this can range from 65,535 chars to 16,383 chars.

---

## String24

```lua
Pack.String24
```

Encodes a string of variable length between 0 and 16 MiB with 3 bytes of overhead.

---

## String32

```lua
Pack.String32
```

Encodes a string of any length with 4 bytes of overhead. The maximum length with a string32 is bigger than the 1 GiB size limit of buffers.
