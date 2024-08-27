--!optimize 2
--!strict

local Promise = require(script.Parent.Parent.Promise)
local React = require(script.Parent.Parent.React)

local FastMerge = require(script.Parent.Utilities.FastMerge)
local Helpers = require(script.Parent.Helpers)
local SpringValue = require(script.Parent.SpringValue)
local Types = require(script.Parent.Types)

export type ControllerProperties<T = any> = Types.AnimationProperties & ({
	From: T?,
	To: T?,
} | T)
export type ControllerApi = {
	Start: (self: ControllerApi, startProperties: ControllerProperties<Types.AnimationStyle>) -> Promise.Promise,
	Stop: (self: ControllerApi, keys: {string}?) -> Promise.Promise,
	Pause: (self: ControllerApi, keys: {string}?) -> Promise.Promise,
}

export type Controller<T> = {
	Bindings: {[string]: React.Binding<any>},
	Controls: {[string]: SpringValue.SpringValue},

	Start: (self: Controller<T>, startProperties: ControllerProperties<Types.AnimationStyle>) -> Promise.Promise,
	Stop: (self: Controller<T>, keys: {string}?) -> (),
	Pause: (self: Controller<T>, keys: {string}?) -> (),
}
type Static = {
	ClassName: "Controller",
	new: <T>(properties: ControllerProperties<T>) -> ({[string]: React.Binding<any>}, Controller<T>),
}
type PrivateStatic = Static & {__tostring: (self: Controller<never>) -> string}

local Controller = {} :: Controller<never> & Static
local Private = Controller :: Controller<never> & PrivateStatic
Controller.ClassName = "Controller";
(Controller :: any).__index = Controller

function Controller.new<T>(properties): ({[string]: React.Binding<any>}, Controller<T>)
	local self: Controller<T> = setmetatable({
		Bindings = {} :: {[string]: React.Binding<any>},
		Controls = {} :: {[string]: SpringValue.SpringValue},
	}, Controller) :: never
	self:Start(FastMerge({Default = true}, properties))
	return self.Bindings, self
end

local function CreateSpring(properties: ControllerProperties<Types.AnimationStyle>, key: string)
	local spring = SpringValue.new(properties :: any, key)
	local binding, setBinding = React.createBinding(nil :: any)

	spring.Key = key
	spring.OnChange = setBinding

	return spring, binding
end

local function PrepareKeys<T>(self: Controller<T>, properties: {[any]: any})
	local keys: {string} = properties.Keys
	if keys then
		for _, key in keys do
			local spring = self.Controls[key]
			if not spring then
				spring, self.Bindings[key] = CreateSpring(properties, key)
				self.Controls[key] = spring
			end

			(spring :: any):PrepareNode(properties)
		end
	end
end

local function FlushUpdate<T>(self: Controller<T>, properties: {[any]: any})
	local loop = properties.Loop
	properties.Loop = false

	local promises: {Promise.Promise} = {}
	local length = 0

	for _, key in properties.Keys or {} do
		local control = self.Controls[key]
		length += 1
		promises[length] = control:Start(properties)
	end

	return Promise.all(promises):andThen(function()
		if loop then
			local nextProperties = Helpers.CreateLoopUpdate(properties, loop)
			if nextProperties then
				PrepareKeys(self, nextProperties)
				return FlushUpdate(self, nextProperties)
			end
		end
	end)
end

function Controller:Start(startProperties)
	if not startProperties then
		return Promise.new(function(resolve)
			resolve()
		end)
	end

	local properties = Helpers.CreateUpdate(startProperties)
	PrepareKeys(self, properties)
	return FlushUpdate(self, properties)
end

function Controller:Stop(keys)
	if keys then
		for _, key in keys do
			local control = self.Controls[key]
			if control then
				control:Stop()
			else
				warn(`Tried to stop animation at key "{key}", but it doesn't exist.`)
			end
		end
	else
		for _, control in self.Controls do
			control:Stop()
		end
	end
end

function Controller:Pause(keys: {string}?)
	if keys then
		for _, key in keys do
			local control = self.Controls[key]
			if control then
				control:Pause()
			else
				warn(`Tried to pause animation at key "{key}", but it doesn't exist.`)
			end
		end
	else
		for _, control in self.Controls do
			control:Pause()
		end
	end
end

function Private:__tostring()
	return "ReactSpring.Controller"
end

return table.freeze(Controller :: Static)
