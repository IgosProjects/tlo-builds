local modUserDataManager = {};

-- probably should move unmanaged/server to server storage
-- note: done!

export type userDataValue = {
	name: string,
	value: IntValue | StringValue | BoolValue
}

local runService = game:GetService("RunService");

if runService:IsClient() then warn("userDataManager: userDataManager cannot run on client!"); return {onImport = function() end}; end;

local replicatedStorage = game:GetService("ReplicatedStorage");
local playersService = game:GetService("Players");
local serverStorage = game:GetService("ServerStorage");

local unmanagedData = serverStorage:WaitForChild("unmanaged");
local managedData = replicatedStorage:WaitForChild("managed");

local eventsFolder = managedData:WaitForChild("events");
local getDataValueFromCurrentUser = eventsFolder:WaitForChild("getDataValueFromCurentUser");

-- Returns the provided user data value for the current user by the name
getDataValueFromCurrentUser.OnServerInvoke = function (player: Player, name: string)
	local dataFolder = unmanagedData.server:FindFirstChild(tostring(player.UserId));
	if dataFolder then
		local value = dataFolder:FindFirstChild(name);
		if value then
			return value.Value;
		end
	end
	return nil;
end

-- When a player joins, create a folder for their data
-- TODO: Store inside of DStore
playersService.PlayerAdded:Connect(function(player: Player)
	if unmanagedData.server:FindFirstChild(tostring(player.UserId)) then
		return; -- dont make a new data folder if it allready exists
	end
	
	local dataFolder = Instance.new("Folder");
	dataFolder.Name = player.UserId;
	dataFolder.Parent = unmanagedData.server;
	
	print("userDataManager: created data folder for " .. player.DisplayName .. "id: ".. player.UserId .. "full path: " .. unmanagedData.server:WaitForChild(player.UserId):GetFullName());
end)

-- Creates a new value in the user's data folder and returns it
function modUserDataManager:createNewValue(name: string, intitalValue: number | string | boolean, userID): userDataValue?
	if userID == nil then
		warn("userDataManager: UserID is nil! Report this to @micro4ave! (unless you are a nonexistant user?)");
		return nil;	
	end
	
	print("userDataManager: creating new value for ".. userID .. " name: " .. name .. " value: " .. tostring(intitalValue) .. " type: " .. type(intitalValue) .. " userID: " .. userID);
	
	if type(intitalValue) == "number" then
		local val = Instance.new("IntValue");
		val.Name = name;
		val.Value = intitalValue;
		val.Parent = unmanagedData.server:WaitForChild(userID);
		return {
			name = name,
			value = val
		};
	elseif type(intitalValue) == "string" then
		local val = Instance.new("StringValue");
		val.Name = name;
		val.Value = intitalValue;
		val.Parent = unmanagedData.server:WaitForChild(userID);
		return {
			name = name,
			value = val
		};
	elseif type(intitalValue) == "boolean" then
		local val = Instance.new("BoolValue");
		val.Name = name;
		val.Value = intitalValue;
		val.Parent = unmanagedData.server:WaitForChild(userID);
		return {
			name = name,
			value = val
		};
	else
		warn("userDataManager: invalid value type for userdata value: " .. tostring(intitalValue));
		return nil;
	end
end

function modUserDataManager:onImport()
	for i, plr in pairs(playersService:GetPlayers()) do
		if unmanagedData.server:FindFirstChild(tostring(plr.UserId)) then
			return; -- dont make a new data folder if it allready exists
		end
		
		local dataFolder = Instance.new("Folder");
		dataFolder.Name = plr.UserId;
		dataFolder.Parent = unmanagedData.server;
		
		print("userDataManager: created data folder for " .. plr.DisplayName .. " id: ".. plr.UserId .. "full path: " .. unmanagedData.server:WaitForChild(plr.UserId):GetFullName());
	end
	
	print("userDataManager: loaded!");
end

return modUserDataManager;