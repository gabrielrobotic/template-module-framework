local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileType = require(ReplicatedStorage.Shared.Types.ProfileType)

local RemoteEvents = ReplicatedStorage.Shared.RemoteEvents
local BindableEvents = ReplicatedStorage.Shared.BindableEvents

local profile: ProfileType.TProfile? = nil

local Private = {}
local Public = {}

function Public.OnStart()
	RemoteEvents.Profile.Loaded.OnClientEvent:Connect(Private.OnProfileLoaded)
	RemoteEvents.Profile.Updated.OnClientEvent:Connect(Private.OnProfileUpdated)

	RemoteEvents.Client.Ready:FireServer()
end

function Private.OnProfileLoaded(profileData: ProfileType.TProfile)
	profile = profileData
	BindableEvents.Profile.Loaded:Fire(Public.GetProfile())
end

function Private.OnProfileUpdated(actionName: string, profileData: ProfileType.TProfile)
	profile = profileData
	BindableEvents.Profile.Updated:Fire(actionName, Public.GetProfile())
end

function Public.GetProfile(): ProfileType.TProfile?
	return profile
end

return Public
