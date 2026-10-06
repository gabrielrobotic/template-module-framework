local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local RunService = game:GetService("RunService")

local IS_SERVER = RunService:IsServer()

local rootDirectory = IS_SERVER and ServerScriptService or Players.LocalPlayer:WaitForChild("PlayerScripts")
local moduleDirectory = IS_SERVER and rootDirectory.Server.Services or rootDirectory.Client:WaitForChild("Controllers")

local function RequireModule(module: ModuleScript)
	local success, result = pcall(require, module)

	if success and typeof(result) == "table" and result.OnStart then
		result.OnStart()
	end
end

return function()
	local moduleCount = 0
	local moduleLoadedCount = 0
	local modulesToLoad = {}

	local descendants = moduleDirectory:GetDescendants()

	for _, descendant in descendants do
		if not descendant:IsA("ModuleScript") then
			continue
		end

		moduleCount += 1
		table.insert(modulesToLoad, descendant)
	end

	if moduleCount == 0 then
		return true
	end

	for _, module in modulesToLoad do
		task.spawn(function()
			RequireModule(module)
			moduleLoadedCount += 1
		end)
	end

	while moduleLoadedCount < moduleCount do
		task.wait()
	end

	return true
end
