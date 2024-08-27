--!optimize 2
--!strict

local Constants = require(script.Parent.Constants)
local FastMerge = require(script.Parent.Utilities.FastMerge)
local Types = require(script.Parent.Types)

local AnimationConfiguration = {}

local TAU = math.pi * 2
local DOUBLE_TAU = TAU * 2

export type SpringConfiguration = Types.SpringConfiguration
export type PartialSpringConfiguration = Types.PartialSpringConfiguration

local DEFAULTS: SpringConfiguration = table.freeze(FastMerge(Constants.Config.Default, {
	Mass = 1;
	DampingRatio = 1;
	Clamp = false;
	Velocity = 0;
	EasingFunction = Constants.EasingFunctions.Smoother;
}))

function AnimationConfiguration.MergeConfiguration(configuration: any, newConfiguration: any?)
	local trueConfiguration: SpringConfiguration = if newConfiguration
		then FastMerge(configuration, newConfiguration)
		else table.clone(configuration)
	for key, value in DEFAULTS :: {[string]: any} do
		if trueConfiguration[key] == nil then
			trueConfiguration[key] = value
		end
	end

	local frequency = trueConfiguration.Frequency
	if frequency then
		local mass = trueConfiguration.Mass
		if frequency < 0.01 then
			frequency = 0.01
			trueConfiguration.Frequency = frequency
		end

		local dampingRatio = trueConfiguration.DampingRatio
		if dampingRatio < 0 then
			dampingRatio = 0
			trueConfiguration.DampingRatio = dampingRatio
		end

		trueConfiguration.Tension = (TAU / frequency) ^ 2 * mass
		trueConfiguration.Friction = DOUBLE_TAU * dampingRatio * mass / frequency
	end

	return trueConfiguration
end

return table.freeze(AnimationConfiguration)
