--!native
--!optimize 2
--!strict

local Oklab = require(script.Parent.Oklab)

-- stylua: ignore
type AnimationType =
	number
	| CFrame
	| Color3
	| ColorSequenceKeypoint
	| DateTime
	| NumberRange
	| NumberSequenceKeypoint
	| PhysicalProperties
	| Ray
	| Rect
	| Region3
	| Region3int16
	| UDim
	| UDim2
	| Vector2
	| Vector2int16
	| Vector3
	| Vector3int16

local function GetTypeFromValues(typeOf: string, values: {number}): AnimationType
	if typeOf == "number" then
		return values[1]
	end

	if typeOf == "CFrame" then
		return CFrame.new(values[1], values[2], values[3])
			* CFrame.fromAxisAngle(Vector3.new(values[4], values[5], values[6]).Unit, values[7])
	end

	if typeOf == "Color3" then
		return Oklab.From(values)
	end

	if typeOf == "ColorSequenceKeypoint" then
		return ColorSequenceKeypoint.new(values[4], Oklab.From(values, false))
	end

	if typeOf == "DateTime" then
		return DateTime.fromUnixTimestampMillis(values[1])
	end

	if typeOf == "NumberRange" then
		return NumberRange.new(values[1], values[2])
	end

	if typeOf == "NumberSequenceKeypoint" then
		return NumberSequenceKeypoint.new(values[2], values[1], values[3])
	end

	if typeOf == "PhysicalProperties" then
		return PhysicalProperties.new(values[1], values[2], values[3], values[4], values[5])
	end

	if typeOf == "Ray" then
		return Ray.new(Vector3.new(values[1], values[2], values[3]), Vector3.new(values[4], values[5], values[6]))
	end

	if typeOf == "Rect" then
		return Rect.new(values[1], values[2], values[3], values[4])
	end

	if typeOf == "Region3" then
		local position = Vector3.new(values[1], values[2], values[3])
		local halfSize = Vector3.new(values[4] / 2, values[5] / 2, values[6] / 2)
		return Region3.new(position - halfSize, position + halfSize)
	end

	if typeOf == "Region3int16" then
		return Region3int16.new(
			Vector3int16.new(values[1], values[2], values[3]),
			Vector3int16.new(values[4], values[5], values[6])
		)
	end

	if typeOf == "UDim" then
		return UDim.new(values[1], values[2])
	end

	if typeOf == "UDim2" then
		return UDim2.new(values[1], values[2], values[3], values[4])
	end

	if typeOf == "Vector2" then
		return Vector2.new(values[1], values[2])
	end

	if typeOf == "Vector2int16" then
		return Vector2int16.new(values[1], values[2])
	end

	if typeOf == "Vector3" then
		return Vector3.new(values[1], values[2], values[3])
	end

	if typeOf == "Vector3int16" then
		return Vector3int16.new(values[1], values[2], values[3])
	end

	error("Unsupported type: " .. typeOf)
end

return GetTypeFromValues
