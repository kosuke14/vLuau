--[[
	vLuau - Similar to vLua but has Fully Luau Support (by sus - GH: kosuke14)

	Luau (lowercase u) is a Custom Lua Language which is developed by Roblox. (similar to Lua 5.1)
	vLuau is a Luau virtual machine written in Luau.

	Update:
		2 02, 2025:
			- Updated Luau to 0.654
			- Using LuauCeption instead of LuauInLuau because of deprecation
		8 14, 2023:
			- Updated Luau to 0.590 (LuauInLuau Custom Build).
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
		A source of LuauCeption is pretty BIG, opening it could CRASH your studio.
	
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
		github:RadiatedExodus/LuauCeption    (   Translated compiled Luau source to Luau   )
		github:TheGreatSageEqualToHeaven/Fiu (  Luau Bytecode Interpreter written in Luau  )
--]]

local Loader = require(script:WaitForChild("Fiu"))
local Ception = require(script:WaitForChild("Ception"))

local function ValidLuauBytecode(bytecode)
	if bytecode:len(bytecode) == 0 then
		return false
	end
	
	local bc = if typeof(bytecode) == 'string' then buffer.fromstring(bytecode) else bytecode
	local luauVersion = buffer.readu8(bc, 0)
	if luauVersion == 0 then
		--error("the provided bytecode is an error message",0)
		return false
	elseif luauVersion < 3 or luauVersion > 6 then
		--error("the version of the provided bytecode is unsupported",0)
		return false
	elseif luauVersion >= 4 then
		return true
	end
	
	return true
end
function luau_compile(source, chunkname)
	local bytecode, _ = Ception.luau_compile(source)
	return bytecode:sub(1, 1) ~= "\0" and bytecode or error((chunkname or '@') .. bytecode:sub(2), 0) -- stack level is 0 to make debugging easier
end
function luau_load(bytecode, env)
	assert(ValidLuauBytecode(bytecode), "luau_load: Argument #1 got invalid bytecode")
	assert(type(env) == 'table' or env == nil, ("luau_load: Argument #2 got '%s' (table expected)"):format(typeof(env)))
	return Loader.luau_load(bytecode, env or getfenv(debug.info(2, 'f')))
end

return setmetatable({
	luau_compile = luau_compile,
	luau_load = luau_load,
	luau_execute = function(source, env, chunkname)
		if ValidLuauBytecode(source) then
			return luau_load(source, env)
		end
		return luau_load(luau_compile(source, chunkname), env or getfenv(debug.info(2, 'f')))
	end,
	create_env = function(envwriter)
		local fenv = getfenv(debug.info(2, 'f'))
		local env = setmetatable({}, {
			__index = function(self,k)
				return envwriter[k] or fenv[k]
			end,
		})
		return env
	end,
}, {
	__call = function(self, source, env, chunkname)
		return self.luau_execute(source, env or getfenv(debug.info(2, 'f')), chunkname)
	end,
})

