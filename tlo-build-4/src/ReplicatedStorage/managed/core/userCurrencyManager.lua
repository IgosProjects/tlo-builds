local modUserCurrencyManager = {};
modUserCurrencyManager.__index = modUserCurrencyManager;

local runService = game:GetService("RunService");

if runService:IsClient() then warn("userCurrencyManager: userCurrencyManager cannot run on client!"); return {onImport = function() end}; end;

-- load userDataManager
local modUserDataManager = require(script.Parent.userDataManager);

-- when you want autocomplete and typesafety, you gotta sacrife neat code
modUserDataManager:onImport();

-- createNewValue(name: string, intitalValue: number | string | boolean, userID): userDataValue?

-- Registers a new currency and returns it
function modUserCurrencyManager:registerNewCurrency(currencyName: string, initialValue: number, userid: number): Currency
	local currency: Currency = {
		name = currencyName,
		userDataValue = nil
	}
	
	local self = setmetatable(currency, modUserCurrencyManager);
	
	print("userCurrencyManager: registering new currency: ".. currencyName .. " for user: " .. userid);
	
	currency.userDataValue = modUserDataManager:createNewValue(currencyName, initialValue, userid);
	
	return currency;
end

function modUserCurrencyManager:onImport()
	print("userCurrencyManager: done loading!");
end

export type Currency = {
	name: string,
	userDataValue: modUserDataManager.userDataValue; -- this is the userdata type, NOT THE ACTUAL VALUE!
}

return modUserCurrencyManager;