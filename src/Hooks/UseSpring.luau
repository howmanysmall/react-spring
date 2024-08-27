--!optimize 2
--!strict

local Promise = require(script.Parent.Parent.Parent.Promise)
local React = require(script.Parent.Parent.Parent.React)

local Controller = require(script.Parent.Parent.Controller)
local UseSprings = require(script.Parent.UseSprings)

export type UseSpringApi<T> = {
	Start: (startProperties: Controller.ControllerProperties<T>) -> Promise.Promise,
	Stop: (keys: {string}?) -> (),
	Pause: (keys: {string}?) -> (),
}

type UseSpringDeclarative = <T>(
	properties: Controller.ControllerProperties<T>,
	dependencies: {unknown}?
) -> {[string]: React.Binding<any>}
type UseSpringImperative = <T>(
	properties: () -> Controller.ControllerProperties<T>,
	dependencies: {unknown}?
) -> ({[string]: React.Binding<any>}, UseSpringApi<T>)
type UseSpring = UseSpringDeclarative & UseSpringImperative

local function UseSpring<T>(
	properties: Controller.ControllerProperties<T> | () -> Controller.ControllerProperties<T>,
	dependencies: {unknown}
): any
	if type(properties) == "function" then
		local styles, api = UseSprings(1, properties, dependencies or {})
		return styles[1], api
	end

	local styles = UseSprings(1, {properties}, dependencies)
	return styles[1]
end

return (UseSpring :: never) :: UseSpring
