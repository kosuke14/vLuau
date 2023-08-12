--[[
	vLuau - Similar to vLua but has Fully Luau Support (developed by sus, uploaded with newdever411)

	Luau (lowercase u) is a Custom Lua Language which is developed by Roblox. (similar to Lua 5.1)
	vLuau is a Luau virtual machine written in Luau.

	Update:
		8 12, 2023:
			- Set FIU_DEBUGGING to false in Fiu.
			- Add COVERAGE Opcode handling in Fiu.
			* another update at same day:
			- Set default environment stack level to 2.
			- Fixed luau_load function.
			- Fixed Compile Error containing 'end of file'.
			- More strict checks.
		8 10, 2023: initial release

	WARNING to use vLuau:
		A source of LuauInLuau is pretty BIG, opening it could CRASH your studio.
	
	Usage:
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

	Credits:
		github:RealEthanPlayzDev/LuauInLuau  (Translated fully compiled Luau source to Luau)
		github:TheGreatSageEqualToHeaven/Fiu (  Luau Bytecode Interpreter written in Luau  )
--]]

local Loader = require(script:WaitForChild("Fiu"))
local Compiler = require(script:WaitForChild("LuauInLuau"))

local function ValidLuauBytecode(bytecode)
	return string.unpack(">B", bytecode, 1) == 3
end
function luau_compile(source, chunkname)
	local suc, bytecode = Compiler.Compile(source)
	return suc == true and bytecode or error((chunkname or '@') .. bytecode:sub(2), 0) -- stack level is 0 to make debugging easier
end
function luau_load(bytecode, env)
	assert(ValidLuauBytecode(bytecode), "luau_load: Argument #1 got invalid bytecode (v3 bytecode expected)")
	assert(type(env) == 'table' or env == nil, ("luau_load: Argument #2 got '%s' (table expected)"):format(typeof(env)))
	return Loader.luau_load(bytecode, env or getfenv(2))
end

return setmetatable({
	luau_compile = luau_compile,
	luau_load = luau_load,
	luau_execute = function(source, env, chunkname)
		if ValidLuauBytecode(source) then
			return luau_load(source, env)
		end
		return luau_load(luau_compile(source, chunkname), env or getfenv(2))
	end,
}, {
	__call = function(self, source, env, chunkname)
		return self.luau_execute(source, env or getfenv(2), chunkname)
	end,
})
