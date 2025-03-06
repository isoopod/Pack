"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[552],{51:(e,n,t)=>{t.r(n),t.d(n,{assets:()=>o,contentTitle:()=>l,default:()=>h,frontMatter:()=>r,metadata:()=>i,toc:()=>d});const i=JSON.parse('{"id":"Datatypes/Primitives","title":"Primitive Datatypes","description":"In Pack, a primitive datatype refers to datatypes that contain only their own data. By this definition, Datatypes like Vector3 are treated as primitives, where they might normally be called compount datatypes or aggregate datatypes.","source":"@site/docs/Datatypes/Primitives.md","sourceDirName":"Datatypes","slug":"/Datatypes/Primitives","permalink":"/Pack/docs/Datatypes/Primitives","draft":false,"unlisted":false,"editUrl":"https://github.com/isoopod/Pack/edit/master/docs/Datatypes/Primitives.md","tags":[],"version":"current","sidebarPosition":1,"frontMatter":{"sidebar_position":1},"sidebar":"defaultSidebar","previous":{"title":"Installation","permalink":"/Pack/docs/Installation"},"next":{"title":"Structural Datatypes","permalink":"/Pack/docs/Datatypes/Structures"}}');var s=t(4848),a=t(8453);const r={sidebar_position:1},l="Primitive Datatypes",o={},d=[{value:"BitField",id:"bitfield",level:2},{value:"boolean",id:"boolean",level:2},{value:"BrickColor",id:"brickcolor",level:2},{value:"buffer_fixed",id:"buffer_fixed",level:2},{value:"buffer8",id:"buffer8",level:2},{value:"buffer16",id:"buffer16",level:2},{value:"buffer32",id:"buffer32",level:2},{value:"CFrame",id:"cframe",level:2},{value:"Color3",id:"color3",level:2},{value:"Color3float32",id:"color3float32",level:2},{value:"DateTime",id:"datetime",level:2},{value:"EnumItem",id:"enumitem",level:2},{value:"float32",id:"float32",level:2},{value:"float64",id:"float64",level:2},{value:"Instance",id:"instance",level:2},{value:"int8",id:"int8",level:2},{value:"int16",id:"int16",level:2},{value:"int32",id:"int32",level:2},{value:"null",id:"null",level:2},{value:"object",id:"object",level:2},{value:"Region3",id:"region3",level:2},{value:"Region3int16",id:"region3int16",level:2},{value:"string_fixed",id:"string_fixed",level:2},{value:"string8",id:"string8",level:2},{value:"string16",id:"string16",level:2},{value:"string32",id:"string32",level:2},{value:"UDim",id:"udim",level:2},{value:"UDim2",id:"udim2",level:2},{value:"uint8",id:"uint8",level:2},{value:"uint16",id:"uint16",level:2},{value:"uint32",id:"uint32",level:2},{value:"Vector2",id:"vector2",level:2},{value:"Vector2int16",id:"vector2int16",level:2},{value:"Vector3",id:"vector3",level:2},{value:"Vector3int16",id:"vector3int16",level:2}];function c(e){const n={a:"a",admonition:"admonition",br:"br",code:"code",h1:"h1",h2:"h2",header:"header",p:"p",pre:"pre",strong:"strong",...(0,a.R)(),...e.components};return(0,s.jsxs)(s.Fragment,{children:[(0,s.jsx)(n.header,{children:(0,s.jsx)(n.h1,{id:"primitive-datatypes",children:"Primitive Datatypes"})}),"\n",(0,s.jsx)(n.p,{children:"In Pack, a primitive datatype refers to datatypes that contain only their own data. By this definition, Datatypes like Vector3 are treated as primitives, where they might normally be called compount datatypes or aggregate datatypes."}),"\n",(0,s.jsx)(n.h2,{id:"bitfield",children:"BitField"}),"\n",(0,s.jsxs)(n.p,{children:["A BitField is a highly compressed array of booleans, using bit packing to fit eight booleans into one byte, instead of the usual one.",(0,s.jsx)(n.br,{}),"\n","To use this datatype, you must pass in a fixed length of how many booleans it is expected to store.",(0,s.jsx)(n.br,{}),"\n","When writing to this datatype, it is in the format of an array of booleans. If the array is shorter than the expected length, the last values will be treated as false.",(0,s.jsx)(n.br,{}),"\n","Reading it will return the array of booleans in the same order."]}),"\n",(0,s.jsx)(n.admonition,{type:"info",children:(0,s.jsxs)(n.p,{children:["You should try to have the defined length as close to a multiple of eight as possible.",(0,s.jsx)(n.br,{}),"\n","If your bitfield length is a mutliple of 8 (including 0) + 1, use a regular boolean for that last bool instead."]})}),"\n",(0,s.jsx)(n.h2,{id:"boolean",children:"boolean"}),"\n",(0,s.jsx)(n.p,{children:"Encodes a true/false value into a single byte."}),"\n",(0,s.jsx)(n.h2,{id:"brickcolor",children:"BrickColor"}),"\n",(0,s.jsx)(n.p,{children:"Encodes a BrickColor value in 2 bytes."}),"\n",(0,s.jsx)(n.h2,{id:"buffer_fixed",children:"buffer_fixed"}),"\n",(0,s.jsxs)(n.p,{children:["buffer_fixed refers a fixed length buffer, where a buffer of a known length will encoded with zero overhead.",(0,s.jsx)(n.br,{}),"\n","The fixed length of the buffer in bytes must be passed in."]}),"\n",(0,s.jsx)(n.h2,{id:"buffer8",children:"buffer8"}),"\n",(0,s.jsx)(n.p,{children:"Encodes a buffer of variable length between 0 and 255 bytes with 1 byte of overhead."}),"\n",(0,s.jsx)(n.h2,{id:"buffer16",children:"buffer16"}),"\n",(0,s.jsx)(n.p,{children:"Encodes a buffer of variable length between 0 and 65,535 bytes with 2 bytes of overhead."}),"\n",(0,s.jsx)(n.h2,{id:"buffer32",children:"buffer32"}),"\n",(0,s.jsx)(n.p,{children:"Encodes a buffer of any length with 4 bytes of overhead. The maximum length with a buffer32 is bigger than the 1 GiB size limit of buffers."}),"\n",(0,s.jsx)(n.h2,{id:"cframe",children:"CFrame"}),"\n",(0,s.jsx)(n.p,{children:"Encodes a CFrame as either 13 or 19 bytes. A standard Vector3 is used for position. Axis-Aligned CFrames are 13 bytes, otherwise for random orientation CFrames they are encoded in 19 bytes using a Quaternion for rotation, with an average percision of 0.00461\xb0 (more than enough)."}),"\n",(0,s.jsx)(n.h2,{id:"color3",children:"Color3"}),"\n",(0,s.jsx)(n.p,{children:"Encodes a Color3 value as standard 24-bit RGB in 3 bytes."}),"\n",(0,s.jsx)(n.admonition,{type:"note",children:(0,s.jsxs)(n.p,{children:["The Color3 Datatype actually uses 32 bit floats to store RGB, meaning sometimes colors will have RGB values above 255.",(0,s.jsx)(n.br,{}),"\n","If this is necessary, use Color3float32 instead"]})}),"\n",(0,s.jsx)(n.h2,{id:"color3float32",children:"Color3float32"}),"\n",(0,s.jsx)(n.p,{children:"Enodes a Color3 value in full using 12 bytes. This is for when you have colors with RGB values above 255."}),"\n",(0,s.jsx)(n.h2,{id:"datetime",children:"DateTime"}),"\n",(0,s.jsx)(n.p,{children:"Encodes a DateTime with millisecond percision using 8 bytes."}),"\n",(0,s.jsx)(n.h2,{id:"enumitem",children:"EnumItem"}),"\n",(0,s.jsxs)(n.p,{children:["Encodes an EnumItem from a provided Roblox Enum using between 1 and 2 bytes.",(0,s.jsx)(n.br,{}),"\n","Some common Enums such as Material and KeyCode use 2 bytes due to how these Enums were set up (they have items with values going past 255)"]}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-lua",children:"-- Pass in which Enum you are using\nPack:DefineSchema(Pack.EnumItem(Enum.KeyCode))\n"})}),"\n",(0,s.jsx)(n.h2,{id:"float32",children:"float32"}),"\n",(0,s.jsx)(n.admonition,{title:"Aliases",type:"note",children:(0,s.jsxs)(n.p,{children:[(0,s.jsx)(n.strong,{children:"Float"})," is an alias for float32 and can be used instead"]})}),"\n",(0,s.jsx)(n.p,{children:"Encodes a 32-bit floating point number with 4 bytes"}),"\n",(0,s.jsx)(n.h2,{id:"float64",children:"float64"}),"\n",(0,s.jsx)(n.admonition,{title:"Aliases",type:"note",children:(0,s.jsxs)(n.p,{children:[(0,s.jsx)(n.strong,{children:"Double"})," is an alias for float64 and can be used instead"]})}),"\n",(0,s.jsx)(n.p,{children:"Enocdes a 64-bit floating point number with 8 bytes. This is the type used by lua numbers. It is also the only numeric type that can be used for UserIds, as those have passed the 32-bit unsigned integer limit."}),"\n",(0,s.jsx)(n.h2,{id:"instance",children:"Instance"}),"\n",(0,s.jsxs)(n.p,{children:["Encodes a reference to an Instance. This will place a UID tag on the instance so it can be located later. This UID is 4 bytes.",(0,s.jsx)(n.br,{}),"\n","Note that the UID tag is not removed, as"]}),"\n",(0,s.jsxs)(n.admonition,{type:"warning",children:[(0,s.jsx)(n.p,{children:"This reference does not persist between server and client"}),(0,s.jsxs)(n.p,{children:[(0,s.jsx)(n.strong,{children:"WRITE UNSAFE"}),(0,s.jsx)(n.br,{}),"\n","Writing a reference to an Instance that does not already have a UID will synchronize the thread"]})]}),"\n",(0,s.jsx)(n.p,{children:"In saving places, references persist between server runtimes."}),"\n",(0,s.jsx)(n.h2,{id:"int8",children:"int8"}),"\n",(0,s.jsx)(n.admonition,{title:"Aliases",type:"note",children:(0,s.jsxs)(n.p,{children:[(0,s.jsx)(n.strong,{children:"Byte"})," is an alias for int8 and can be used instead"]})}),"\n",(0,s.jsxs)(n.p,{children:["Enocdes an 8-bit signed integer in a single byte.",(0,s.jsx)(n.br,{}),"\n","Range: -128 \u2013 127"]}),"\n",(0,s.jsx)(n.h2,{id:"int16",children:"int16"}),"\n",(0,s.jsx)(n.admonition,{title:"Aliases",type:"note",children:(0,s.jsxs)(n.p,{children:[(0,s.jsx)(n.strong,{children:"Short"})," is an alias for int16 and can be used instead"]})}),"\n",(0,s.jsxs)(n.p,{children:["Encodes a 16-bit signed integer in 2 bytes.",(0,s.jsx)(n.br,{}),"\n","Range: -32,768 \u2013 32,767"]}),"\n",(0,s.jsx)(n.h2,{id:"int32",children:"int32"}),"\n",(0,s.jsx)(n.admonition,{title:"Aliases",type:"note",children:(0,s.jsxs)(n.p,{children:[(0,s.jsx)(n.strong,{children:"Int"})," is an alias for int32 and can be used instead"]})}),"\n",(0,s.jsx)(n.p,{children:"Encodes a 32-bit signed integer in 4 bytes.\nRange: -2,147,483,648 \u2013 2,147,483,647"}),"\n",(0,s.jsx)(n.h2,{id:"null",children:"null"}),"\n",(0,s.jsx)(n.p,{children:"Represents nothing, directly uses zero bytes. For use in the Union structure (WIP)"}),"\n",(0,s.jsx)(n.h2,{id:"object",children:"object"}),"\n",(0,s.jsxs)(n.p,{children:["Allows marshalling a lua object by providing the class's metatable, and a ",(0,s.jsx)(n.a,{href:"Structures/#dictionary",children:"Dictionary"})," of members to serialize from the object.",(0,s.jsx)(n.br,{}),"\n","This should work for most common OOP patterns. An example has been provided for the classic lua OOP paradigm."]}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-lua",children:"-- Example Class --\nlocal exampleClass = {}\nexampleClass.__index = exampleClass\n\nfunction exampleClass:SomeMethod(val: number)\n    self.someProperty = val\nend\n\nfunction exampleClass.new(val: number)\n    local self = setmetatable({}, exampleClass)\n\n    self.someProperty = val\n\n    return self\nend\n----\n\n-- Create a schema to marshall exampleClass by providing its metatable \n-- as well as instructions to serialize its properties\nlocal schema = Pack:DefineSchema(Pack.object(getmetatable(exampleClass), Pack.Dictionary({\n    someProperty = Pack.Double\n})))\n----\n\n-- Test it with an object of exampleClass\nlocal exampleObject = exampleClass.new(1)\n\nprint(exampleObject.someProperty) -- >>> 1\nexampleObject:SomeMethod(10)\nprint(exampleObject.someProperty) -- >>> 10\n\nlocal reconstructedObject = schema:Read(schema:Write(exampleObject))\n\nprint(reconstructedObject.someProperty) -- >>> 10\nreconstructedObject:SomeMethod(100)\nprint(reconstructedObject.someProperty) -- >>> 100\n"})}),"\n",(0,s.jsx)(n.h2,{id:"region3",children:"Region3"}),"\n",(0,s.jsx)(n.p,{children:"Encodes a Region3 as a min and max Vector3, giving a total of 24 bytes."}),"\n",(0,s.jsx)(n.h2,{id:"region3int16",children:"Region3int16"}),"\n",(0,s.jsx)(n.p,{children:"Encodes a Region3int16 as a min and max Vector3int16, giving a total of 12 bytes."}),"\n",(0,s.jsx)(n.h2,{id:"string_fixed",children:"string_fixed"}),"\n",(0,s.jsxs)(n.p,{children:["string_fixed refers a fixed length string, where a string of a known length will encoded with zero overhead.",(0,s.jsx)(n.br,{}),"\n","The fixed length of the string in bytes must be passed in."]}),"\n",(0,s.jsx)(n.h2,{id:"string8",children:"string8"}),"\n",(0,s.jsxs)(n.p,{children:["Encodes a string of variable length between 0 and 255 bytes with 1 byte of overhead.",(0,s.jsx)(n.br,{}),"\n","Chars already have a variable length of 1-4, so this can range from 255 chars to 63 chars."]}),"\n",(0,s.jsx)(n.h2,{id:"string16",children:"string16"}),"\n",(0,s.jsx)(n.p,{children:"Encodes a string of variable length between 0 and 65,535 bytes with 2 bytes of overhead.\nChars already have a variable length of 1-4, so this can range from 65,535 chars to 16,383 chars."}),"\n",(0,s.jsx)(n.h2,{id:"string32",children:"string32"}),"\n",(0,s.jsx)(n.p,{children:"Encodes a string of any length with 4 bytes of overhead. The maximum length with a string32 is bigger than the 1 GiB size limit of buffers."}),"\n",(0,s.jsx)(n.h2,{id:"udim",children:"UDim"}),"\n",(0,s.jsxs)(n.p,{children:["Encodes a single UDim as 6 bytes.",(0,s.jsx)(n.br,{}),"\n","We assume the offset will be within the range of a int16. If this is not the case, you will have to send the UDim as a float32 scale and int32 offset."]}),"\n",(0,s.jsx)(n.h2,{id:"udim2",children:"UDim2"}),"\n",(0,s.jsx)(n.p,{children:"Encodes a UDim2 as 12 bytes.\nWe assume the offset will be within the range of a int16. If this is not the case, you will have to send the two UDims as a float32 scale and int32 offset."}),"\n",(0,s.jsx)(n.h2,{id:"uint8",children:"uint8"}),"\n",(0,s.jsx)(n.admonition,{title:"Aliases",type:"note",children:(0,s.jsxs)(n.p,{children:[(0,s.jsx)(n.strong,{children:"UByte"})," is an alias for uint8 and can be used instead"]})}),"\n",(0,s.jsxs)(n.p,{children:["Enocdes an 8-bit unsigned integer in a single byte.",(0,s.jsx)(n.br,{}),"\n","Range: 0 \u2013 255"]}),"\n",(0,s.jsx)(n.h2,{id:"uint16",children:"uint16"}),"\n",(0,s.jsx)(n.admonition,{title:"Aliases",type:"note",children:(0,s.jsxs)(n.p,{children:[(0,s.jsx)(n.strong,{children:"UShort"})," is an alias for uint16 and can be used instead"]})}),"\n",(0,s.jsxs)(n.p,{children:["Encodes a 16-bit unsigned integer in 2 bytes.",(0,s.jsx)(n.br,{}),"\n","Range: 0 \u2013 65,565"]}),"\n",(0,s.jsx)(n.h2,{id:"uint32",children:"uint32"}),"\n",(0,s.jsx)(n.admonition,{title:"Aliases",type:"note",children:(0,s.jsxs)(n.p,{children:[(0,s.jsx)(n.strong,{children:"UInt"})," is an alias for uint32 and can be used instead"]})}),"\n",(0,s.jsx)(n.p,{children:"Encodes a 32-bit unsigned integer in 4 bytes.\nRange: 0 \u2013 4,294,967,295"}),"\n",(0,s.jsx)(n.h2,{id:"vector2",children:"Vector2"}),"\n",(0,s.jsx)(n.p,{children:"Encodes a 2D vector of float32s with 8 bytes."}),"\n",(0,s.jsx)(n.h2,{id:"vector2int16",children:"Vector2int16"}),"\n",(0,s.jsx)(n.p,{children:"Encodes a 2D vector of int16s with 4 bytes."}),"\n",(0,s.jsx)(n.h2,{id:"vector3",children:"Vector3"}),"\n",(0,s.jsxs)(n.p,{children:["Encodes a 3D vector of float32s with 12 bytes.",(0,s.jsx)(n.br,{}),"\n","Compatible with the Roblox Vector3 library and luau vector library.",(0,s.jsx)(n.br,{}),"\n","Will return as a luau vector, but these are interchangeable with the Vector3 library.",(0,s.jsx)(n.br,{}),"\n","(Vector3 methods can be used on vectors and vector library functions can take Vector3s)"]}),"\n",(0,s.jsx)(n.h2,{id:"vector3int16",children:"Vector3int16"}),"\n",(0,s.jsx)(n.p,{children:"Encodes a 3D vector of int16s with 6 bytes."})]})}function h(e={}){const{wrapper:n}={...(0,a.R)(),...e.components};return n?(0,s.jsx)(n,{...e,children:(0,s.jsx)(c,{...e})}):c(e)}},8453:(e,n,t)=>{t.d(n,{R:()=>r,x:()=>l});var i=t(6540);const s={},a=i.createContext(s);function r(e){const n=i.useContext(a);return i.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function l(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(s):e.components||s:r(e.components),i.createElement(a.Provider,{value:n},e.children)}}}]);