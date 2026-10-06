local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player.PlayerGui

local Public = {}

Public.GUIs = {
	HUD = playerGui:WaitForChild("UI"):WaitForChild("HUDGui"),
}

return Public
