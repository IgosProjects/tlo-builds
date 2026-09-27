-- todo: blah blah blah, same thing

local replicatedStorage = game:GetService("ReplicatedStorage");
local managedData = replicatedStorage:WaitForChild("managed");

local eventsFolder = managedData:WaitForChild("events");
local getDataValueFromCurrentUser = eventsFolder:WaitForChild("getDataValueFromCurentUser");

-- wait for server to set initial values
-- TODO: increases load time!
task.wait(2); 

-- update it every like frame or so
local function updateMoneyLabel()
	script.Parent.Text = "$" .. getDataValueFromCurrentUser:InvokeServer("cash");
end

while task.wait() do
	updateMoneyLabel();	
end