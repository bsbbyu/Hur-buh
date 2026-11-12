-- ==========================================
-- KEREN HUB - OFFICE WORKER (GITHUB WINDUI EDITION)
-- ==========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Load WindUI Library resmi dari GitHub
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/main.lua"))()
end)

if not success or not WindUI then
    warn("[Keren Hub] Gagal memuat WindUI dari GitHub! Menggunakan fallback UI.")
    return
end

-- Buat Window Utama WindUI
local Window = WindUI:CreateWindow({
    Title = "Keren Hub • Office Worker",
    Icon = "briefcase",
    Author = "Auto Farm System",
    Folder = "KerenHubConfig",
    Size = UDim2.fromOffset(450, 300),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 140,
    HasOutline = true,
})

-- Buat Tab Menu
local MainTab = Window:Tab({
    Title = "Auto Farm",
    Icon = "home",
})

-- Section Status & Informasi
local StatusSection = MainTab:Section({
    Title = "Status Monitor",
    Content = "Sistem otomatis kantor Drag Drive Simulator.",
})

local StatusParagraph = StatusSection:Paragraph({
    Title = "Current Status",
    Desc = "Status: Standby (Mati 🔴)",
})

-- ==========================================
-- LOGIC AUTO-FARM OFFICE WORKER
-- ==========================================
local AutoOfficeEnabled = false
local JobEvents = ReplicatedStorage:WaitForChild("JobEvents")
local ComputersFolder = Workspace:WaitForChild("Computers")
local CurrentTargetComputer = nil

-- Dengerin event printer dari server
JobEvents:WaitForChild("AssignPrintJob").OnClientEvent:Connect(function(computerName)
    CurrentTargetComputer = computerName
    StatusParagraph:SetDesc("Status: Menuju ke " .. tostring(computerName))
end)

JobEvents:WaitForChild("ClearPrintJob").OnClientEvent:Connect(function()
    CurrentTargetComputer = nil
    StatusParagraph:SetDesc("Status: Tugas Selesai, Menunggu Print Baru...")
end)

-- Anti-AFK
task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    end)
end)

-- Join Team Office Worker
local function selectOfficeJob()
    pcall(function()
        local TeamChange = JobEvents:FindFirstChild("TeamChangeRequest")
        if TeamChange then
            TeamChange:FireServer("Office Worker", 11378976, 1, 0, "Detector")
            task.wait(2)
        end
    end)
end

-- Teleport halus langsung ke depan part printer (Biar anti nyangkut jalan)
local function teleportToPart(targetPart)
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp or not targetPart then return end

        hrp.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
        task.wait(0.3)
    end)
end

-- Interaksi ProximityPrompt Natural
local function interactPrompt(prompt)
    if not prompt then return end
    local holdTime = prompt.HoldDuration or 0
    if holdTime > 0 then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(holdTime + 0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    else
        if fireproximityprompt then
            fireproximityprompt(prompt)
        end
    end
end

-- MAIN LOOP AUTO FARM
task.spawn(function()
    while true do
        if AutoOfficeEnabled then
            pcall(function()
                if not (LocalPlayer.Team and LocalPlayer.Team.Name == "Office Worker") then
                    StatusParagraph:SetDesc("Status: Masuk ke Tim Office Worker...")
                    selectOfficeJob()
                end

                if CurrentTargetComputer then
                    local targetModel = ComputersFolder:FindFirstChild(CurrentTargetComputer)
                    if targetModel and targetModel:FindFirstChild("Part") then
                        local targetPart = targetModel.Part
                        local prompt = targetPart:FindFirstChildOfClass("ProximityPrompt")

                        StatusParagraph:SetDesc("Status: Teleport ke " .. CurrentTargetComputer)
                        teleportToPart(targetPart)
                        task.wait(0.5)
                        
                        if prompt then
                            StatusParagraph:SetDesc("Status: Memproses Dokumen Printer...")
                            interactPrompt(prompt)
                        end
                    end
                else
                    StatusParagraph:SetDesc("Status: Standby Menunggu Job Printer...")
                end
            end)
        else
            StatusParagraph:SetDesc("Status: Standby (Mati 🔴)")
        end
        task.wait(1)
    end)
end)

-- Tombol Toggle WindUI
MainTab:Toggle({
    Title = "Auto Farm Office",
    Desc = "Otomatis ambil tugas print & teleport interaksi",
    Value = false,
    Callback = function(state)
        AutoOfficeEnabled = state
        if AutoOfficeEnabled then
            StatusParagraph:SetDesc("Status: Auto Farm Aktif 🟢")
        else
            StatusParagraph:SetDesc("Status: Dimatikan Manual 🔴")
        end
    end
})

-- Notifikasi Berhasil Load
WindUI:Notify({
    Title = "Keren Hub Loaded",
    Content = "Office Worker WindUI berhasil dimuat!",
    Duration = 3
})
