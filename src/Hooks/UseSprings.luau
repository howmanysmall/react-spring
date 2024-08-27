--!optimize 2
--!strict

local Promise = require(script.Parent.Parent.Parent.Promise)
local React = require(script.Parent.Parent.Parent.React)

local Controller = require(script.Parent.Parent.Controller)
local FastMerge = require(script.Parent.Parent.Utilities.FastMerge)
local Types = require(script.Parent.Parent.Types)

type ControllerProperties<T> = Controller.ControllerProperties<T>
export type UseSpringsStylesList = {{[string]: React.Binding<any>}}
export type UseSpringsApi<T> = {
	Pause: (keys: {string}?) -> (),
	Start: (callback: (index: number) -> ControllerProperties<T>) -> Promise.Promise,
	Stop: (keys: {string}?) -> (),
}

local Hooks = {
	UseRef = React.useRef :: <T>(initialValue: T) -> {current: T};
}

type UseSpringsDeclarative = <T>(length: number, properties: {T}, dependencies: {unknown}?) -> UseSpringsStylesList
type UseSpringsImperative = <T>(
	length: number,
	properties: (Index: number) -> ControllerProperties<T>,
	dependencies: {unknown}?
) -> (UseSpringsStylesList, UseSpringsApi<T>)

export type UseSprings = UseSpringsDeclarative & UseSpringsImperative

local function UseSprings<T>(
	length: number,
	properties: {ControllerProperties<T> | (index: number) -> ControllerProperties<T>},
	dependencies: {unknown}?
): any
	local isImperative = Hooks.UseRef(nil :: boolean?)
	local controls = Hooks.UseRef({} :: {[number]: Controller.ControllerApi}).current
	local useSpringsStylesList = Hooks.UseRef({} :: UseSpringsStylesList).current
	local apiList = Hooks.UseRef({} :: {{[string]: UseSpringsApi<Types.AnimatableType>}}).current

	if type(properties) == "table" then
		assert(
			not isImperative.current,
			"UseSprings detected a change from imperative to declarative. This is not supported."
		)

		isImperative.current = false
	elseif type(properties) == "function" then
		assert(
			isImperative.current == nil or isImperative.current == true,
			"UseSprings detected a change from declarative to imperative. This is not supported."
		)

		isImperative.current = true
	else
		error(`Expected table or function for UseSprings, got {typeof(properties)}`)
	end

	local function startEffect()
		if isImperative.current == false and type(properties) == "table" then
			for index, spring in controls do
				local startProperties = FastMerge(properties[index], {
					Reset = not not (properties[index] :: any).Reset;
				})

				spring:Start(FastMerge({Default = true}, startProperties))
			end
		end
	end
	React.useEffect(startEffect, dependencies)

	React.useMemo(function()
		if length > #controls then
			for index = #controls + 1, length do
				local styles, api = Controller.new(
					(
							if type(properties) == "table" then properties[index] else properties(index)
						) :: ControllerProperties<any>
				)

				controls[index] = api :: never
				useSpringsStylesList[index] = styles
			end
		else
			for index = length + 1, #controls do
				controls[index]:Stop()
				controls[index] = nil

				useSpringsStylesList[index] = nil
				apiList[index] = nil
			end
		end
	end, {length})

	React.useMemo(function()
		if isImperative.current then
			if #controls > 0 then
				for apiName, value in getmetatable(controls[1] :: never) do
					if type(value) == "function" and apiName ~= "new" then
						apiList[apiName] = function(apiProperties: any | (index: number) -> any)
							local promises: {Promise.Promise} = {}
							local localLength = 0

							for index, spring in controls do
								localLength += 1
								promises[localLength] = Promise.new(function(resolve)
									local result = spring[apiName](
										spring,
										if type(apiProperties) == "function"
											then (apiProperties :: any)(index)
											else apiProperties
									)
									if result and result.await then
										result:await()
									end

									resolve()
								end)
							end

							return Promise.all(promises)
						end :: never
					end
				end
			end
		end
	end, dependencies or {{}})

	local function stopEffect()
		return function()
			for _, controller in controls do
				controller:Stop()
			end
		end
	end
	React.useEffect(stopEffect, {})

	if isImperative.current then
		return useSpringsStylesList, apiList
	end

	return useSpringsStylesList
end

return (UseSprings :: never) :: UseSprings
