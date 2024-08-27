--!optimize 2
--!strict

local LuauPolyfill = require(script.Parent.Parent.Parent.LuauPolyfill)
local React = require(script.Parent.Parent.Parent.React)

export type Parallax = {
	Configuration: any,
	Horizontal: boolean,
	Busy: boolean,
	Space: number,
	Offset: number,

	Current: number,
	Layers: LuauPolyfill.Set<ParallaxLayer>,
	Container: any,
	Content: any,

	ScrollTo: (offset: number) -> (),
	Update: () -> (),
	Stop: () -> (),

	_Api: any,
	_Styles: any,
}

export type ParallaxProperties = {
	Configuration: any?,
	Pages: number,
	Horizontal: boolean?,
	children: React.ReactNode?,
	[string]: any,
}

export type StickyConfiguration = {
	Finish: number?,
	Start: number?,
}

export type ParallaxLayer = {
	Horizontal: boolean,
	Sticky: StickyConfiguration?,
	IsSticky: boolean,

	SetHeight: (height: number, immediate: boolean?) -> (),
	SetPosition: (height: number, scrollTop: number, immediate: boolean?) -> (),
}

export type ParallaxLayerProperties = {
	Horizontal: boolean?,
	-- Size of a page, (1 = 100%, 1.5 = 3/2, ...)
	Factor: number?,
	-- Determines where the layer will be at when scrolled to (0=start, 1=1st page, ...)
	Offset: number?,
	-- Shifts the layer in accordance to its offset, values can be positive or negative
	Speed: number?,
	-- Layer will be sticky between these two offsets, all other props are ignored
	Sticky: StickyConfiguration?,

	children: React.ReactNode?,
	[string]: any,
}

return false
