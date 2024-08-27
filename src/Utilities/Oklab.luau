--!native
--!optimize 2
--!strict

--[[
	Provides functions for converting Color3s into Oklab space, for more
	perceptually uniform colour blending.

	See: https://bottosson.github.io/posts/oklab/
]]

local Oklab = {}

-- Converts a Color3 in RGB space to an array in Oklab space.
function Oklab.To(color: Color3): {number}
	local red = color.R
	local green = color.G
	local blue = color.B

	local long = red * 0.4122214708 + green * 0.5363325363 + blue * 0.0514459929
	local medium = red * 0.2119034982 + green * 0.6806995451 + blue * 0.1073969566
	local short = red * 0.0883024619 + green * 0.2817188376 + blue * 0.6299787005

	local rootLong = long ^ (1 / 3)
	local rootMedium = medium ^ (1 / 3)
	local rootShort = short ^ (1 / 3)

	return {
		rootLong * 0.2104542553 + rootMedium * 0.7936177850 - rootShort * 0.0040720468,
		rootLong * 1.9779984951 - rootMedium * 2.4285922050 + rootShort * 0.4505937099,
		rootLong * 0.0259040371 + rootMedium * 0.7827717662 - rootShort * 0.8086757660,
	}
end

-- Converts an array in CIELAB space to a Color3 in RGB space.
-- The Color3 will be clamped by default unless specified otherwise.
function Oklab.From(array: {number}, unclamped: boolean?): Color3
	local x = array[1]
	local y = array[2]
	local z = array[3]

	local rootLong = x + y * 0.3963377774 + z * 0.2158037573
	local rootMedium = x - y * 0.1055613458 - z * 0.0638541728
	local rootShort = x - y * 0.0894841775 - z * 1.2914855480

	local long = rootLong ^ 3
	local medium = rootMedium ^ 3
	local short = rootShort ^ 3

	local red = long * 4.0767416621 - medium * 3.3077115913 + short * 0.2309699292
	local green = long * -1.2684380046 + medium * 2.6097574011 - short * 0.3413193965
	local blue = long * -0.0041960863 - medium * 0.7034186147 + short * 1.7076147010

	if not unclamped then
		red = math.clamp(red, 0, 1)
		green = math.clamp(green, 0, 1)
		blue = math.clamp(blue, 0, 1)
	end

	return Color3.new(red, green, blue)
end

return table.freeze(Oklab)
