local modDoorManager = {};
local runService = game:GetService("RunService");
local collectionService = game:GetService("CollectionService");

if runService:IsClient() then warn("doorManager: doorManager cannot run on client!"); return {onImport = function() end}; end;

local doorsInWorld = collectionService:GetTagged("tloDoorRoot");

function modDoorManager:onImport()
	for i, v in pairs(doorsInWorld) do
		print("doorManager: Registering door: " .. v.Name .. " parent name: ".. v.Parent.name);
			
		local door: BasePart = v;
		
		local success, err = pcall(function()
			local doorPrompt: ProximityPrompt = v:WaitForChild("DoorPrompt", 2);
			
			assert(doorPrompt, "no door prompt!");
			
			doorPrompt.Triggered:Connect(function(plr)
				local char = plr.Character;
				local root = char:WaitForChild("HumanoidRootPart", 2);
				
				if root then
					-- do some fancy math to get the player direction and such
					local direction = door.CFrame.LookVector;
					
					if direction:Dot((root.Position - door.Position).Unit) > 0 then
						direction = -direction;
					end
					
					-- apply the direction and move them to the other side of the door
					root.CFrame = door.CFrame + direction * 5; -- TODO: make it change since some doors are thicker
				end
			end)
		end);

		if not success and err then
			warn("doorManager: Error while registering door: " .. v.Name .. " parent name: ".. v.Parent.name .. " - " .. err);	
		end
	end
end

return modDoorManager;