--[[
	vLuau - Similar to vLua but has Fully Luau Support (by gh:kosuke14)
	vLuau is a Luau virtual machine written in Luau.

	Example:
	local load = require(workspace.vLuau)
	local success, compileError = pcall(function()
		local loaded = load("print('hello from vLuau!')")
		loaded() -- hello from vLuau!
	end)

	Credits:
		gh:RadiatedExodus/LuauCeption    (   Translated compiled Luau source to Luau   )
		gh:TheGreatSageEqualToHeaven/Fiu (  Luau Bytecode Interpreter written in Luau  )
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

