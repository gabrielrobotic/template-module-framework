local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ProfileStore = require(ServerScriptService.ServerPackages.profilestore)
local ProfileData = require(ReplicatedStorage.Shared.Data.ProfileData)
local ProfileType = require(ReplicatedStorage.Shared.Types.ProfileType)
local ProfileActionType = require(ReplicatedStorage.Shared.Types.ProfileActionType)
local ActionHandler = require(script.ActionHandler)

local DATA_STORE_NAME = RunService:IsStudio() and "profile_dev" or "profile_prod"

local RemoteEvents = ReplicatedStorage.Shared.RemoteEvents
local BindableEvents = ReplicatedStorage.Shared.BindableEvents

local playerStore = ProfileStore.New(DATA_STORE_NAME, ProfileData)
type Profile<T> = typeof(playerStore)
local playerProfiles: { [Player]: Profile<ProfileType.TProfile> } = {}
local clientsReceived: { [Player]: boolean } = {}

local Private = {}
local Public = {}

function Public.OnStart()
	RemoteEvents.Client.Ready.OnServerEvent:Connect(Private.OnClientReady)

	Players.PlayerAdded:Connect(Private.OnPlayerAdded)
	Players.PlayerRemoving:Connect(Private.OnPlayerRemoving)

	for _, player in Players:GetPlayers() do
		task.defer(Private.OnPlayerAdded, player)
	end
end

function Private.OnClientReady(player: Player)
	if clientsReceived[player] then
		return
	end

	while player.Parent and not playerProfiles[player] do
		task.wait()
	end

	local profile = Public.GetProfile(player)
	if not profile then
		warn(`Profile for player {player.Name} not found.`)
		return
	end

	RemoteEvents.Profile.Loaded:FireClient(player, profile)

	clientsReceived[player] = true
end

function Private.OnPlayerAdded(player: Player)
	local success, profile = pcall(function()
		return playerStore:StartSessionAsync(tostring(player.UserId), {
			Cancel = function()
				return player.Parent ~= Players
			end,
		})
	end)

	if not success then
		warn(`Failed to load profile for player {player.Name}`)
		player:Kick("Failed to load your profile. Please try again later.")
		return
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()

	profile.OnSessionEnd:Connect(function()
		playerProfiles[player] = nil
	end)

	playerProfiles[player] = profile

	BindableEvents.Profile.Loaded:Fire(player, profile.Data)
end

function Private.OnPlayerRemoving(player: Player)
	local profile = playerProfiles[player]
	if not profile then
		return
	end

	profile:EndSession()
end

function Public.GetProfile(player: Player): ProfileType.TProfile?
	local profile = playerProfiles[player]

	if not profile then
		warn(`Profile for player {player.Name} not found.`)
		return nil
	end

	return profile.Data
end

function Public.UpdateProfile(player: Player, action: ProfileActionType.TProfileAction)
	local profile = Public.GetProfile(player)
	if not profile then
		return
	end

	local success, errorMessage = ActionHandler.Execute(profile, action)
	if not success then
		warn(`Failed to execute action {action.name} for player {player.Name}: {errorMessage}`)
		return
	end

	RemoteEvents.Profile.Updated:FireClient(player, action.name, profile)
	BindableEvents.Profile.Updated:Fire(player, action.name, profile)
end

return Public
