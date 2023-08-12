# vLuau
vLuau is a Luau VM with compiler which can be ran in Roblox.<br>
Like vLua but with Fully Luau Support.
## Credits
- [vLuau](https://github.com/kosuke14/vLuau) - [me (sussy person / sukru / kosuke14 / reboy)](https://github.com/kosuke14)
- [Fiu](https://github.com/TheGreatSageEqualToHeaven/Fiu) (Luau v3 Bytecode Interpreter) - [TheGreatSageEqualToHeaven](https://github.com/TheGreatSageEqualToHeaven) and [Rerumu](https://github.com/Rerumu)
- [LuauInLuau](https://github.com/RealEthanPlayzDev/LuauInLuau) (Translated compiled Luau source to Luau) - [RealEthanPlayzDev](https://github.com/RealEthanPlayzDev) and [Rerumu](https://github.com/Rerumu)
## Usage
```lua
local loadstring = require(path.to.MainModule) -- requiring vLuau MainModule

loadstring(<string:(source or bytecode)>[, table:env, string:chunkname]): function
-- compile code and build function
loadstring.luau_execute(...)
-- same as above

loadstring.luau_compile(<string:source>[, string:chunkname]): string
-- compile code and return bytecode

loadstring.luau_load(<string:bytecode>[, table:env]): function
-- build function with provided compiled bytecode

-- Examples:
loadstring("print('hello world!')", getfenv(0))()
-- (OUTPUT) hello world!
loadstring("a", nil, 'syntaxTest')()
-- (ERROR) syntaxTest:1: Incomplete statement: expected assignment or a function call
```
Roblox Model is available at [vLuau (lowercase u)](https://www.roblox.com/library/14382140693)
## Building
1. Go [LuauInLuau](https://github.com/RealEthanPlayzDev/LuauInLuau) and build them with latest Luau (currently, v4 format is not supported)
2. Replace LuauInLuau.luau with the built version.
3. Place Instances in Roblox like this:
```
├── <ModuleScript> MainModule (init.lua)
|   ├── <ModuleScript> LuauInLuau (LuauInLuau.luau)
└── ├── <ModuleScript> Fiu (Fiu.luau)
```
