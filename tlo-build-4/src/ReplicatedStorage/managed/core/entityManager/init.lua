local modEntityManager = {};
modEntityManager.__index = modEntityManager;

local replicatedStorage = game:GetService("ReplicatedStorage");
local runService = game:GetService("RunService");

if runService:IsClient() then warn("entityManager: entityManager cannot run on client!"); return {onImport = function() end}; end;

local managedAssets = replicatedStorage:WaitForChild("managed");
local entitiesFolder = managedAssets:WaitForChild("entities");

local modEntityTypes = require(script:FindFirstChild("entityTypes"));

-- List of all enmies in the game
-- This might be loaded from the folder later on, for now its hardcoded!
local enemies = {
	"Enemy_Homeless"
}

-- Spawns an entity at the provided position, entity is based on the name
-- Invalid entites are rejected!
function modEntityManager:spawnEntity(entityName: string, position: Vector3)
	local entity: modEntityTypes.Entity = {
		name = entityName,
		position = position,
		model = nil,
		despawn = nil
	}
	
	local entityModel = entitiesFolder:FindFirstChild(entityName);
	if not entityModel then warn("entityManager: could not find entity model: " .. entityName); return; end;
	
	-- MODEL SETUP
	entity.model = entityModel:Clone();
	entity.model.Parent = workspace;
	
	-- FUNCTION SETUP
	function entity:despawn()
		if self.model then
			self.model:Destroy();
			self.model = nil;
		end
	end
	
	-- SET POSITION
	entity.model:PivotTo(CFrame.new(position));
	
	-- ENEMY SETUP
	-- if the entity name is included in the enemies table, we will register it as an enemy
	
	local enemyIndex = table.find(enemies, entityName);
	if enemyIndex then
		local enemyModule = require(script:WaitForChild("enemyManager"));
		enemyModule:registerEnemy(entity);
	end
	
	return entity;
end

function modEntityManager:onImport()
	
end

return modEntityManager;