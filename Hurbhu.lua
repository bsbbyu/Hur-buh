-- ==========================================
-- KEREN HUB - OFFICE WORKER FULL AUTO (JOB + SOLVE + MOVE)
-- ==========================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local AutoFarmActive = true
local isWorking = false

-- Fungsi cari kursi terdekat buat duduk balik
local function sitOnNearestChair()
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then return end

        -- Kalau sudah duduk, jangan dipaksa duduk lagi
        if humanoid.SeatPart then return end

        local closestSeat = nil
        local shortestDist = math.huge

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if (obj:IsA("Seat") or obj:IsA("VehicleSeat")) and obj.Occupant == nil then
                local dist = (hrp.Position - obj.Position).Magnitude
                if dist < shortestDist and dist < 25 then -- Radius 25 stud cari kursi sekitar meja
                    shortestDist = dist
                    closestSeat = obj
                end
            end
        end

        if closestSeat then
            hrp.CFrame = closestSeat.CFrame + Vector3.new(0, 2, 0)
            task.wait(0.4)
            closestSeat:Sit(humanoid)
            print("[Keren Hub] Kembali duduk di kursi terdekat!")
        end
    end)
end

-- Fungsi jalan / tween ke printer / komputer tujuan
local function walkToPrinter()
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- Cari objek Printer / Komputer di Workspace (sesuaikan folder game jika ada)
        local computersFolder = Workspace:FindFirstChild("Computers") or Workspace:FindFirstChild("Printers")
        if not computersFolder then
            -- Kalau foldernya gak ketemu, cari part interaktif di workspace
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and (obj.Parent.Name:lower():find("printer") or obj.Parent.Name:lower():find("computer")) then
                    hrp.CFrame = obj.Parent.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.5)
                    fireproximityprompt(obj)
                    return
                end
            end
            return
        end

        -- Kalau foldernya ada, datengin satu-satu yang ada prompt-nya
        for _, comp in ipairs(computersFolder:GetChildren()) do
            local part = comp:FindFirstChild("Part") or comp:FindFirstChildOfClass("BasePart")
            local prompt = comp:FindFirstChildOfClass("ProximityPrompt", true)
            
            if part then
                hrp.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.5)
                if prompt then
                    fireproximityprompt(prompt)
                end
                break
            end
        end
    end)
end

-- Fungsi Utama Baca Soal & Jawab
local function solveOfficeTask()
    pcall(function()
        local workGui = PlayerGui:FindFirstChild("WorkGui")
        if not workGui then 
            -- Kalau WorkGui ilang (lagi gak ngerjain soal), pastikan balik duduk
            isWorking = false
            sitOnNearestChair()
            return 
        end

        isWorking = true

        -- 1. Baca soal dari QuestionLabel atau TextLabel
        local questionLabel = workGui:FindFirstChild("QuestionLabel") or workGui:FindFirstChild("TextLabel")
        if not questionLabel then return end

        local rawText = questionLabel.Text
        if not rawText or rawText == "" then return end

        -- Pastikan hanya memproses soal penjumlahan atau pengurangan
        if not (rawText:find("%+") or rawText:find("%-")) then return end

        -- 2. Bersihkan teks dan hitung jawaban secara otomatis
        local cleanExpr = rawText:gsub("=.*", ""):gsub("[^%d%+%-]", "")
        local mathFunc = loadstring("return " .. cleanExpr)
        if not mathFunc then return end

        local success, result = pcall(mathFunc)
        if not success or not result then return end
        
        local targetAnswer = tostring(result)

        -- Jeda manusia natural biar aman dari deteksi server
        task.wait(math.random(8, 12) / 10)

        -- 3. Cari container Frame tempat AnswerButton berada
        local frame = workGui:FindFirstChild("Frame")
        if not frame then return end

        -- 4. Cari tombol yang cocok dan klik otomatis
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
                    
                    print("[Keren Hub] Sukses Jawab: " .. rawText .. " -> Jawaban: " + targetAnswer)
                    task.wait(1.2)
                    
                    -- Sesudah selesai jawab, otomatis balik duduk sebentar nunggu soal berikutnya
                    task.wait(1)
                    sitOnNearestChair()
                    break
                end
            end
        end
    end)
end

-- Loop utama auto worker
task.spawn(function()
    while AutoFarmActive do
        task.wait(1.5)
        if not isWorking then
            -- Kalau lagi gak ngerjain soal, cek apakah perlu jalan ke printer atau balik duduk
            solveOfficeTask()
        else
            solveOfficeTask()
        end
    end
end)

print("[Keren Hub] Full Auto Walk & Solve Loaded!")
