--!optimize 2
--!strict

local Constants = require(script.Constants)
local Controller = require(script.Controller)

local Parallax = require(script.Parallax)
local ParallaxLayer = require(script.Parallax.ParallaxLayer)

local UseSpring = require(script.Hooks.UseSpring)
local UseSprings = require(script.Hooks.UseSprings)
local UseTrail = require(script.Hooks.UseTrail)

local ParallaxTypes = require(script.Parallax.ParallaxTypes)
local Types = require(script.Types)

export type AnimatableType = Types.AnimatableType
export type AnimationStyle = Types.AnimationStyle
export type AnimationProperties = Types.AnimationProperties

export type UseSpringsApi<T> = UseSprings.UseSpringsApi<T>
export type UseSpringsStylesList = UseSprings.UseSpringsStylesList

export type ControllerApi = Controller.ControllerApi

export type Parallax = ParallaxTypes.Parallax
export type ParallaxLayer = ParallaxTypes.ParallaxLayer

export type SpringConfiguration = Types.SpringConfiguration
export type PartialSpringConfiguration = Types.PartialSpringConfiguration

-- Check out https://react-spring-visualizer.com/
-- Very helpful!
local ReactSpring = table.freeze({
	Bezier = Constants.Bezier;
	Config = Constants.Config;
	Configuration = Constants.Config;
	EasingFunctions = Constants.EasingFunctions;
	Easings = Constants.EasingFunctions;

	Controller = Controller;

	Parallax = Parallax;
	ParallaxLayer = ParallaxLayer;

	UseSpring = UseSpring;
	UseSprings = UseSprings;
	UseTrail = UseTrail;

	useSpring = UseSpring;
	useSprings = UseSprings;
	useTrail = UseTrail;
})

return ReactSpring
