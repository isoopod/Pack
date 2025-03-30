"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[898],{4703:(e,a,t)=>{t.r(a),t.d(a,{assets:()=>c,contentTitle:()=>o,default:()=>u,frontMatter:()=>i,metadata:()=>n,toc:()=>l});const n=JSON.parse('{"id":"Datatypes/Structures","title":"Structural Datatypes","description":"In Pack, structural datatypes are types that do not hold their own data, but instead help you organize primitive datatypes.","source":"@site/docs/Datatypes/Structures.md","sourceDirName":"Datatypes","slug":"/Datatypes/Structures","permalink":"/Pack/docs/Datatypes/Structures","draft":false,"unlisted":false,"editUrl":"https://github.com/isoopod/Pack/edit/master/docs/Datatypes/Structures.md","tags":[],"version":"current","sidebarPosition":2,"frontMatter":{"sidebar_position":2},"sidebar":"defaultSidebar","previous":{"title":"Primitive Datatypes","permalink":"/Pack/docs/Datatypes/Primitives"},"next":{"title":"Miscellaneous Datatypes","permalink":"/Pack/docs/Datatypes/Miscellaneous"}}');var r=t(4848),s=t(8453);const i={sidebar_position:2},o="Structural Datatypes",c={},l=[{value:"Array",id:"array",level:2},{value:"Dictionary",id:"dictionary",level:2},{value:"Map",id:"map",level:2},{value:"Nullable",id:"nullable",level:2},{value:"SparseDictionary",id:"sparsedictionary",level:2}];function d(e){const a={br:"br",code:"code",h1:"h1",h2:"h2",header:"header",p:"p",pre:"pre",...(0,s.R)(),...e.components};return(0,r.jsxs)(r.Fragment,{children:[(0,r.jsx)(a.header,{children:(0,r.jsx)(a.h1,{id:"structural-datatypes",children:"Structural Datatypes"})}),"\n",(0,r.jsx)(a.p,{children:"In Pack, structural datatypes are types that do not hold their own data, but instead help you organize primitive datatypes."}),"\n",(0,r.jsx)(a.h2,{id:"array",children:"Array"}),"\n",(0,r.jsxs)(a.p,{children:["An array is an ordered collection of values with the same type.",(0,r.jsx)(a.br,{}),"\n","Arrays are one-based for consistency with lua.",(0,r.jsx)(a.br,{}),"\n","Arrays have two bytes of overhead and can contain a maximum of 65,565 elements."]}),"\n",(0,r.jsx)(a.pre,{children:(0,r.jsx)(a.code,{className:"language-lua",children:"Pack:DefineSchema(Pack.Array(Pack.Vector3))\n"})}),"\n",(0,r.jsx)(a.h2,{id:"dictionary",children:"Dictionary"}),"\n",(0,r.jsxs)(a.p,{children:["A Pack Dictionary refers to a table with predefined keys.",(0,r.jsx)(a.br,{}),"\n","This is sometimes called a struct in similar libraries.",(0,r.jsx)(a.br,{}),"\n","Dictionaries add no overhead."]}),"\n",(0,r.jsx)(a.pre,{children:(0,r.jsx)(a.code,{className:"language-lua",children:"Pack:DefineSchema(Pack.Dictionary({\n    -- Doesn't matter which way you assign string keys\n    [\"A\"] = Pack.Float64,\n    B = Pack.Float32,\n    -- You aren't limited to just strings as the key.\n    -- Beware that using non-string keys may break the typing, and explicit type annotation may not be able to fix it.\n    [0] = Pack.CFrame,\n    -- You can nest Dictionaries and use other structural datatypes inside a dictionary\n    Nested = Pack.Dictionary({\n        A = Pack.String16,\n    }),\n}))\n"})}),"\n",(0,r.jsx)(a.h2,{id:"map",children:"Map"}),"\n",(0,r.jsxs)(a.p,{children:["A Map is a mapping of some type of key to some type of value.",(0,r.jsx)(a.br,{}),"\n","This is very useful when used with the Union or any datatypes (WIP).",(0,r.jsx)(a.br,{}),"\n","Maps have two bytes of overhead to store the number of elements they contain."]}),"\n",(0,r.jsx)(a.pre,{children:(0,r.jsx)(a.code,{className:"language-lua",children:"-- Represents a table with string keys and Vector3 values\nPack:DefineSchema(Pack.Map(Pack.string8, Pack.Vector3))\n"})}),"\n",(0,r.jsx)(a.h2,{id:"nullable",children:"Nullable"}),"\n",(0,r.jsx)(a.p,{children:"The Nullable datatype indicates the value is optional and may be nil. This adds 1 byte of overhead for every nullable value."}),"\n",(0,r.jsx)(a.pre,{children:(0,r.jsx)(a.code,{className:"language-lua",children:"-- A packet from this schema could be 1 bytes long or 13 bytes long, depending if the Vector3 was passed in or not.\nPack:DefineSchema(Pack.Nullable(Pack.Vector3))\n"})}),"\n",(0,r.jsx)(a.h2,{id:"sparsedictionary",children:"SparseDictionary"}),"\n",(0,r.jsxs)(a.p,{children:["A Pack SparseDictionary refers to a table with predefined keys, each of which are optional.",(0,r.jsx)(a.br,{}),"\n","The second argument is for requried keys, which functions like a regular Dictionary.",(0,r.jsx)(a.br,{}),"\n","SparseDictionaries have the overhead of a BitField for all optional keys."]}),"\n",(0,r.jsx)(a.pre,{children:(0,r.jsx)(a.code,{className:"language-lua",children:"Pack:DefineSchema(Pack.SparseDictionary({\n    -- Optional keys\n    CFrame = Pack.CFrame,\n    Velocity = Pack.Vector3,\n    -- Do not do:\n    opt = Pack.Nullable(Pack.CFrame)\n    -- All keys in the optional table are already nullable\n}))\n"})})]})}function u(e={}){const{wrapper:a}={...(0,s.R)(),...e.components};return a?(0,r.jsx)(a,{...e,children:(0,r.jsx)(d,{...e})}):d(e)}},8453:(e,a,t)=>{t.d(a,{R:()=>i,x:()=>o});var n=t(6540);const r={},s=n.createContext(r);function i(e){const a=n.useContext(s);return n.useMemo((function(){return"function"==typeof e?e(a):{...a,...e}}),[a,e])}function o(e){let a;return a=e.disableParentContext?"function"==typeof e.components?e.components(r):e.components||r:i(e.components),n.createElement(s.Provider,{value:a},e.children)}}}]);