--!optimize 2
--!strict

local RunService = game:GetService("RunService")
local Promise = require(script.Parent.Parent.Promise)
local Signal = require(script.Parent.Parent.Signal)

local Animation = require(script.Parent.Animation)
local AnimationConfiguration = require(script.Parent.AnimationConfiguration)
local FastMerge = require(script.Parent.Utilities.FastMerge)
local Helpers = require(script.Parent.Helpers)
local Types = require(script.Parent.Types)

export type SpringValueProperties = {
	From: number,
	To: number,
	Delay: number?,
	Immediate: boolean?,
	Configuration: AnimationConfiguration.SpringConfiguration?,
	OnChange: nil | (position: Types.AnimatableType) -> (),
}

export type SpringValue = {
	Animation: Animation.Animation,
	DefaultProperties: {Configuration: AnimationConfiguration.SpringConfiguration?, Immediate: boolean},
	OnChange: (position: Types.AnimatableType) -> (),
	OnComplete: Signal.VoidSignal,
	HasAnimated: boolean,
	Key: string?,
	UpdateEvent: typeof(RunService.PostSimulation),

	Start: (self: SpringValue, properties: Types.Properties) -> Promise.Promise,
	Stop: (self: SpringValue) -> (),
	Pause: (self: SpringValue) -> (),
	Advance: (self: SpringValue, deltaTime: number) -> (),
}
type Private = {
	Animation: Animation.Animation,
	Connection: RBXScriptConnection?,
	DefaultProperties: {Configuration: AnimationConfiguration.SpringConfiguration?, Immediate: boolean},
	HasAnimated: boolean,
	Key: string?,
	MemoizedDuration: number,
	OnChange: (position: Types.AnimatableType) -> (),
	OnComplete: Signal.VoidSignal,
	UpdateEvent: typeof(RunService.PostSimulation),

	Start: (self: Private, properties: Types.Properties) -> Promise.Promise,
	Stop: (self: Private) -> (),
	Pause: (self: Private) -> (),
	Advance: (self: Private, deltaTime: number) -> (),

	PrepareNode: (self: Private, properties: Types.Properties) -> {
		From: unknown,
		To: unknown,
	},
}
type Static = {
	ClassName: "SpringValue",
	new: (properties: SpringValueProperties, key: string, updateEvent: Types.PostSimulationLike?) -> SpringValue,
}
type PrivateStatic = Static & {__tostring: (self: SpringValue) -> string}

local SpringValue = {} :: SpringValue & Static
local Private = SpringValue :: Private & PrivateStatic
SpringValue.ClassName = "SpringValue";
(SpringValue :: any).__index = SpringValue

function SpringValue.new(properties, key, updateEvent)
	assert(properties.From or properties.To, "`To` or `From` expected, none passed.")

	return setmetatable({
		Animation = Animation.new(properties, key);
		DefaultProperties = {
			Configuration = properties.Configuration;
			Immediate = if properties.Immediate ~= nil then properties.Immediate else false;
		};

		OnChange = (properties.OnChange or function() end) :: (position: Types.AnimatableType) -> ();
		OnComplete = Signal.new() :: Signal.VoidSignal;
		HasAnimated = false;
		Key = nil :: string?;
		UpdateEvent = (updateEvent or RunService.PostSimulation) :: typeof(RunService.PostSimulation);

		Connection = nil :: RBXScriptConnection?;
		MemoizedDuration = 0;
	}, SpringValue) :: never
end

local function PrepareNode(self: Private, properties: Types.Properties)
	local key = self.Key or ""
	local to = properties.To :: any
	local from = properties.From :: any

	if type(to) == "table" then
		to = to[key]
	end

	if type(from) == "table" then
		from = from[key]
	end

	local range = {From = from, To = to}
	if not self.HasAnimated then
		if properties.Reverse then
			to, from = from, to
		end

		local values = Helpers.GetValuesFromType(from or to)
		--self.Animation = self.Animation or Animation.new(#Values)
		self.Animation.Values = table.clone(values)
		self.Animation.LastPosition = table.clone(values)
		self.OnChange(from or to)
	end

	return range
end
Private.PrepareNode = PrepareNode

local function Update(self: Private, properties: Types.Properties)
	if properties.Default then
		self.DefaultProperties = FastMerge(self.DefaultProperties, Helpers.GetDefaultProperties(properties))
	end

	return Promise.new(function(resolve, _, onCancel)
		if properties.Delay then
			task.wait(properties.Delay)
		end

		if onCancel() then
			return
		end

		local range = PrepareNode(self, properties)
		local from = range.From
		local to = range.To

		if from and not to then
			to = from
		end

		local classAnimation = self.Animation
		classAnimation:MergeProperties(FastMerge(self.DefaultProperties, properties))

		if properties.Reverse then
			classAnimation.ToValues, classAnimation.FromValues = classAnimation.FromValues, classAnimation.ToValues
		end

		self.OnChange = properties.OnChange or self.OnChange

		local reset = if properties.Reset == nil
			then from ~= nil
			else classAnimation.FromValues ~= nil and properties.Reset
		if reset then
			classAnimation.Values = table.clone(classAnimation.FromValues)
			classAnimation.LastPosition = if from then Helpers.GetValuesFromType(from) else classAnimation.LastPosition

			local length = #classAnimation.Velocity0
			classAnimation.Velocity0 = table.create(length, nil)
			classAnimation.LastVelocity = table.create(length, nil)
		end

		classAnimation.ToValues = Helpers.GetValuesFromType(to)
		classAnimation.FromValues = table.clone(classAnimation.LastPosition)

		if not self.Connection then
			self.Connection = self.UpdateEvent:Connect(function(deltaTime: number)
				self:Advance(deltaTime)
			end)
		end

		self.OnComplete:Wait()
		resolve()
	end)
end

function Private:Start(properties)
	self.HasAnimated = true
	return Update(self, properties)
end

function Private:Stop()
	local connection = self.Connection
	if connection then
		connection:Disconnect()
		self.Connection = nil
	end

	self.Animation:Stop()
end

function Private:Pause()
	local connection = self.Connection
	if connection then
		connection:Disconnect()
		self.Connection = nil
	end
end

-- TODO: REDUCE INDEXING PLEASEEEEEEEEEEEEE
function Private:Advance(deltaTime: number)
	local changed = false
	local idle = true

	local classAnimation = self.Animation
	local configuration = classAnimation.Configuration
	local toValues = classAnimation.ToValues

	for index = 1, #classAnimation.Values do
		if classAnimation.Done[index] then
			continue
		end

		local finished = classAnimation.Immediate
		local position = toValues[index]
		local from = classAnimation.FromValues[index]
		local to = classAnimation.ToValues[index]

		if not finished then
			position = classAnimation.LastPosition[index]
			if configuration.Tension <= 0 then
				classAnimation.Done[index] = true
				continue
			end

			local currentElapsedTime = classAnimation.ElapsedTime[index] + deltaTime
			classAnimation.ElapsedTime[index] = currentElapsedTime

			local currentVelocity0 = classAnimation.Velocity0[index]
			if currentVelocity0 == nil then
				local velocity = configuration.Velocity
				if type(velocity) == "table" then
					currentVelocity0 = velocity[index]
					classAnimation.Velocity0[index] = currentVelocity0
				else
					currentVelocity0 = if to - from > 0 then velocity elseif to - from < 0 then -velocity else 0
					classAnimation.Velocity0[index] = currentVelocity0
				end
			end

			local velocity: number
			local duration = configuration.Duration
			if duration then
				local alpha = 1
				if duration > 0 then
					if self.MemoizedDuration ~= duration then
						self.MemoizedDuration = duration

						local durationProgress = classAnimation.DurationProgress[index]
						if durationProgress > 0 then
							currentElapsedTime = duration * durationProgress + deltaTime
							classAnimation.ElapsedTime[index] = currentElapsedTime
						end
					end

					alpha = math.clamp((configuration.Progress or 0) + currentElapsedTime / self.MemoizedDuration, 0, 1)
					classAnimation.DurationProgress[index] = alpha
				end

				position = from + configuration.EasingFunction(alpha) * (to - from)
				velocity = (position - classAnimation.LastPosition[index]) / deltaTime
				finished = alpha == 1
			else
				velocity = classAnimation.LastVelocity[index] or currentVelocity0

				local precision = math.max(
					configuration.Precision or (if from == to then 0.005 else math.min(1, math.abs(to - from) / 1000)),
					0.0001
				)
				local restVelocity = configuration.RestVelocity or precision / 10

				local bounceFactor = if configuration.Clamp then 0 else configuration.Bounce
				local canBounce = bounceFactor ~= nil

				local isGrowing = if from == to then currentVelocity0 > 0 else from < to
				local totalSteps = deltaTime * 1000 // 2 + 1
				for _ = 0, totalSteps do
					local isMoving = math.abs(velocity) > restVelocity
					if not isMoving then
						finished = math.abs(to - position) <= precision
						if finished then
							break
						end
					end

					if canBounce then
						local isBouncing = position == to or (position > to) == isGrowing
						if isBouncing then
							velocity = -velocity * bounceFactor :: number
							position = to
						end
					end

					local springForce = -configuration.Tension * 0.000001 * (position - to)
					local dampingForce = -configuration.Friction * 0.001 * velocity
					local acceleration = (springForce + dampingForce) / configuration.Mass

					velocity += acceleration
					position += velocity
				end
			end

			classAnimation.LastVelocity[index] = velocity
		end

		if finished then
			position = to
			classAnimation.Done[index] = true
		else
			idle = false
		end

		if classAnimation:SetValue(index, position) then
			changed = true
		end
	end

	if idle then
		self.OnChange(classAnimation:GetValue())
		local connection = self.Connection
		if connection then
			connection:Disconnect()
			self.Connection = nil
		end

		self.Animation:Stop()
		self.OnComplete:Fire()
	elseif changed then
		self.OnChange(classAnimation:GetValue())
	end
end

function Private:__tostring()
	return "ReactSpring.SpringValue"
end

return table.freeze(SpringValue :: Static)
