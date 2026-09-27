-- todo: do this properly, im just too lazy to!

local bar = script.Parent:WaitForChild("Bar");
local localplr = game:GetService("Players").LocalPlayer;
local char = localplr.Character or localplr.CharacterAdded:Wait();
local hum = char:WaitForChild("Humanoid");

function updateBar()
	local percent = hum.Health / hum.MaxHealth;
	bar:TweenSize(UDim2.new(percent, 0, 0.8, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true);
end

-- very simple
updateBar();
hum.HealthChanged:Connect(updateBar);