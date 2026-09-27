local modGameInit = {};
local replicatedStorage = game:GetService("ReplicatedStorage");
local playersService = game:GetService("Players");
local runService = game:GetService("RunService");

local managedResources = replicatedStorage:WaitForChild("managed");
local coreModules = managedResources:WaitForChild("core");

local modShared = require(coreModules:WaitForChild("shared"));
local modDoorManager = modShared:require(coreModules:WaitForChild("doorManager"));
local modZoneManager = modShared:require(coreModules:WaitForChild("zoneManager"));
local modEntityManager = modShared:require(coreModules:WaitForChild("entityManager"));
local modUserDataManager = modShared:require(coreModules:WaitForChild("userDataManager"));
local modUserCurrencyManager = modShared:require(coreModules:WaitForChild("userCurrencyManager"));

-- registerNewCurrency(currencyName: string, initialValue: number, userid: number): Currency

-- SERVER LOGIC!
if runService:IsServer() then
	for i, plr in pairs(playersService:GetPlayers()) do
		print("gameInit: setting initial currencies for player ".. plr.DisplayName);
		modUserCurrencyManager:registerNewCurrency("cash", 0, plr.UserId);
	end
	
	playersService.PlayerAdded:Connect(function(plr: Player)
		print("gameInit: setting initial currencies for player ".. plr.DisplayName);
		modUserCurrencyManager:registerNewCurrency("cash", 0, plr.UserId);
	end)
end

function modGameInit:onImport()
	print("gameInit: done gameInit!");
	
	-- only spawn NPCs on server!
	if runService:IsServer() then
		local jackson = modEntityManager:spawnEntity("NPC_Jackson", Vector3.new(-12.5, 0.5, 3.5));
		local homeless = modEntityManager:spawnEntity("Enemy_Homeless", Vector3.new(-15.5, 0.5, 3.5));
	end
end

return modGameInit;