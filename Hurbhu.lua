-- ==========================================
-- KEREN HUB - ULTIMATE OFFICE BOT (FULL SMOOTH & IGNORE LOW WALLS)
-- ==========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local JobEvents = ReplicatedStorage:WaitForChild("JobEvents")
local AssignPrintJob = JobEvents:WaitForChild("AssignPrintJob")
local ComputersFolder = Workspace:WaitForChild("Computers")

local AutoFarmActive = true

-- Data Koordinat Pasti Printer
local PrinterCoordinates = {
    ["Print_1"] = Vector3.new(-6008.849, 5.956, -210.805),
    ["Print_2"] = Vector3.new(-6008.840, 5.966, -224.522),
    ["Print_3"] = Vector3.new(-6008.839, 5.979, -238.361),
    ["Print_4"] = Vector3.new(-5868.426, 5.982, -213.191),
    ["Print_5"] = Vector3.new(-5868.429, 5.956, -249.965),
}

print("==========================================")
print("[Keren Hub] Ultimate Office Bot Active (No Low-Wall Stutter Mode)!")
print("==========================================")

-- ==========================================
-- FUNGSI JALAN LANGSUNG (CUEK BABLAS TEMBOK RENDAH)
-- ==========================================
local function walkDirectIgnoreLowWalls(printerName)
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then return end

        -- 1. Lepas dari kursi dulu & beri waktu transisi
        if humanoid.SeatPart then
            humanoid.Sit = false
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            task.wait(0.6)
        end

        local targetPos = PrinterCoordinates[printerName]
        local printerModel = ComputersFolder:FindFirstChild(printerName)
        local targetPrompt = printerModel and printerModel:FindFirstChildOfClass("ProximityPrompt", true)

        if targetPos then
            print("[Keren Hub] Jalan lurus bablas ke " .. printerName)
            
            local destination = targetPos + Vector3.new(0, 0, 2)
            
            -- Set state humanoid ke berjalan bebas langsung ke tujuan tanpa waypoint
            humanoid:MoveTo(destination)
            
            -- Loop pemantau: paksa arahkan pandangan/gerakan lurus ke tujuan tanpa takut tembok rendah
            local startTime = tick()
            while (hrp.Position - destination).Magnitude > 3 and (tick() - startTime) < 8 do
                if humanoid.MoveDirection.Magnitude == 0 then
                    humanoid:MoveTo(destination)
                end
                
                -- Jaga rotasi hadap tetap lurus ke target printer
                local lookAtPos = Vector3.new(destination.X, hrp.Position.Y, destination.Z)
                hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(hrp.Position, lookAtPos), 0.1)
                
                task.wait(0.05)
            end

            task.wait(0.2)
            if targetPrompt and fireproximityprompt then
                fireproximityprompt(targetPrompt)
                print("[Keren Hub] Berhasil interaksi dengan " .. printerName)
            else
                print("[Keren Hub] Warning: Gagal mengeksekusi fireproximityprompt.")
            end
        end
    end)
end

-- ==========================================
-- FUNGSI UTAMA: DETEKSI & JALAN KE PRINTER AKTIF
-- ==========================================
local function walkToActivePrinter()
    pcall(function()
        local targetPrinterName = nil
        local foundActive = false

        -- Sistem Polling / Retry Deteksi (Memastikan server game sudah siapin status prompt)
        local attempts = 0
        while not foundActive and attempts < 15 do
            attempts = attempts + 1

            for i = 1, 5 do
                local pName = "Print_" .. i
                local printerModel = ComputersFolder:FindFirstChild(pName)
                
                if printerModel then
                    local isPromptEnabled = false
                    for _, descendant in ipairs(printerModel:GetDescendants()) do
                        if descendant:IsA("ProximityPrompt") then
                            if descendant.Enabled then
                                isPromptEnabled = true
                            end
                            break
                        end
                    end

                    -- Ambil printer pertama yang status prompt-nya aktif (Enabled = true)
                    if isPromptEnabled then
                        targetPrinterName = pName
                        foundActive = true
                        break
                    end
                end
            end

            if not foundActive then
                task.wait(0.4)
            end
        end

        -- Eksekusi Jalan Bablas jika Tujuan Ditemukan
        if targetPrinterName then
            print("[Keren Hub] Menuju ke tujuan aktif: " .. targetPrinterName)
            walkDirectIgnoreLowWalls(targetPrinterName)
        else
            print("[Keren Hub] Gagal mendeteksi tujuan printer aktif (Waktu tunggu habis).")
        end
    end)
end

-- ==========================================
-- FUNGSI AUTO SOLVER GUI (MATEMATIKA)
-- ==========================================
local function solveOfficeTask()
    pcall(function()
        local workGui = PlayerGui:FindFirstChild("WorkGui")
        if not workGui then return end

        local questionLabel = workGui:FindFirstChild("QuestionLabel") or workGui:FindFirstChild("TextLabel")
        if not questionLabel then return end

        local rawText = questionLabel.Text
        if not rawText or rawText == "" then return end

        if not (rawText:find("%+") or rawText:find("%-")) then return end

        local cleanExpr = rawText:gsub("=.*", ""):gsub("[^%d%+%-]", "")
        local mathFunc = loadstring("return " .. cleanExpr)
        if not mathFunc then return end

        local success, result = pcall(mathFunc)
        if not success or not result then return end
        
        local targetAnswer = tostring(result)

        task.wait(math.random(10, 15) / 10)

        local frame = workGui:FindFirstChild("Frame")
        if not frame then return end

        for _, obj in ipairs(frame:GetChildren()) do
            if obj.Name == "AnswerButton" or obj:IsA("TextButton") then
                local btnText = ""
                if obj:IsA("TextButton") then
                    btnText = obj.Text
                else
                    local lbl = obj:FindFirstChildOfClass("TextLabel")
                    if lbl then btnText = lbl.Text end
                end

                local cleanBtnText = btnText:gsub("%D", "")

                if cleanBtnText == targetAnswer or btnText == targetAnswer then
                    if obj:IsA("GuiButton") then
                        if firesignal then
                            firesignal(obj.MouseButton1Click)
                            firesignal(obj.Activated)
                        else
                            obj:Activate()
                        end
                    end
                    
                    task.wait(1.2)
                    break
                end
            end
        end
    end)
end

-- ==========================================
-- LOOP & EVENT LISTENER UTAMA
-- ==========================================
task.spawn(function()
    while AutoFarmActive do
        task.wait(1)
        solveOfficeTask()
    end
end)

AssignPrintJob.OnClientEvent:Connect(function()
    if not AutoFarmActive then return end
    task.wait(0.5)
    walkToActivePrinter()
end)
