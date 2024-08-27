--!optimize 2
--!strict

local function FastMerge<T>(...: any): T
	local length = select("#", ...)
	if length == 0 then
		return {} :: never
	end

	if length == 1 then
		local dictionary0 = ...
		return (if dictionary0 then table.clone(dictionary0) else {}) :: never
	end

	if length == 2 then
		local dictionary0, dictionary1 = ...

		local result = (if dictionary0 then table.clone(dictionary0) else {}) :: never
		if dictionary1 then
			for key, value in dictionary1 do
				result[key] = value
			end
		end

		return result
	end

	if length == 3 then
		local dictionary0, dictionary1, dictionary2 = ...

		local result = (if dictionary0 then table.clone(dictionary0) else {}) :: never
		if dictionary1 then
			for key, value in dictionary1 do
				result[key] = value
			end
		end
		if dictionary2 then
			for key, value in dictionary2 do
				result[key] = value
			end
		end

		return result
	end

	if length == 4 then
		local dictionary0, dictionary1, dictionary2, dictionary3 = ...

		local result = (if dictionary0 then table.clone(dictionary0) else {}) :: never
		if dictionary1 then
			for key, value in dictionary1 do
				result[key] = value
			end
		end
		if dictionary2 then
			for key, value in dictionary2 do
				result[key] = value
			end
		end
		if dictionary3 then
			for key, value in dictionary3 do
				result[key] = value
			end
		end

		return result
	end

	local result = {}
	for dictionaryIndex = 1, length do
		local dictionary = select(dictionaryIndex, ...)
		if dictionary ~= nil then
			for key, value in dictionary do
				result[key] = value
			end
		end
	end

	return result :: never
end

return FastMerge
