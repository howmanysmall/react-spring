--!optimize 2
--!strict

local AnimationConfiguration = require(script.Parent.AnimationConfiguration)
local Helpers = require(script.Parent.Helpers)
local Types = require(script.Parent.Types)

export type Animation = {
	Values: {number},
	ToValues: {number},
	FromValues: {number},
	Type: string,

	Configuration: AnimationConfiguration.SpringConfiguration,
	Immediate: boolean?,

	Velocity0: {number},
	LastPosition: {number},
	LastVelocity: {number},
	Done: {boolean},
	ElapsedTime: {number},
	DurationProgress: {number},

	SetValue: (self: Animation, index: number, value: number) -> boolean,
	MergeProperties: (self: Animation, properties: Types.Properties?) -> (),
	GetValue: (self: Animation) -> Types.AnimatableType,
	Stop: (self: Animation) -> (),
}
type Static = {
	ClassName: "Animation",
	new: (properties: Types.Properties, key: string?) -> Animation,
}
type PrivateStatic = Static & {__tostring: (self: Animation) -> string}

local Animation = {} :: Animation & Static
local Private = Animation :: Animation & PrivateStatic
Animation.ClassName = "Animation";
(Animation :: any).__index = Animation

function Animation.new(properties: Types.Properties, key: string?): Animation
	local self = setmetatable({}, Animation)

	local to = properties.To and properties.To[key :: string]
	local from = properties.From and properties.From[key :: string]
	local length = #Helpers.GetValuesFromType(from or to)

	self.Values = Helpers.GetValuesFromType(from or to)
	self.ToValues = Helpers.GetValuesFromType(to or from)
	self.FromValues = Helpers.GetValuesFromType(from or to)
	self.Type = typeof(from or to)

	self.Configuration = AnimationConfiguration.MergeConfiguration(properties.Configuration or {})
	self.Immediate = properties.Immediate :: boolean

	self.Velocity0 = table.create(length, nil) :: {number}
	self.LastPosition = Helpers.GetValuesFromType(from or to)
	self.LastVelocity = table.create(length, nil) :: {number}
	self.Done = table.create(length, false)
	self.ElapsedTime = table.create(length, 0)
	self.DurationProgress = table.create(length, 0)

	return self :: never
end

function Animation:SetValue(index: number, value: number)
	self.LastPosition[index] = value
	local values = self.Values
	if values[index] == value then
		return false
	end

	values[index] = value
	return true
end

function Animation:MergeProperties(properties: Types.Properties?)
	if properties then
		self.Configuration = AnimationConfiguration.MergeConfiguration(properties.Configuration or {})
		self.Immediate = if properties.Immediate ~= nil then properties.Immediate else self.Immediate

		local length = #self.Values
		self.Done = table.create(length, false)
		self.ElapsedTime = table.create(length, 0)
		self.DurationProgress = table.create(length, 0)
	end
end

function Animation:GetValue(): Types.AnimatableType
	return Helpers.GetTypeFromValues(self.Type, self.Values)
end

function Animation:Stop()
	local lastPosition = self.LastPosition
	local lastVelocity = self.LastVelocity
	local values = self.Values
	local velocity0 = self.Velocity0

	local length = #values
	for index, value in values do
		lastPosition[index] = value
		lastVelocity[index] = nil
		velocity0[index] = nil

		self.DurationProgress = table.create(length, 0)
		self.ElapsedTime = table.create(length, 0)
	end
end

function Private:__tostring()
	return "ReactSpring.Animation"
end

return table.freeze(Animation :: Static)
