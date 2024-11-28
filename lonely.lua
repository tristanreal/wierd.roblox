local Players = game:GetService("Players")

-- Function to create a clone of a friend
local function createClone(friendModel, position)
    local clone = friendModel:Clone()
    clone.Name = friendModel.Name .. "'s Clone"
    clone.Parent = workspace
    clone.HumanoidRootPart.CFrame = CFrame.new(position)
    return clone
end

-- Function to make clones follow the player and talk
local function followAndTalk(clone, targetPlayer)
    -- Follow the player
    local runService = game:GetService("RunService")
    local followConnection
    followConnection = runService.Heartbeat:Connect(function()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
            clone.Humanoid:MoveTo(targetPosition)
        else
            followConnection:Disconnect()
        end
    end)

    -- Repeatedly say comforting text
    while clone.Parent do
        local head = clone:FindFirstChild("Head")
        if head then
            local dialog = Instance.new("Dialog", head)
            dialog.InitialPrompt = "You're lonely? Not anymore!"
            wait(3) -- Adjust the message frequency
            dialog:Destroy()
        end
        wait(2)
    end
end

-- Main function to monitor chat
Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(message)
        if string.find(message:lower(), "i'm so lonely") or string.find(message:lower(), "man, i'm so lonely") then
            if player.Friends then
                local playerPosition = player.Character and player.Character:FindFirstChild("HumanoidRootPart").Position or Vector3.new(0, 10, 0)
                for _, friendId in ipairs(player.Friends:GetChildren()) do
                    local friend = Players:GetPlayerByUserId(friendId.Value)
                    if friend and friend.Character then
                        local clone = createClone(friend.Character, playerPosition + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
                        followAndTalk(clone, player)
                    end
                end
            end
        end
    end)
end)
