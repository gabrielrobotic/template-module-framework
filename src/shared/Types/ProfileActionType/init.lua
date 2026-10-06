local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileActionEnum = require(ReplicatedStorage.Shared.Enums.ProfileActionEnum)

export type TProfileAction = {
	name: typeof(ProfileActionEnum.UPDATE_COINS),
	amount: number,
}

return {}
