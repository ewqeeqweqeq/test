local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local Clip = false
local originalProps = {}
local distanceInFront = 1
local transparency = 1
local makeAnchored = true

local function enableNoclip(character)
    local function noclipLoop()
        if Clip == false and character ~= nil then
            for _, child in pairs(character:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide == true then
                    child.CanCollide = false
                end
            end
        end
    end

    RunService.Stepped:Connect(noclipLoop)
end

local function checkMurderer()
    local roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
    local isMurderer = false
    for name, data in pairs(roles) do
        if name == player.Name and data.Role == "Murderer" then
            isMurderer = true
            break
        end
    end
    return isMurderer
end

local function getHRP(char)
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:IsA("BasePart") then return hrp end
    return nil
end

local function saveOriginal(humanoidRootPart)
    if not humanoidRootPart then return end
    if originalProps[humanoidRootPart] then return end
    originalProps[humanoidRootPart] = {
        Size = humanoidRootPart.Size,
        Anchored = humanoidRootPart.Anchored,
        CanCollide = humanoidRootPart.CanCollide,
        CFrame = humanoidRootPart.CFrame,
        Transparency = humanoidRootPart.Transparency
    }
end

local function restorePlayers()
    for hrp, props in pairs(originalProps) do
        if hrp and hrp.Parent then
            pcall(function()
                hrp.Size = props.Size
                hrp.Anchored = props.Anchored
                hrp.CanCollide = props.CanCollide
                hrp.CFrame = props.CFrame
                hrp.Transparency = props.Transparency
            end)
        end
    end
    originalProps = {}
end

local function makeCharacterInvisibleAndNonCollidable(char, distance)
    if not char then return end
    local hrp = getHRP(char)
    if hrp then
        local newSize = Vector3.new(distance, distance, distance)
        hrp.Size = newSize

        hrp.CanCollide = false
        hrp.Transparency = transparency
        hrp.Anchored = makeAnchored

        local lpChar = player and player.Character
        local lpHRP = getHRP(lpChar)
        if lpHRP then
            local targetPos = lpHRP.Position + (lpHRP.CFrame.LookVector * distanceInFront)
            local targetCFrame = CFrame.new(targetPos)
            hrp.CFrame = targetCFrame
        end
    end

    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Transparency = transparency
        end
        if part:IsA("MeshPart") and part.Name == "Head" then
            part.Transparency = transparency
            local face = part:FindFirstChild("face")
            if face then
                face.Transparency = transparency
            end
        end
    end
end

local function modifyPlayerHitboxes()
    local lpChar = player and player.Character
    local lpHRP = getHRP(lpChar)
    if not lpHRP then warn("Local player character/humanoid root part not found.") return end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            local char = plr.Character
            if char then
                local hrp = getHRP(char)
                if hrp then
                    saveOriginal(hrp)
                    makeCharacterInvisibleAndNonCollidable(char, distanceInFront)
                end
            end
        end
    end
end

local function equipKnifeAndStab()
    local knife = player.Backpack:FindFirstChild("Knife")
    if knife then
        knife.Parent = player.Character
        task.wait(0.2)

        local stabEvent = knife:FindFirstChild("Stab")
        if stabEvent and stabEvent:IsA("RemoteEvent") then
            local args = {"Slash"}
            stabEvent:FireServer(unpack(args))
        end
    end
end

local function main()
    enableNoclip(player.Character)

    while true do
        if checkMurderer() then
            modifyPlayerHitboxes()
            equipKnifeAndStab()
            wait(0.5)

        else
            restorePlayers()
            break 
        end
    end
end

main()
