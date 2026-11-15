-- ==========================================
-- KEREN HUB - OFFICE WORKER ULTIMATE BOT (FINAL SYNC TARGET)
-- ==========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local JobEvents = ReplicatedStorage:WaitForChild("JobEvents")
local CorrectAnswer = JobEvents:WaitForChild("CorrectAnswer")
local GenerateQuestion = JobEvents:WaitForChild("GenerateQuestion")
local AssignPrintJob = JobEvents:WaitForChild("AssignPrintJob")
local ClearPrintJob = JobEvents:WaitForChild("ClearPrintJob")
local ComputersFolder = Workspace:WaitForChild("Computers")

local AutoBotActive = true
local questionCounter = 0

print("[Keren Hub] Ultimate Office Bot (Synced Target Mode) Loaded!")

-- Fungsi utama lari ke printer berdasarkan target yang dikirim server
local function goToTargetPrinter(targetPrinterObj)
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then return end

        -- 1. Berdiri / lompat dulu dari kursi
        if humanoid.SeatPart then
            humanoid.Sit = false
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            task.wait(0.3)
        end

        local targetPart = nil
        local targetPrompt = nil

        -- Jika server ngirim objek printer langsung
        if typeof(targetPrinterObj) == "Instance" then
            targetPart = targetPrinterObj:FindFirstChild("Part") or targetPrinterObj:FindFirstChildOfClass("BasePart")
            targetPrompt = targetPrinterObj:FindFirstChildOfClass("ProximityPrompt", true)
        elseif typeof(targetPrinterObj) == "number" or typeof(targetPrinterObj) == "string" then
            -- Kalau server ngirim angka/nama (misal "Print_2" atau angka 2)
            local printerModel = ComputersFolder:FindFirstChild("Print_" .. tostring(targetPrinterObj))
            if printerModel then
                targetPart = printerModel:FindFirstChild("Part") or printerModel:FindFirstChildOfClass("BasePart")
                targetPrompt = printerModel:FindFirstChildOfClass("ProximityPrompt", true)
            end
        end

        -- Kalau target dari server valid, langsung teleport & interaksi
        if targetPart then
            hrp.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.3)
            if targetPrompt then
                fireproximityprompt(targetPrompt)
            end
            print("[Keren Hub] Sukses sampai di printer tujuan dari server!")
        else
            -- Fallback darurat: kalau argumen kosong, cari printer yang prompt-nya aktif
            print("[Keren Hub] Mencari printer aktif alternatif...")
            for i = 1, 5 do
                local pModel = ComputersFolder:FindFirstChild("Print_" .. i)
                if pModel then
                    local pPart = pModel:FindFirstChild("Part") or pModel:FindFirstChildOfClass("BasePart")
                    local pPrompt = pModel:FindFirstChildOfClass("ProximityPrompt", true)
                    if pPart and pPrompt then
                        hrp.CFrame = pPart.CFrame + Vector3.new(0, 3, 0)
                        task.wait(0.2)
                        fireproximityprompt(pPrompt)
                        break
                    end
                end
            end
        end
    end)
end

-- 1. AUTO SOLVER MATEMATIKA + COUNTER 6 KALI SOAL
GenerateQuestion.OnClientEvent:Connect(function(questionText, optionsList, sessionID)
    if not AutoBotActive then return end
    
    task.wait(math.random(8, 12) / 10)
    
    pcall(function()
        local cleanExpr = questionText:gsub("=.*", ""):gsub("[^%d%+%-]", "")
        local mathFunc = loadstring("return " .. cleanExpr)
        if not mathFunc then return end
        
        local success, result = pcall(mathFunc)
        if not success or not result then return end
        
        local targetVal = tostring(result)
        local selectedButtonID = nil

        for _, opt in ipairs(optionsList) do
            local optNum = opt.Text:gsub("%D", "")
            if optNum == targetVal or opt.Text == targetVal then
                selectedButtonID = opt.ID
                break
            end
        end

        if selectedButtonID then
            CorrectAnswer:FireServer(selectedButtonID, sessionID)
            questionCounter = questionCounter + 1
            print("[Keren Hub] Jawab Soal ke-" .. questionCounter .. " -> " .. targetVal)

            -- Pas udah 6 kali jawab, kalau server nge-trigger event print otomatis
            if questionCounter >= 6 then
                print("[Keren Hub] Siklus 6 soal tercapai!")
                questionCounter = 0
            end
        end
    end)
end)

-- 2. MENANGKAP EVENT PRINTER DARI SERVER BESERTA ARGUMENNYA
AssignPrintJob.OnClientEvent:Connect(function(assignedTarget)
    if not AutoBotActive then return end
    questionCounter = 0
    print("[Keren Hub] Tugas Print diterima dari server! Target:", assignedTarget)
    task.wait(0.4)
    goToTargetPrinter(assignedTarget)
end)
