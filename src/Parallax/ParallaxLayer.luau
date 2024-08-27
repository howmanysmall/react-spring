--!optimize 2
--!strict

local React = require(script.Parent.Parent.Parent.React)

local Controller = require(script.Parent.Parent.Controller)
local ParallaxTypes = require(script.Parent.ParallaxTypes)
local ParentContext = require(script.Parent.ParentContext)

local function ParallaxLayer(properties: ParallaxTypes.ParallaxLayerProperties, reference: any)
	local layerProperties: any = table.clone(properties)

	local horizontal = layerProperties.Horizontal
	layerProperties.Horizontal = nil

	local factor = layerProperties.Factor or 1
	layerProperties.Factor = nil

	local offset = layerProperties.Offset or 0
	layerProperties.Offset = nil

	local speed = layerProperties.Speed or 0
	layerProperties.Speed = nil

	local sticky = layerProperties.Sticky
	layerProperties.Sticky = nil

	local children = layerProperties.children
	layerProperties.children = nil

	local parent = React.useContext(ParentContext)
	local stickyTranslate, setStickyTranslate = React.useBinding(0)

	local styles, api = React.useMemo(function()
		local translate: number
		if sticky then
			local start = sticky.start or 0
			translate = start * parent.Space
		else
			local targetScroll = math.floor(offset) * parent.Space
			local distance = parent.Space * offset + targetScroll * speed
			translate = -(parent.Current * speed) + distance
		end

		return Controller.new({
			Space = if sticky then parent.Space else parent.Space * factor,
			Translate = translate,
		})
	end, {})

	local function setSticky(_: number, _: number) end

	local layer = React.useMemo(function(): ParallaxTypes.ParallaxLayer
		return {
			Horizontal = if horizontal == nil or sticky then parent.Horizontal else horizontal,
			Sticky = nil,
			IsSticky = false,

			SetPosition = function(height, scrollTop, immediate)
				if sticky then
					setSticky(height, scrollTop)
				else
					local targetScroll = math.floor(offset) * height
					local distance = height * offset + targetScroll * speed
					api:Start({
						Configuration = parent.Configuration,
						Immediate = immediate,
						Translate = -(scrollTop * speed) + distance,
					} :: any)
				end
			end,

			SetHeight = function(height, immediate)
				api:Start({
					Configuration = parent.Configuration,
					Immediate = immediate,
					Space = if sticky then height else height * factor,
				})
			end,
		}
	end, {})

	-- TODO: useOnce
	local function updateStickyEffect()
		if sticky then
			local start = sticky.Start or 0
			local finish = sticky.Finish or start + 1
			layer.Sticky = {
				Finish = finish,
				Start = start,
			}
		end
	end
	React.useEffect(updateStickyEffect, {})

	React.useImperativeHandle(reference, function()
		return layer
	end)

	setSticky = function(height: number, scrollTop: number)
		local start = layer.Sticky and layer.Sticky.Start and layer.Sticky.Start * height
		local finish = layer.Sticky and layer.Sticky.Finish and layer.Sticky.Finish * height
		if start and finish then
			layer.IsSticky = scrollTop >= start and scrollTop <= finish

			-- DEVIATION: Since `sticky` is not natively supported, we must manually set the position of the sticky layer every time
			-- the scroll position changes
			if scrollTop > start and scrollTop < finish then
				setStickyTranslate(scrollTop)
			else
				setStickyTranslate(if scrollTop <= start then start else finish)
			end
		end
	end

	local function updateParentEffect()
		if not parent then
			return
		end

		parent.Layers:add(layer)
		parent.Update()
		return function()
			parent.Layers:delete(layer)
			parent.Update()
		end
	end
	React.useEffect(updateParentEffect, {})

	api:Start({Translate = 0})

	layerProperties.BackgroundTransparency = 1
	layerProperties.Position = (if sticky then stickyTranslate else styles.Translate):map(function(value)
		return if layer.Horizontal then UDim2.fromOffset(value, 0) else UDim2.fromOffset(0, value)
	end)
	layerProperties.Size = styles.Space:map(function(value)
		return if layer.Horizontal then UDim2.new(0, value, 1, 0) else UDim2.new(1, 0, 0, value)
	end)
	layerProperties.ref = reference
	return React.createElement("Frame", layerProperties, children)
end

local ParallaxLayerNoMemo = React.forwardRef(ParallaxLayer)
ParallaxLayerNoMemo.displayName = "ParallaxLayerNoMemo"

local TrueParallaxLayer = React.memo(ParallaxLayerNoMemo)
TrueParallaxLayer.displayName = "ParallaxLayer"
return (TrueParallaxLayer :: never) :: (properties: ParallaxTypes.ParallaxLayerProperties) -> React.ReactNode
