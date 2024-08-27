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

local function GetValuesFromType(data: any): {number}
	local typeOf = typeof(data)

	if typeOf == "number" then
		return {data}
	end

	if typeOf == "CFrame" then
		local axis, angle = data:ToAxisAngle()
		return {data.X, data.Y, data.Z, axis.X, axis.Y, axis.Z, angle}
	end

	if typeOf == "Color3" then
		return Oklab.To(data)
	end

	if typeOf == "ColorSequenceKeypoint" then
		local Array = Oklab.To(data.Value)
		Array[4] = data.Time
		return Array
	end

	if typeOf == "DateTime" then
		return {data.UnixTimestampMillis}
	end

	if typeOf == "NumberRange" then
		local castData = data :: NumberRange
		return {castData.Min, castData.Max}
	end

	if typeOf == "NumberSequenceKeypoint" then
		return {data.Value, data.Time, data.Envelope}
	end

	if typeOf == "PhysicalProperties" then
		return {data.Density, data.Friction, data.Elasticity, data.FrictionWeight, data.ElasticityWeight}
	end

	if typeOf == "Ray" then
		local origin, direction = data.Origin, data.Direction
		return {origin.X, origin.Y, origin.Z, direction.X, direction.Y, direction.Z}
	end

	if typeOf == "Rect" then
		local castData = data :: Rect
		local min = castData.Min
		local max = castData.Max
		return {min.X, min.Y, max.X, max.Y}
	end

	if typeOf == "Region3" then
		local cframe = data.CFrame
		local size = data.Size
		return {cframe.X, cframe.Y, cframe.Z, size.X, size.Y, size.Z}
	end

	if typeOf == "Region3int16" then
		local castData = data :: Region3int16
		local min = castData.Min
		local max = castData.Max
		return {min.X, min.Y, min.Z, max.X, max.Y, max.Z}
	end

	if typeOf == "UDim" then
		return {data.Scale, data.Offset}
	end

	if typeOf == "UDim2" then
		return {data.X.Scale, data.X.Offset, data.Y.Scale, data.Y.Offset}
	end

	if typeOf == "Vector2" or typeOf == "Vector2int16" then
		return {data.X, data.Y}
	end

	if typeOf == "Vector3" or typeOf == "Vector3int16" then
		return {data.X, data.Y, data.Z}
	end

	error("Unsupported type: " .. typeOf)
end

return GetValuesFromType
