--!optimize 2
--!strict

local Bezier = require(script.SimpleBezier)
local EasingFunctions = require(script.SimpleEasingFunctions)
local Types = require(script.Parent.Types)

local Constants = {}
Constants.Bezier = Bezier
Constants.EasingFunctions = EasingFunctions
Constants.Easings = EasingFunctions

Constants.Config = {
	Default = {
		Friction = 26;
		Tension = 170;
	} :: Types.PartialSpringConfiguration;

	Gentle = {
		Friction = 14;
		Tension = 120;
	} :: Types.PartialSpringConfiguration;

	Wobbly = {
		Friction = 12;
		Tension = 180;
	} :: Types.PartialSpringConfiguration;

	Stiff = {
		Friction = 20;
		Tension = 210;
	} :: Types.PartialSpringConfiguration;

	Slow = {
		Friction = 60;
		Tension = 280;
	} :: Types.PartialSpringConfiguration;

	Molasses = {
		Friction = 120;
		Tension = 280;
	} :: Types.PartialSpringConfiguration;

	Snappy = {
		Friction = 20;
		Mass = 0.5;
		Tension = 400;
	} :: Types.PartialSpringConfiguration;
}

export type EasingFunction = Types.EasingFunction

table.freeze(Constants.Config)
return table.freeze(Constants)
