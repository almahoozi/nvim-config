local Repl = {}
Repl.__index = Repl

-- TODO: Move to separate repo
-- TODO: Setup CI and dev env
-- TODO: Maintain state
-- TODO: Write documentation
-- TODO: Write tests

local default_config = {
	Debug = true,
}

--@class Config
--@field Lang string
local Config = {}
Config.__index = Config

--@param values table
--@return Config
function Config:new(values)
	-- TODO: Load and merge defaults
	if not values then
		values = default_config
	end

	return setmetatable({
		Lang = values.Lang,
		Debug = values.Debug,
	}, self)
end

--@return Repl
function Repl:new()
	return setmetatable({}, self)
end

--@param config Config
--@return Repl
function Repl:setup(config)
	if not config then
		config = Config:new(default_config)
	end

	if config.Debug then
		print("Setting up REPL")
		print(vim.inspect(config))
	end

	return self
end

return Repl:new()
