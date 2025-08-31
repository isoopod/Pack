---
sidebar_position: 4
---

# Packets

Pack uses schemas to create packets, and understanding how these work can help design effective schemas.
A packet has two parts, the Buffer and the Bit-Buffer. Most datatypes write to the Buffer in sequential order.

The Buffer writes in bytes, left to right, and the BitBuffer writes in bits, right to left, and is appended onto the end of the Buffer when the Packet is finalized.

Because Pack uses a BitBuffer, the largest amount of unused data in a Packet can be at most 7 bits.

Packets themselves are just buffers, and can be passed around as needed before being read with a compatible Schema. You can use JsonEncode and JsonDecode to serialize and deserialize the Packet into a string format. This also has the benefit of applying Zstd compression before encoding in base64.

WIP.
