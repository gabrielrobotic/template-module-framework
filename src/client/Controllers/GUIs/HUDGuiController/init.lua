local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GuiController = require(script.Parent.Parent.GuiController)
local ProfileController = require(script.Parent.Parent.ProfileController)
local ProfileActionEnum = require(ReplicatedStorage.Shared.Enums.ProfileActionEnum)

local BindableEvents = ReplicatedStorage.Shared.BindableEvents

local gui = GuiController.GUIs.HUD
local coinsAmount = gui.Coins.Amount

local Private = {}
local Public = {}

function Public.OnStart()
	BindableEvents.Profile.Loaded.Event:Connect(Private.OnProfileLoaded)
	BindableEvents.Profile.Updated.Event:Connect(Private.OnProfileUpdated)
end

function Private.OnProfileLoaded()
	Private.UpdateCoins()
end

function Private.OnProfileUpdated(actionName: string)
	if actionName == ProfileActionEnum.UPDATE_COINS then
		Private.UpdateCoins()
	end
end

function Private.UpdateCoins()
	local profile = ProfileController.GetProfile()
	if not profile then
		return
	end

	coinsAmount.Text = tostring(profile.coins)
end

return Public
