local modShared = {};
local runService = game:GetService("RunService");

modShared.isStudio = runService:IsStudio();
modShared.gameVersion = "0.0.1-dev";
modShared.gameName = "The Last Outbreak";

function modShared:require(mod: ModuleScript | string)
	local module = require(mod);
	local onImport = module["onImport"];
	
	if not onImport then
		warn("shared: Attempt to load module without an onImport function");
		warn("shared: " .. mod.Name .. " does not have an onImport function!");
		warn("shared: By defualt behavior, the module will be returned directly!");
		
		return module;
	end
	
	onImport();
	
	return module;
end

return modShared;