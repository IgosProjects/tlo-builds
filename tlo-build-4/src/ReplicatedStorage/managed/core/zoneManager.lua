local modZoneManager = {};
modZoneManager.__index = modZoneManager;

local collectionService = game:GetService("CollectionService");
local runService = game:GetService("RunService");

local zones = {}; -- indexed by zone name!
local playerCurrentZones = {}; -- player object is the index, the value is the current zone name

local goodSignal = require(script.Parent.Parent.shared:WaitForChild("goodSignal"));


-- Registers a new zone with the zone manager
-- tag: The tag that is applied to the parts of this zone
-- name: The name of the zone that will be used to refrence it
function modZoneManager:addNewZone(tag: string, name: string)
	zones[name] = collectionService:GetTagged(tag); -- set the zone table entry
	
	if #zones[name] == 0 then
		warn("zoneManager: no parts were found with tag ".. tag .. " , zone name: ".. name .. " this may cause undefined behavior!");
	end
	
	-- register handlers
	for i, zpart in pairs(zones[name]) do
		zpart.Touched:Connect(function(otherPart: BasePart) 
			-- check if its a character
			if otherPart.Parent:FindFirstChild("Humanoid") then
				-- get the character and player
				local char = otherPart.Parent;
				local plr = game.Players:GetPlayerFromCharacter(char);
				
				-- check if its actually a player and not just an NPC
				if plr then
					-- check if the player is allready in this zone
					-- this is to prevent 20 events firing instead of 1
					if playerCurrentZones[plr] == name then
						return;
					end
					
					-- dont print the enter logs!
					--print("zoneManager: ".. plr.DisplayName.. " has entered zone ".. name);
					
					-- Fire the event and let the handlers handle it
					self.enteredZone:Fire(plr, name);
					
					-- if it doesnt exist, insert it into
					if not playerCurrentZones[plr] then
						playerCurrentZones[plr] = "";
					end
					
					-- set the current zone for the player
					playerCurrentZones[plr] = name;
				end
			end
		end)
	end
	
	print("zoneManager: registered and added zone! tag: ".. tag .. " name: ".. name);	
end

function modZoneManager:onImport()
	print("zoneManager: waiting a few seconds to make sure the game is loaded!");
	task.wait(5);
	
	-- EVENT SETUP
	local self = setmetatable({}, modZoneManager);
	self.enteredZone = goodSignal.new();

	modZoneManager.enteredZone = self.enteredZone; -- sometimes it breaks without this
	
	print("zoneManager: registering initial zones");
	
	-- INITIAL ZONE SETUP
	modZoneManager:addNewZone("tloZone_warehouseMainRoom", "warehouseMainRoom");
	modZoneManager:addNewZone("tloZone_warehouseBedroom", "warehouseBedroom");
	
	return self;
end

return modZoneManager;