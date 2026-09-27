local modEnemyManager = {};
modEnemyManager.__index = modEnemyManager;

local replicatedStorage = game:GetService("ReplicatedStorage");
local managedAssets = replicatedStorage:WaitForChild("managed");
local entitiesFolder = managedAssets:WaitForChild("entities")
local coreFolder = managedAssets:WaitForChild("core");

local modShared = require(coreFolder:WaitForChild("shared"));
local modEntityTypes = require(script.Parent.entityTypes);
local modSimplePath = require(managedAssets.shared.simplePath);

local playersService = game:GetService("Players");

function modEnemyManager:getNearestPlayer(position: Vector3): Player?
	local nearestPlayer: Player? = nil;
	local nearestDistance = math.huge;

	-- loop through all players and find the closest
	for _, player in playersService:GetPlayers() do
		local character = player.Character;
		if not character then
			continue;
		end

		-- get the humanoid and root part
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart");
		local humanoid = character:FindFirstChildOfClass("Humanoid");

		if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
			continue;
		end

		-- do some math to get distance
		local distance = (humanoidRootPart.Position - position).Magnitude;

		-- check if this is the closest player
		if distance < nearestDistance then
			nearestDistance = distance;
			nearestPlayer = player;
		end
	end

	return nearestPlayer;
end

-- Registers an enemy with the system, inserts the scripts and handles the stuff!
function modEnemyManager:registerEnemy(entity: modEntityManager.Entity)
	print("enemyManager: registering enemy ", entity.name);
	
	-- HUMANOID SETUP
	local humanoid: Humanoid = entity.model:FindFirstChild("Humanoid");
	local maxHealth = humanoid.MaxHealth;
	
	local enemyConfig = require(entity.model:WaitForChild("EnemyConfig"));
	
	local path = modSimplePath.new(entity.model); -- create a new path
	local nearestPlayerPos: Vector3 = nil;
	
	-- NOTE FOR FUTURE SELF: this will cause many threads, aka fps = fucked
	local enemyThread = coroutine.create(function()
		while true do
			task.wait(0);
			
			-- Check if the enemy died, if so we despawn them after 5 seconds
			if humanoid.Health <= 0 then
				entity:despawn();
				break; -- stop the thread
			end
			
			---------------------
			-- AI UPDATE LOGIC --
			---------------------
			
			local nearestPlayer = modEnemyManager:getNearestPlayer(entity.model.HumanoidRootPart.Position); -- get the nearest player
			local nearestPlayerRoot = nil;
			
			if nearestPlayer then
				nearestPlayerRoot = nearestPlayer.Character:FindFirstChild("HumanoidRootPart"); -- get the nearest players root part
			end
			
			
			local randomWalking = false;

			if not nearestPlayerRoot then
				randomWalking = true;
				nearestPlayerPos = entity.model.PrimaryPart.Position + Vector3.new(math.random(0, 10), 0, math.random(0, 10));
			else
				nearestPlayerPos = nearestPlayerRoot.Position; -- get the players position
			end
			
			local distance = (nearestPlayerPos - entity.model.HumanoidRootPart.Position).Magnitude;
			
		if distance <= enemyConfig.DistanceUntilChase then
			local didFindPath: boolean = path:Run(nearestPlayerPos); -- Run() will return true if a path was found and it was used, but it will return false if otherwise
			
			if not didFindPath then
				humanoid:MoveTo(nearestPlayerPos); -- if pathfinding fails, start trying to reach the nearest player
			end
		end
			
			-- DEAL DAMAGE
			
			if distance <= enemyConfig.AttackDistance then
				-- get the humanoid
				local playerHumanoid: Humanoid = nearestPlayer.Character:FindFirstChildOfClass("Humanoid");
				
				playerHumanoid:TakeDamage(enemyConfig.DamagePerTick);
			end
			
			if randomWalking then
				task.wait(2);
			end
		end
		
		coroutine.yield();
	end)
	
	coroutine.resume(enemyThread); -- start the thread(note: dont remove for the love of me)
	
	-- hook onto the delete logic and make the enemy stop pathfinding
	humanoid.Destroying:Connect(function()
		path:Stop(); -- stop the pathfinding
		coroutine.close(enemyThread); -- stop the thread
		-- entity was allready despawned
	end)
	
	print("enemyManager: enemy registered!");	
end

function modEnemyManager:onImport()
	print("enemyManager: ready!");
end

return modEnemyManager;