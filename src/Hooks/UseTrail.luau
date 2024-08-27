--!optimize 2
--!strict

local React = require(script.Parent.Parent.Parent.React)

local Controller = require(script.Parent.Parent.Controller)
local FastMerge = require(script.Parent.Parent.Utilities.FastMerge)
local UseSprings = require(script.Parent.UseSprings)

type UseTrailProperties<T> = {Controller.ControllerProperties<T>} | ((index: number) -> Controller.ControllerProperties<T>)
local DEFAULT_DELAY = {Delay = 0.1}

local Hooks = {
	UseRef = React.useRef :: <T>(InitialValue: T) -> {current: T};
}

local function UseTrail<T>(length: number, properties: UseTrailProperties<T>, dependencies: {unknown}?): any
	local mergedProperties = React.useMemo(function()
		if type(properties) == "function" then
			return properties
		end

		local newProperties: {Controller.ControllerProperties<T>} = table.create(length)
		local currentDelay = 0
		for index, value in properties do
			local merged = FastMerge(DEFAULT_DELAY, value) :: any
			local delayAmount = merged.Delay
			merged.Delay = currentDelay
			currentDelay += delayAmount
			newProperties[index] = merged
		end

		return newProperties :: any
	end, dependencies or {{}})

	local styles, api: UseSprings.UseSpringsApi<T>? = UseSprings(length, mergedProperties :: any, dependencies)
	local modifiedApi = Hooks.UseRef({} :: UseSprings.UseSpringsApi<T>)

	if type(properties) == "function" and api then
		table.clear(modifiedApi.current)
		modifiedApi.current = table.clone(api :: never)

		function modifiedApi.current.Start(startFunction)
			local currentDelay = 0
			return api.Start(function(index)
				local startProperties = FastMerge(DEFAULT_DELAY, startFunction(index))
				local delay = startProperties.Delay :: number

				startProperties.Delay = currentDelay
				currentDelay += delay
				return startProperties :: any
			end)
		end

		return styles, modifiedApi.current
	end

	return styles
end

return (UseTrail :: never) :: UseSprings.UseSprings
