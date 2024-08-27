--!optimize 2
--!strict

local ParallaxTypes = require(script.Parent.ParallaxTypes)
local React = require(script.Parent.Parent.Parent.React)

local ParentContext: React.Context<ParallaxTypes.Parallax> = React.createContext(nil :: any)
ParentContext.displayName = "ParallaxParentContext"
return ParentContext
