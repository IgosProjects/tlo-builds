local replicatedStorage = game:GetService("ReplicatedStorage");
local managedResources = replicatedStorage:WaitForChild("managed");
local coreModules = managedResources:WaitForChild("core");

local modShared = require(coreModules:WaitForChild("shared"));
local modGameInit = modShared:require(coreModules:WaitForChild("gameInit"));

print("serverInit: started gameInit!");