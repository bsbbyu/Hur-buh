-- ==========================================
-- KEREN HUB - ULTIMATE OFFICE BOT (DEBUG SCANNER MODE)
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

print("[Keren Hub] Ultimate Office Bot (Debug Scanner) Loaded!")

-- ==========================================
- FUNGSI JALAN & DEBUG SCANNER
-- ==========================================
local function walkToActivePrinter()
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then return end

        if humanoid.SeatPart then
            humanoid.Sit = false
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            task.wait(0.6)
        end

        print("[Keren Hub DEBUG] Memulai scan printer...")

        local targetPrinterName = nil
        local targetPos = nil
        local targetPrompt = nil

        for i = 1, 5 do
            local pName = "Print_" .. i
            local printerModel = ComputersFolder:FindFirstChild(pName)
            if printerModel then
                local part = printerModel:FindFirstChild("Part")
                local attachment = part and part:FindFirstChild("Attachment")
                local prompt = printerModel:FindFirstChildOfClass("ProximityPrompt", true)

                -- Cetak status komponen ke F9
                print("[Keren Hub DEBUG] " .. pName .. " -> Part:", tostring(part), "| Attachment:", tostring(attachment), "| Prompt:", tostring(prompt))

                if attachment and prompt then
                    targetPrinterName = pName
                    targetPos = PrinterCoordinates[pName]
                    targetPrompt = prompt
                    print("[Keren Hub DEBUG] -> Target valid terpilih:", targetPrinterName)
                    break
                end
            else
                print("[Keren Hub DEBUG] Model " .. pName .. " tidak ditemukan di folder Computers!")
            end
        end

        if targetPos then
            print("[Keren Hub] Berjalan menuju " .. targetPrinterName .. "...")
            humanoid:MoveTo(targetPos)
            task.wait(2) -- Tunggu karakter sampai di dekat printer

            if targetPrompt and fireproximityprompt then
                fireproximityprompt(targetPrompt)
                print("[Keren Hub] Berhasil eksekusi prompt di:", targetPrinterName)
            else
                print("[Keren Hub] Warning: Target prompt atau fungsi fireproximityprompt tidak tersedia.")
            end
        else
            print("[Keren Hub DEBUG] GAGAL: Tidak ada satupun printer yang memenuhi syarat attachment/prompt saat discan!")
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
                    
                    print("[Keren Hub] Sukses Jawab Soal -> Jawaban:", targetAnswer)
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
    print("[Keren Hub] Tugas Print diterima! Memulai scan printer...")
    task.wait(0.5)
    walkToActivePrinter()
end)

print("[Keren Hub] Ultimate Office Bot siap memantau F9!")
