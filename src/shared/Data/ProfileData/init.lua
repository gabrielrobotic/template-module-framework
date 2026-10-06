local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileType = require(ReplicatedStorage.Shared.Types.ProfileType)

local ProfileData: ProfileType.TProfile = {
	coins = 0,
}

return ProfileData
