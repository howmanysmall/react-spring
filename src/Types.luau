--!optimize 2
--!strict

export type AnimatableType =
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

export type AnimationStyle = {[string]: AnimatableType}
export type EasingFunction = (alpha: number) -> number

export type SpringConfiguration = {
	--[[
		Higher mass means more friction is required to slow down.
		Defaults to 1, which works fine most of the time.
	]]
	Mass: number,

	--[[
		With higher tension, the spring will resist bouncing and try harder to stop at its end value.
		When tension is zero, no animation occurs.
	]]
	Tension: number,

	--[[
		The damping ratio coefficient.
		Higher friction means the spring will slow down faster.
	]]
	Friction: number,

	--[[
		Avoid overshooting by ending abruptly at the goal value.
	]]
	Clamp: boolean,

	--[[
		The smallest distance from a value before that distance is essentially zero.

		This helps in deciding when a spring is "at rest". The spring must be within
		this distance from its final value, and its velocity must be lower than this
		value too (unless `RestVelocity` is defined).
	]]
	Precision: number?,

	--[[
		For `Duration` animations only. Note: The `Duration` is not affected
		by this property.

		- Defaults to `0`, which means "start from the beginning".
		- Setting to `1+` makes an immediate animation.
		- Setting to `0.5` means "start from the middle of the easing function".
		- Any number `>= 0` and `<= 1` makes sense here.
	]]
	Progress: number?,

	--[[
		The initial velocity of one or more values.
	]]
	Velocity: number | {number},

	--[[
		The animation curve. Only used when `Duration` is defined.
	]]
	EasingFunction: EasingFunction,

	--[[
		The damping ratio, which dictates how the spring slows down.

		Set to `0` to never slow down. Set to `1` to slow down without bouncing.
		Between `0` and `1` is for you to explore.

		Only works when `Frequency` is defined.
	]]
	DampingRatio: number,

	--[[
		Animation length in number of seconds.
	]]
	Duration: number?,

	--[[
		The natural frequency (in seconds), which dictates the number of bounces
		per second when no damping exists.

		When defined, `Tension` is derived from this, and `Friction` is derived
		from `Tension` and `Damping`.
	]]
	Frequency: number?,

	--[[
		When above zero, the spring will bounce instead of overshooting when
		exceeding its goal value. Its velocity is multiplied by `-1 + Bounce`
		whenever its current value equals or exceeds its goal. For example,
		setting `Bounce` to `0.5` chops the velocity in half on each bounce,
		in addition to any friction.
	]]
	Bounce: number?,

	--[[
		The smallest velocity before the animation is considered "not moving".
		When undefined, `Precision` is used instead.
	]]
	RestVelocity: number?,
}
export type PartialSpringConfiguration = {
	--[[
		Higher mass means more friction is required to slow down.
		Defaults to 1, which works fine most of the time.
	]]
	Mass: number?,

	--[[
		With higher tension, the spring will resist bouncing and try harder to stop at its end value.
		When tension is zero, no animation occurs.
	]]
	Tension: number?,

	--[[
		The damping ratio coefficient.
		Higher friction means the spring will slow down faster.
	]]
	Friction: number?,

	--[[
		Avoid overshooting by ending abruptly at the goal value.
	]]
	Clamp: boolean?,

	--[[
		The smallest distance from a value before that distance is essentially zero.

		This helps in deciding when a spring is "at rest". The spring must be within
		this distance from its final value, and its velocity must be lower than this
		value too (unless `RestVelocity` is defined).
	]]
	Precision: number?,

	--[[
		For `Duration` animations only. Note: The `Duration` is not affected
		by this property.

		- Defaults to `0`, which means "start from the beginning".
		- Setting to `1+` makes an immediate animation.
		- Setting to `0.5` means "start from the middle of the easing function".
		- Any number `>= 0` and `<= 1` makes sense here.
	]]
	Progress: number?,

	--[[
		The initial velocity of one or more values.
	]]
	Velocity: nil | number | {number},

	--[[
		The animation curve. Only used when `Duration` is defined.
	]]
	EasingFunction: EasingFunction?,

	--[[
		The damping ratio, which dictates how the spring slows down.

		Set to `0` to never slow down. Set to `1` to slow down without bouncing.
		Between `0` and `1` is for you to explore.

		Only works when `Frequency` is defined.
	]]
	DampingRatio: number?,

	--[[
		Animation length in number of seconds.
	]]
	Duration: number?,

	--[[
		The natural frequency (in seconds), which dictates the number of bounces
		per second when no damping exists.

		When defined, `Tension` is derived from this, and `Friction` is derived
		from `Tension` and `Damping`.
	]]
	Frequency: number?,

	--[[
		When above zero, the spring will bounce instead of overshooting when
		exceeding its goal value. Its velocity is multiplied by `-1 + Bounce`
		whenever its current value equals or exceeds its goal. For example,
		setting `Bounce` to `0.5` chops the velocity in half on each bounce,
		in addition to any friction.
	]]
	Bounce: number?,

	--[[
		The smallest velocity before the animation is considered "not moving".
		When undefined, `Precision` is used instead.
	]]
	RestVelocity: number?,
}

export type AnimationProperties = {
	Loop: boolean?,
	Reset: boolean?,
	Default: boolean?,
	Configuration: PartialSpringConfiguration?,
	Immediate: boolean?,
	Delay: number?,
}

export type Properties = {[string]: any}

type Disconnect = {Disconnect: (self: Disconnect) -> ()}
export type PostSimulationLike = {
	Connect: (self: PostSimulationLike, callback: (deltaTime: number) -> ()) -> Disconnect,
}

return false
