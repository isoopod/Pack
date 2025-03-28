"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[187],{7139:e=>{e.exports=JSON.parse('{"functions":[{"name":"moveCursor","desc":"Manually moves the reader\'s cursor.  \\n:::danger\\nDoes not prevent you from leaving buffer bounds.\\n:::","params":[{"name":"self","desc":"A reader instance created with .new","lua_type":"ReaderData"},{"name":"delta","desc":"How many bytes to move the cursor, can be negative to go backwards","lua_type":"number"}],"returns":[],"function_type":"static","source":{"line":45,"path":"src/Reader.luau"}},{"name":"u8","desc":"Reads an unsigned 8-bit integer from the buffer and moves the cursor forwards 1 byte.","params":[{"name":"self","desc":"A reader instance created with .new","lua_type":"ReaderData"}],"returns":[{"desc":"","lua_type":"number"}],"function_type":"static","source":{"line":57,"path":"src/Reader.luau"}},{"name":"u16","desc":"Reads an unsigned 16-bit integer from the buffer and moves the cursor forwards 2 bytes.","params":[{"name":"self","desc":"A reader instance created with.new","lua_type":"ReaderData"}],"returns":[{"desc":"","lua_type":"number"}],"function_type":"static","source":{"line":70,"path":"src/Reader.luau"}},{"name":"u32","desc":"Reads an unsigned 32-bit integer from the buffer and moves the cursor forwards 4 bytes.","params":[{"name":"self","desc":"A reader instance created with .new","lua_type":"ReaderData"}],"returns":[{"desc":"","lua_type":"number"}],"function_type":"static","source":{"line":83,"path":"src/Reader.luau"}},{"name":"u8","desc":"Reads a signed 8-bit integer from the buffer and moves the cursor forwards 1 byte.","params":[{"name":"self","desc":"A reader instance created with .new","lua_type":"ReaderData"}],"returns":[{"desc":"","lua_type":"number"}],"function_type":"static","source":{"line":96,"path":"src/Reader.luau"}},{"name":"i16","desc":"Reads a signed 16-bit integer from the buffer and moves the cursor forwards 2 bytes.","params":[{"name":"self","desc":"A reader instance created with .new","lua_type":"ReaderData"}],"returns":[{"desc":"","lua_type":"number"}],"function_type":"static","source":{"line":109,"path":"src/Reader.luau"}},{"name":"i32","desc":"Reads a signed 32-bit integer from the buffer and moves the cursor forwards 4 bytes.","params":[{"name":"self","desc":"A reader instance created with .new","lua_type":"ReaderData"}],"returns":[{"desc":"","lua_type":"number"}],"function_type":"static","source":{"line":122,"path":"src/Reader.luau"}},{"name":"nBitUint","desc":"Reads an unsigned integer of length `n` bits\\n:::info\\nThis function does not move the cursor after completing, so you will have to move it yourself with .moveCursor\\n:::","params":[{"name":"self","desc":"A reader instance created with .new","lua_type":"ReaderData"},{"name":"n","desc":"The length in bits of the integer","lua_type":"number"},{"name":"bitOffset","desc":"The bit offset from the current cursor location [0 \u2013 31]","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number"}],"function_type":"static","source":{"line":140,"path":"src/Reader.luau"}},{"name":"nBitInt","desc":"Reads a signed integer of length `n` bits\\n:::info\\nThis function does not move the cursor after completing, so you will have to move it yourself with .moveCursor\\n:::","params":[{"name":"self","desc":"A reader instance created with .new","lua_type":"ReaderData"},{"name":"n","desc":"The length in bits of the integer","lua_type":"number"},{"name":"bitOffset","desc":"The bit offset from the current cursor location [0 \u2013 31]","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number"}],"function_type":"static","source":{"line":156,"path":"src/Reader.luau"}},{"name":"nBitFloat","desc":"Reads a custom signed floating point number with the exponent length `n` bits and mantissa length `m` bits\\n:::info\\nThis function does not move the cursor after completing, so you will have to move it yourself with .moveCursor\\n:::\\n:::warning\\nThe sum of `n` and `m` should not be greater than `31 - bitOffset`.  \\n:::","params":[{"name":"self","desc":"A reader instance created with .new","lua_type":"ReaderData"},{"name":"n","desc":"The length in bits of the floating point\'s exponent","lua_type":"number"},{"name":"m","desc":"The length in bits of the floating point\'s mantissa","lua_type":"number"},{"name":"bitOffset","desc":"The bit offset from the current cursor location [0 \u2013 31]","lua_type":"number"}],"returns":[{"desc":"","lua_type":"number"}],"function_type":"static","source":{"line":180,"path":"src/Reader.luau"}},{"name":"f32","desc":"Reads a 32-bit floating point number from the buffer and moves the cursor forwards 4 bytes.","params":[{"name":"self","desc":"A reader instance created with .new","lua_type":"ReaderData"}],"returns":[{"desc":"","lua_type":"number"}],"function_type":"static","source":{"line":226,"path":"src/Reader.luau"}},{"name":"f64","desc":"Reads a 64-bit floating point number from the buffer and moves the cursor forwards 8 bytes.","params":[{"name":"self","desc":"A reader instance created with .new","lua_type":"ReaderData"}],"returns":[{"desc":"","lua_type":"number"}],"function_type":"static","source":{"line":239,"path":"src/Reader.luau"}},{"name":"string","desc":"Reads a string of length `count` bytes from the buffer and pushes the cursor `count` bytes forwards.","params":[{"name":"self","desc":"A reader instance created with .new","lua_type":"ReaderData"},{"name":"count","desc":"The length of the string in bytes","lua_type":"number"}],"returns":[{"desc":"","lua_type":"string"}],"function_type":"static","source":{"line":253,"path":"src/Reader.luau"}},{"name":"new","desc":"Creates a new reader instance from a written packet","params":[{"name":"packet","desc":"The packet the reader should be reading","lua_type":"buffer"}],"returns":[{"desc":"","lua_type":"ReaderData"}],"function_type":"static","tags":["Constructor"],"source":{"line":268,"path":"src/Reader.luau"}}],"properties":[],"types":[],"name":"Reader","desc":"An internal ordered buffer reader library used to deserialize packets.  \\nA reader instance is created with the .new constructor and modified by the library\'s functions.","source":{"line":13,"path":"src/Reader.luau"}}')}}]);