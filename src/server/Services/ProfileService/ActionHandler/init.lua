local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileType = require(ReplicatedStorage.Shared.Types.ProfileType)
local ProfileActionType = require(ReplicatedStorage.Shared.Types.ProfileActionType)
local ProfileActionEnum = require(ReplicatedStorage.Shared.Enums.ProfileActionEnum)

local handlers = {
	[ProfileActionEnum.UPDATE_COINS] = function(
		profile: ProfileType.TProfile,
		action: ProfileActionType.TProfileAction
	): (boolean, string?)
		if not action.amount then
			return false, "Missing amount for UPDATE_COINS action"
		end

		profile.coins += action.amount

		return true
	end,
}

local Public = {}

function Public.Execute(profile: ProfileType.TProfile, action: ProfileActionType.TProfileAction): (boolean, string?)
	local handler = handlers[action.name]
	if not handler then
		return false, `No handler found for action {action.name}`
	end

	return handler(profile, action)
end

return Public
