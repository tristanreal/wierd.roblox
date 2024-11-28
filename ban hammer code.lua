local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local BanStore = DataStoreService:GetDataStore("BannedPlayers")

local OWNER_USERNAME = "sub2itr" -- Your username
local TOOL_NAME = "BanHammer" -- Name of the hammer tool

-- Function to check if a player is the owner or has the special username
local function isOwner(player)
    return player.UserId == game.CreatorId or player.Name == OWNER_USERNAME
end

-- Function to ban a player
local function banPlayer(playerToBan)
    BanStore:SetAsync(playerToBan.UserId, true)
    playerToBan:Kick("You have been permanently banned by the game owner.")
end

-- Check if a player is banned when they join
Players.PlayerAdded:Connect(function(player)
    local isBanned = BanStore:GetAsync(player.UserId)
    if isBanned then
        player:Kick("You are banned from this game.")
    end
end)

-- Give the ban hammer to the owner
Players.PlayerAdded:Connect(function(player)
    if isOwner(player) then
        local hammer = game.ServerStorage:FindFirstChild(TOOL_NAME):Clone()
        hammer.Parent = player.Backpack
    end
end)
