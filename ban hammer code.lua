local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local OWNER_USERNAME = "sub2itr" -- Your username
local TOOL_NAME = "BanHammer" -- Name of the Ban Hammer tool

-- Function to check if a player is authorized to use the tool
local function isAuthorized(player)
    return player.UserId == game.CreatorId or player.Name == OWNER_USERNAME
end

-- Handle giving the tool to authorized players
Players.PlayerAdded:Connect(function(player)
    if isAuthorized(player) then
        -- Give the tool to the player
        local tool = ServerStorage:FindFirstChild(TOOL_NAME)
        if tool then
            local clonedTool = tool:Clone()
            clonedTool.Parent = player.Backpack
        end
    end
end)

-- Handle kicking unauthorized users if they somehow equip the hammer
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and child.Name == TOOL_NAME then
                if not isAuthorized(player) then
                    player:Kick("You do not have permission for the Ban Hammer!")
                end
            end
        end)
    end)
end)
