local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local function onChatMessage(player, message)
    if string.find(message:lower(), "lonely") then
        local playerPosition = player.Character and player.Character:FindFirstChild("HumanoidRootPart").Position or Vector3.new(0, 10, 0)

        for _, friend in ipairs(player:GetFriendsAsync()) do
            local friendPlayer = Players:GetPlayerByUserId(friend.Id)
            if friendPlayer and friendPlayer.Character then
                local clone = friendPlayer.Character:Clone()
                clone.Parent = workspace
                clone:SetPrimaryPartCFrame(CFrame.new(playerPosition + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))))
                clone.HumanoidRootPart.Anchored = false
                clone.Name = friendPlayer.Name .. " Clone"
            end
        end
    end
end

-- Listen for messages
TextChatService.OnIncomingMessage = function(message)
    local player = Players:FindFirstChild(message.TextSource.Name)
    if player then
        onChatMessage(player, message.Text)
    end
end

