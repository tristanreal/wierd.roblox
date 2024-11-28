local Players = game:GetService("Players")
local BadgeService = game:GetService("BadgeService")
local DataStoreService = game:GetService("DataStoreService")
local playerTimeDataStore = DataStoreService:GetDataStore("PlayerTimeData")

-- Badge IDs (replace these with actual Badge IDs from Roblox)
local BADGE_IDS = {
    Play = 123456789,         -- Badge for playing the game (replace with actual badge ID)
    OneHour = 234567890,      -- Badge for 1 hour
    TwoHours = 345678901,     -- Badge for 2 hours
    FourHours = 456789012,    -- Badge for 4 hours
    EightHours = 567890123,   -- Badge for 8 hours
    TwentyFourHours = 678901234, -- Badge for 24 hours
    SevenDays = 789012345,    -- Badge for 7 days
    MeetTheOwner = 890123456  -- Badge for meeting the owner (replace with actual badge ID)
}

-- The owner's username or user ID (you can use either)
local OWNER_USERNAME = "sub2itr"  -- Replace with your Roblox username

-- Kick message for players who break the rules
local KICK_MESSAGE = "The GAME SAYS DO NOTHING AND THAT'S IT!"

-- Function to track time and check if the player should earn a badge
local function trackTime(player)
    local startTime = tick()
    local lastTimePlayed = 0

    -- Check if the player has time saved
    local success, savedTime = pcall(function()
        return playerTimeDataStore:GetAsync(player.UserId)
    end)
    
    if success and savedTime then
        lastTimePlayed = savedTime
    end

    while true do
        wait(1)  -- Wait 1 second between checks
        local elapsedTime = tick() - startTime + lastTimePlayed
        local hours = math.floor(elapsedTime / 3600)
        local minutes = math.floor((elapsedTime % 3600) / 60)
        local seconds = math.floor(elapsedTime % 60)

        -- Update player’s UI with the time (to be done on the client side)
        -- Send the current time to the client (See Client-side code below)
        player:SetAttribute("TimeElapsed", elapsedTime)

        -- Check if they should earn a badge
        if elapsedTime >= 604800 and not BadgeService:UserHasBadge(player.UserId, BADGE_IDS.SevenDays) then  -- 604800 seconds = 7 days
            BadgeService:AwardBadge(player.UserId, BADGE_IDS.SevenDays)
        elseif hours >= 24 and not BadgeService:UserHasBadge(player.UserId, BADGE_IDS.TwentyFourHours) then
            BadgeService:AwardBadge(player.UserId, BADGE_IDS.TwentyFourHours)
        elseif hours >= 8 and not BadgeService:UserHasBadge(player.UserId, BADGE_IDS.EightHours) then
            BadgeService:AwardBadge(player.UserId, BADGE_IDS.EightHours)
        elseif hours >= 4 and not BadgeService:UserHasBadge(player.UserId, BADGE_IDS.FourHours) then
            BadgeService:AwardBadge(player.UserId, BADGE_IDS.FourHours)
        elseif hours >= 2 and not BadgeService:UserHasBadge(player.UserId, BADGE_IDS.TwoHours) then
            BadgeService:AwardBadge(player.UserId, BADGE_IDS.TwoHours)
        elseif hours >= 1 and not BadgeService:UserHasBadge(player.UserId, BADGE_IDS.OneHour) then
            BadgeService:AwardBadge(player.UserId, BADGE_IDS.OneHour)
        elseif not BadgeService:UserHasBadge(player.UserId, BADGE_IDS.Play) then
            BadgeService:AwardBadge(player.UserId, BADGE_IDS.Play)
        end
    end
end

-- Function to check if the player is in the same server as the owner (sub2itr)
local function checkMeetOwnerBadge(player)
    -- Check if the player is in the same server as the owner
    if player.Name == OWNER_USERNAME then
        return  -- Skip if the player is the owner themselves
    end

    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer.Name == OWNER_USERNAME then
            -- Award the "Meet the Owner" badge if the player is in the same server as the owner
            if not BadgeService:UserHasBadge(player.UserId, BADGE_IDS.MeetTheOwner) then
                BadgeService:AwardBadge(player.UserId, BADGE_IDS.MeetTheOwner)
            end
            break
        end
    end
end

-- Function to kick the player if they move or jump
local function monitorPlayerActions(player)
    -- Check if the player moves or jumps
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local lastPosition = character.HumanoidRootPart.Position
    local lastJump = humanoid:GetState()

    -- Monitor player movement, jumping, and chat
    local connection

    -- Detect player movement
    connection = player.CharacterAdded:Connect(function()
        local humanoid = character:WaitForChild("Humanoid")
        local hrp = character:WaitForChild("HumanoidRootPart")

        humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
            if humanoid:GetState() ~= Enum.HumanoidStateType.Seated then
                -- If the player moves, kick them
                player:Kick(KICK_MESSAGE)
            end
        end)
    end)

    -- Detect if they chat or press keys
    player.Chatted:Connect(function(message)
        player:Kick(KICK_MESSAGE)
    end)
end

-- When a player joins, start monitoring them
Players.PlayerAdded:Connect(function(player)
    -- Initialize player's time tracking
    trackTime(player)

    -- Monitor player's actions
    monitorPlayerActions(player)

    -- Check if the player is in the same server as the owner (sub2itr)
    checkMeetOwnerBadge(player)
end)

-- Save player time when they leave
Players.PlayerRemoving:Connect(function(player)
    local elapsedTime = player:GetAttribute("TimeElapsed") or 0

    -- Save the time to the DataStore
    pcall(function()
        playerTimeDataStore:SetAsync(player.UserId, elapsedTime)
    end)
end)

