--!optimize 2
--!strict

local FastMerge = require(script.Parent.Utilities.FastMerge)
local GetTypeFromValues = require(script.Parent.Utilities.GetTypeFromValues)
local GetValuesFromType = require(script.Parent.Utilities.GetValuesFromType)
local Types = require(script.Parent.Types)

local Helpers = {}

Helpers.GetValuesFromType = GetValuesFromType
Helpers.GetTypeFromValues = GetTypeFromValues

local DEFAULT_PROPERTIES = table.freeze({"Configuration", "Immediate"})
local RESERVED_PROPERTIES = table.freeze({
	Configuration = true;
	From = true;
	To = true;
	Loop = true;
	Reset = true;
	Immediate = true;
	Default = true;
	Delay = true;

	-- Internal properties
	Keys = true;
})

function Helpers.GetDefaultProperties(properties: Types.Properties)
	local defaults = {}
	for _, key in DEFAULT_PROPERTIES do
		local value = properties[key]
		if value then
			defaults[key] = value
		end
	end

	return defaults
end

local function GetForwardProperties(properties: Types.Properties): Types.Properties?
	local forward = {}
	local count = 0

	for property, value in properties do
		if not RESERVED_PROPERTIES[property] then
			forward[property] = value
			count += 1
		end
	end

	return if count > 0 then forward else nil
end

function Helpers.InferTo(properties: Types.Properties)
	local to = GetForwardProperties(properties)
	if to then
		local out = {To = to}
		for key, value in properties do
			if not to[key] then
				out[key] = value
			end
		end

		return out
	end

	return table.clone(properties)
end

local function FindDefined(values: Types.Properties, keys: {string})
	local length = #keys
	for key, value in values do
		if value and not table.find(keys, key) then
			length += 1
			keys[length] = key
		end
	end
end

function Helpers.CreateUpdate(properties: Types.Properties): Types.Properties
	properties = Helpers.InferTo(properties)
	local keys: {string} = {}

	local to = properties.To
	if type(to) == "table" then
		FindDefined(to, keys)
	end

	local from = properties.From
	if type(from) == "table" then
		FindDefined(from, keys)
	end

	properties.Keys = keys
	return properties
end

function Helpers.CreateLoopUpdate(properties: Types.Properties, loop: unknown?): Types.Properties?
	local trueLoop = if loop ~= nil then loop else properties.Loop

	local continueLoop = true
	if type(trueLoop) == "function" then
		continueLoop = trueLoop()
	end

	if continueLoop then
		local overrides = type(trueLoop) == "table" and trueLoop
		local reset = not overrides or overrides.Reset

		local nextProperties = table.clone(properties)
		nextProperties.Loop = trueLoop
		nextProperties.Default = false
		nextProperties.Pause = nil
		nextProperties.From = reset and properties.From
		nextProperties.Reset = reset

		if type(overrides) == "table" then
			nextProperties = FastMerge(nextProperties, overrides)
		end

		return Helpers.CreateUpdate(nextProperties)
	end

	return nil
end

return table.freeze(Helpers)
