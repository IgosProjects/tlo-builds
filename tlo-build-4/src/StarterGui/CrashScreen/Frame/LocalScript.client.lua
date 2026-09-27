local logService = game:GetService("LogService")

local crashInfoLabel = script.Parent:WaitForChild("InfoLabel");

-- catch any errors and report them
logService.MessageOut:Connect(function(msg: string, msgType: Enum.MessageType)
	if msgType == Enum.MessageType.MessageError then
		crashInfoLabel.Text = "The Last Outbreak has crashed! Report this to the developers with the screenshot below: ".. msg;
		script.Parent.Visible = true;
	end
end)