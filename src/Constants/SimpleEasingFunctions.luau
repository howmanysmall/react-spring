--!native
--!optimize 2
--!strict

local Bezier = require(script.Parent.SimpleBezier)

local PI = math.pi
local HALF_PI = PI / 2

local function RevBack(alpha: number)
	alpha = 1 - alpha
	return 1 - (math.sin(alpha * HALF_PI) + (math.sin(alpha * PI) * (math.cos(alpha * PI) + 1) / 2))
end

local function Linear(alpha: number)
	return alpha
end

-- @specs https://material.io/guidelines/motion/duration-easing.html#duration-easing-natural-easing-curves
local Sharp = Bezier(0.4, 0, 0.6, 1)
local Standard = Bezier(0.4, 0, 0.2, 1) -- used for moving.
local Acceleration = Bezier(0.4, 0, 1, 1) -- used for exiting.
local Deceleration = Bezier(0, 0, 0.2, 1) -- used for entering.

-- @specs https://developer.microsoft.com/en-us/fabric#/styles/web/motion#basic-animations
local FabricStandard = Bezier(0.8, 0, 0.2, 1) -- used for moving.
local FabricAccelerate = Bezier(0.9, 0.1, 1, 0.2) -- used for exiting.
local FabricDecelerate = Bezier(0.1, 0.9, 0.2, 1) -- used for entering.

-- @specs https://docs.microsoft.com/en-us/windows/uwp/design/motion/timing-and-easing
local UWPAccelerate = Bezier(0.7, 0, 1, 0.5)

-- @specs https://www.ibm.com/design/language/elements/motion/basics

-- Productivity and Expression are both essential to an interface. Reserve Expressive motion for occasional, important moments to better capture user’s attention, and offer rhythmic break to the productive experience.
-- Use standard-easing when an element is visible from the beginning to end of a motion. Tiles expanding and table rows sorting are good examples.
local StandardProductive = Bezier(0.2, 0, 0.38, 0.9)
local StandardExpressive = Bezier(0.4, 0.14, 0.3, 1)

-- Use entrance-easing when adding elements to the view such as a modal or toaster appearing, or moving in response to users’ input, such as dropdown opening or toggle. An element quickly appears and slows down to a stop.
local EntranceProductive = Bezier(0, 0, 0.38, 0.9)
local EntranceExpressive = Bezier(0, 0, 0.3, 1)

-- Use exit-easing when removing elements from view, such as closing a modal or toaster. The element speeds up as it exits from view, implying that its departure from the screen is permanent.
local ExitProductive = Bezier(0.2, 0, 1, 0.9)
local ExitExpressive = Bezier(0.4, 0.14, 1, 1)

-- @specs https://design.firefox.com/photon/motion/duration-and-easing.html
local MozillaCurve = Bezier(0.07, 0.95, 0, 1)

-- @specs https://vanillaframework.io/docs/settings/animation-settings
local VanillaOut = Bezier(0.215, 0.61, 0.355, 1)
local VanillaIn = Bezier(0.55, 0.055, 0.675, 0.19)

local function Smooth(alpha: number)
	return alpha * alpha * (3 - 2 * alpha)
end

local function Smoother(alpha: number)
	return alpha * alpha * alpha * (alpha * (6 * alpha - 15) + 10)
end

local function RidiculousWiggle(alpha: number)
	return math.sin(math.sin(alpha * PI) * HALF_PI)
end

local function Spring(alpha: number)
	return 1 + (-math.exp(-6.9 * alpha) * math.cos(-20.106192982975 * alpha))
end

local function SoftSpring(alpha: number)
	return 1 + (-math.exp(-7.5 * alpha) * math.cos(-10.053096491487 * alpha))
end

local function OutBounce(alpha: number): number
	if alpha < 1 / 2.75 then
		return 7.5625 * alpha * alpha
	elseif alpha < 2 / 2.75 then
		alpha -= 1.5 / 2.75
		return 7.5625 * alpha * alpha + 0.75
	elseif alpha < 2.5 / 2.75 then
		alpha -= 2.25 / 2.75
		return 7.5625 * alpha * alpha + 0.9375
	else
		alpha -= 2.625 / 2.75
		return 7.5625 * alpha * alpha + 0.984375
	end
end

local function InBounce(alpha: number): number
	if alpha > 0.63636363636364 then
		alpha -= 1
		return 1 - alpha * alpha * 7.5625
	end

	if alpha > 0.272727272727273 then
		return (11 * alpha - 7) * (11 * alpha - 3) / -16
	end

	if alpha > 0.090909090909091 then
		return (11 * (4 - 11 * alpha) * alpha - 3) / 16
	end

	return alpha * (11 * alpha - 1) * -0.6875
end

local EasingFunctions = {
	InLinear = Linear;
	OutLinear = Linear;
	InOutLinear = Linear;
	OutInLinear = Linear;
	Linear = Linear;

	VanillaOut = VanillaOut;
	VanillaIn = VanillaIn;
	VanillaInOut = function(alpha: number)
		alpha *= 2
		return if alpha < 1 then VanillaIn(alpha) / 2 else VanillaOut(alpha) / 2
	end;
	VanillaOutIn = function(alpha: number)
		alpha *= 2
		return if alpha < 1 then VanillaOut(alpha) / 2 else VanillaIn(alpha) / 2
	end;

	OutSmooth = Smooth;
	InSmooth = Smooth;
	InOutSmooth = Smooth;
	OutInSmooth = Smooth;
	Smooth = Smooth;

	OutSmoother = Smoother;
	InSmoother = Smoother;
	InOutSmoother = Smoother;
	OutInSmoother = Smoother;
	Smoother = Smoother;

	OutRidiculousWiggle = RidiculousWiggle;
	InRidiculousWiggle = RidiculousWiggle;
	InOutRidiculousWiggle = RidiculousWiggle;
	OutInRidiculousWiggle = RidiculousWiggle;
	RidiculousWiggle = RidiculousWiggle;

	OutRevBack = RevBack;
	InRevBack = RevBack;
	InOutRevBack = RevBack;
	OutInRevBack = RevBack;
	RevBack = RevBack;

	OutSpring = Spring;
	InSpring = Spring;
	InOutSpring = Spring;
	OutInSpring = Spring;
	Spring = Spring;

	OutSoftSpring = SoftSpring;
	InSoftSpring = SoftSpring;
	InOutSoftSpring = SoftSpring;
	OutInSoftSpring = SoftSpring;
	SoftSpring = SoftSpring;

	InSharp = Sharp;
	InOutSharp = Sharp;
	OutSharp = Sharp;
	OutInSharp = Sharp;
	Sharp = Sharp;

	InAcceleration = Acceleration;
	InOutAcceleration = Acceleration;
	OutAcceleration = Acceleration;
	OutInAcceleration = Acceleration;
	Acceleration = Acceleration;

	InStandard = Standard;
	InOutStandard = Standard;
	OutStandard = Standard;
	OutInStandard = Standard;
	Standard = Standard;

	InDeceleration = Deceleration;
	InOutDeceleration = Deceleration;
	OutDeceleration = Deceleration;
	OutInDeceleration = Deceleration;
	Deceleration = Deceleration;

	InFabricStandard = FabricStandard;
	InOutFabricStandard = FabricStandard;
	OutFabricStandard = FabricStandard;
	OutInFabricStandard = FabricStandard;
	FabricStandard = FabricStandard;

	InFabricAccelerate = FabricAccelerate;
	InOutFabricAccelerate = FabricAccelerate;
	OutFabricAccelerate = FabricAccelerate;
	OutInFabricAccelerate = FabricAccelerate;
	FabricAccelerate = FabricAccelerate;

	InFabricDecelerate = FabricDecelerate;
	InOutFabricDecelerate = FabricDecelerate;
	OutFabricDecelerate = FabricDecelerate;
	OutInFabricDecelerate = FabricDecelerate;
	FabricDecelerate = FabricDecelerate;

	InUWPAccelerate = UWPAccelerate;
	InOutUWPAccelerate = UWPAccelerate;
	OutUWPAccelerate = UWPAccelerate;
	OutInUWPAccelerate = UWPAccelerate;
	UWPAccelerate = UWPAccelerate;

	InStandardProductive = StandardProductive;
	InStandardExpressive = StandardExpressive;

	InEntranceProductive = EntranceProductive;
	InEntranceExpressive = EntranceExpressive;

	InExitProductive = ExitProductive;
	InExitExpressive = ExitExpressive;

	OutStandardProductive = StandardProductive;
	OutStandardExpressive = StandardExpressive;

	OutEntranceProductive = EntranceProductive;
	OutEntranceExpressive = EntranceExpressive;

	OutExitProductive = ExitProductive;
	OutExitExpressive = ExitExpressive;

	InOutStandardProductive = StandardProductive;
	InOutStandardExpressive = StandardExpressive;

	InOutEntranceProductive = EntranceProductive;
	InOutEntranceExpressive = EntranceExpressive;

	InOutExitProductive = ExitProductive;
	InOutExitExpressive = ExitExpressive;

	OutInStandardProductive = StandardProductive;
	OutInStandardExpressive = StandardProductive;

	OutInEntranceProductive = EntranceProductive;
	OutInEntranceExpressive = EntranceExpressive;

	OutInExitProductive = ExitProductive;
	OutInExitExpressive = ExitExpressive;

	EntranceExpressive = EntranceExpressive;
	EntranceProductive = EntranceProductive;
	ExitExpressive = ExitExpressive;
	ExitProductive = ExitProductive;
	StandardExpressive = StandardExpressive;
	StandardProductive = StandardProductive;

	OutMozillaCurve = MozillaCurve;
	InMozillaCurve = MozillaCurve;
	InOutMozillaCurve = MozillaCurve;
	OutInMozillaCurve = MozillaCurve;
	MozillaCurve = MozillaCurve;

	InQuad = function(alpha: number)
		return alpha * alpha
	end;

	OutQuad = function(alpha: number)
		return alpha * (2 - alpha)
	end;

	InOutQuad = function(alpha: number)
		return if alpha < 0.5 then 2 * alpha * alpha else 2 * (2 - alpha) * alpha - 1
	end;

	OutInQuad = function(alpha: number)
		if alpha < 0.5 then
			alpha *= 2
			return alpha * (2 - alpha) / 2
		end

		alpha = alpha * 2 - 1
		return alpha * alpha / 2 + 0.5
	end;

	InCubic = function(alpha: number)
		return alpha * alpha * alpha
	end;

	OutCubic = function(alpha: number)
		local OneSubalpha = 1 - alpha
		return 1 - OneSubalpha * OneSubalpha * OneSubalpha
	end;

	InOutCubic = function(alpha: number)
		if alpha < 0.5 then
			return 4 * alpha * alpha * alpha
		end

		alpha -= 1
		return 1 + 4 * alpha * alpha * alpha
	end;

	OutInCubic = function(alpha: number)
		if alpha < 0.5 then
			alpha = 1 - alpha * 2
			return (1 - alpha * alpha * alpha) / 2
		end

		alpha = alpha * 2 - 1
		return alpha * alpha * alpha / 2 + 0.5
	end;

	InQuart = function(alpha: number)
		return alpha * alpha * alpha * alpha
	end;

	OutQuart = function(alpha: number)
		alpha -= 1
		return 1 - alpha * alpha * alpha * alpha
	end;

	InOutQuart = function(alpha: number)
		if alpha < 0.5 then
			alpha *= alpha
			return 8 * alpha * alpha
		end

		alpha -= 1
		return 1 - 8 * alpha * alpha * alpha * alpha
	end;

	OutInQuart = function(alpha: number)
		if alpha < 0.5 then
			alpha = alpha * 2 - 1
			return (1 - alpha * alpha * alpha * alpha) / 2
		end

		alpha = alpha * 2 - 1
		return alpha * alpha * alpha * alpha / 2 + 0.5
	end;

	InQuint = function(alpha: number)
		return alpha * alpha * alpha * alpha * alpha
	end;

	OutQuint = function(alpha: number)
		alpha -= 1
		return alpha * alpha * alpha * alpha * alpha + 1
	end;

	InOutQuint = function(alpha: number)
		if alpha < 0.5 then
			return 16 * alpha * alpha * alpha * alpha * alpha
		end

		alpha -= 1
		return 16 * alpha * alpha * alpha * alpha * alpha + 1
	end;

	OutInQuint = function(alpha: number)
		if alpha < 0.5 then
			alpha = alpha * 2 - 1
			return (alpha * alpha * alpha * alpha * alpha + 1) / 2
		end

		alpha = alpha * 2 - 1
		return alpha * alpha * alpha * alpha * alpha / 2 + 0.5
	end;

	InBack = function(alpha: number)
		return alpha * alpha * (3 * alpha - 2)
	end;

	OutBack = function(alpha: number)
		local alphaSubOne = alpha - 1
		return alphaSubOne * alphaSubOne * (alpha * 2 + alphaSubOne) + 1
	end;

	InOutBack = function(alpha: number)
		if alpha < 0.5 then
			return 2 * alpha * alpha * (2 * 3 * alpha - 2)
		end

		local alphaSubOne = alpha - 1
		return 1 + 2 * alphaSubOne * alphaSubOne * (2 * 3 * alpha - 2 - 2)
	end;

	OutInBack = function(alpha: number)
		if alpha < 0.5 then
			alpha *= 2
			local alphaSubOne = alpha - 1
			return (alphaSubOne * alphaSubOne * (alpha * 2 + alphaSubOne) + 1) / 2
		end

		alpha = alpha * 2 - 1
		return alpha * alpha * (3 * alpha - 2) / 2 + 0.5
	end;

	InSine = function(alpha: number)
		return 1 - math.cos(alpha * HALF_PI)
	end;

	OutSine = function(alpha: number)
		return math.sin(alpha * HALF_PI)
	end;

	InOutSine = function(alpha: number)
		return (1 - math.cos(PI * alpha)) / 2
	end;

	OutInSine = function(alpha: number)
		return if alpha < 0.5 then math.sin(alpha * PI) / 2 else (1 - math.cos((alpha * 2 - 1) * HALF_PI)) / 2 + 0.5
	end;

	OutBounce = OutBounce;
	InBounce = InBounce;

	InOutBounce = function(alpha: number)
		return if alpha < 0.5 then InBounce(2 * alpha) / 2 else OutBounce(2 * alpha - 1) / 2 + 0.5
	end;

	OutInBounce = function(alpha: number)
		return if alpha < 0.5 then OutBounce(2 * alpha) / 2 else InBounce(2 * alpha - 1) / 2 + 0.5
	end;

	InElastic = function(alpha: number)
		return math.exp((alpha * 0.96380736418812 - 1) * 8)
			* alpha
			* 0.96380736418812
			* math.sin(4 * alpha * 0.96380736418812)
			* 1.8752275007429
	end;

	OutElastic = function(alpha: number)
		return 1
			+ (
					math.exp(8 * (0.96380736418812 - 0.96380736418812 * alpha - 1))
					* 0.96380736418812
					* (alpha - 1)
					* math.sin(4 * 0.96380736418812 * (1 - alpha))
				)
				* 1.8752275007429
	end;

	InOutElastic = function(alpha: number)
		return if alpha < 0.5
			then (math.exp(8 * (2 * 0.96380736418812 * alpha - 1)) * 0.96380736418812 * alpha * math.sin(
				2 * 4 * 0.96380736418812 * alpha
			)) * 1.8752275007429
			else 1
				+ (
						math.exp(8 * (0.96380736418812 * (2 - 2 * alpha) - 1))
						* 0.96380736418812
						* (alpha - 1)
						* math.sin(4 * 0.96380736418812 * (2 - 2 * alpha))
					)
					* 1.8752275007429
	end;

	OutInElastic = function(alpha: number)
		-- This isn't actually correct, but it is close enough.
		if alpha < 0.5 then
			alpha *= 2
			return (
				1
				+ (
						math.exp(8 * (0.96380736418812 - 0.96380736418812 * alpha - 1))
						* 0.96380736418812
						* (alpha - 1)
						* math.sin(4 * 0.96380736418812 * (1 - alpha))
					)
					* 1.8752275007429
			) / 2
		end

		alpha = alpha * 2 - 1
		return (
			math.exp((alpha * 0.96380736418812 - 1) * 8)
			* alpha
			* 0.96380736418812
			* math.sin(4 * alpha * 0.96380736418812)
			* 1.8752275007429
		)
				/ 2
			+ 0.5
	end;

	InExpo = function(alpha: number)
		return alpha * alpha * math.exp(4 * (alpha - 1))
	end;

	OutExpo = function(alpha: number)
		return 1 - (1 - alpha) * (1 - alpha) / math.exp(4 * alpha)
	end;

	InOutExpo = function(alpha: number)
		return if alpha < 0.5
			then 2 * alpha * alpha * math.exp(4 * (2 * alpha - 1))
			else 1 - 2 * (alpha - 1) * (alpha - 1) * math.exp(4 * (1 - 2 * alpha))
	end;

	OutInExpo = function(alpha: number)
		if alpha < 0.5 then
			alpha *= 2
			return (1 - (1 - alpha) * (1 - alpha) / math.exp(4 * alpha)) / 2
		end

		alpha = alpha * 2 - 1
		return (alpha * alpha * math.exp(4 * (alpha - 1))) / 2 + 0.5
	end;

	InCirc = function(alpha: number)
		return -(math.sqrt(1 - alpha * alpha) - 1)
	end;

	OutCirc = function(alpha: number)
		alpha -= 1
		return math.sqrt(1 - alpha * alpha)
	end;

	InOutCirc = function(alpha: number)
		alpha *= 2
		if alpha < 1 then
			return -(math.sqrt(1 - alpha * alpha) - 1) / 2
		end

		alpha -= 2
		return (math.sqrt(1 - alpha * alpha) - 1) / 2
	end;

	OutInCirc = function(alpha: number)
		if alpha < 0.5 then
			alpha = alpha * 2 - 1
			return math.sqrt(1 - alpha * alpha) / 2
		end

		alpha = alpha * 2 - 1
		return -(math.sqrt(1 - alpha * alpha) - 1) / 2 + 0.5
	end;
}

return table.freeze(EasingFunctions)
