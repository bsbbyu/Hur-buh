-- ==========================================
-- FUNGSI JALAN KE PRINTER (SCAN SETELAH BANGUN DARI KURSI)
-- ==========================================
local function walkToActivePrinter()
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then return end

        -- 1. BERSIHKAN DARI KURSI DULU (SUPAYA POSISI VALID)
        if humanoid.SeatPart then
            humanoid.Sit = false
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            task.wait(0.8) -- Kasih jeda santai biar animasi berdiri/loncatnya kelar dulu
        end

        local targetPrinterName = nil
        local targetPos = nil
        local targetPrompt = nil
        local activePrinters = {}

        -- 2. BARU DETEKSI PRINTER SETELAH KARAKTER BERDIRI & GAME READY
        local attempts = 0
        while #activePrinters == 0 and attempts < 10 do
            attempts = attempts + 1
            activePrinters = {}

            for i = 1, 5 do
                local pName = "Print_" .. i
                local printerModel = ComputersFolder:FindFirstChild(pName)
                if printerModel then
                    local prompt = printerModel:FindFirstChildOfClass("ProximityPrompt", true)
                    if prompt and prompt.Enabled then
                        table.insert(activePrinters, {name = pName, prompt = prompt})
                    end
                end
            end

            if #activePrinters == 0 then
                task.wait(0.3)
            end
        end

        if #activePrinters > 0 then
            print("• Proximity aktif terdeteksi (" .. #activePrinters .. " printer menyala)")
            targetPrinterName = activePrinters[1].name
            targetPos = PrinterCoordinates[targetPrinterName]
            targetPrompt = activePrinters[1].prompt
        end

        if targetPos and targetPrinterName then
            print("[Keren Hub] Menuju ke target: " .. targetPrinterName)
            
            local path = PathfindingService:CreatePath({
                AgentRadius = 2,
                AgentHeight = 5,
                AgentCanJump = true
            })

            path:ComputeAsync(hrp.Position, targetPos + Vector3.new(0, 0, 1.5))
            
            if path.Status == Enum.PathStatus.Success then
                local waypoints = path:GetWaypoints()
                for _, waypoint in ipairs(waypoints) do
                    humanoid:MoveTo(waypoint.Position)
                    if waypoint.Action == Enum.PathWaypointAction.Jump then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                    
                    local reached = false
                    local conn
                    conn = humanoid.MoveToFinished:Connect(function(isReached)
                        reached = true
                        if conn then conn:Disconnect() end
                    end)
                    
                    local t = tick()
                    while not reached and (tick() - t) < 0.8 do
                        task.wait(0.05)
                    end
                    if conn then conn:Disconnect() end
                end
            else
                humanoid:MoveTo(targetPos)
                task.wait(1.5)
            end

            task.wait(0.2)
            if targetPrompt and fireproximityprompt then
                fireproximityprompt(targetPrompt)
                print("• Semua lancar (Berhasil interaksi dengan " .. targetPrinterName .. ")")
            else
                local printerModel = ComputersFolder:FindFirstChild(targetPrinterName)
                if printerModel then
                    local fallbackPrompt = printerModel:FindFirstChildOfClass("ProximityPrompt", true)
                    if fallbackPrompt and fireproximityprompt then
                        fireproximityprompt(fallbackPrompt)
                        print("• Semua lancar (Fallback interaksi dengan " .. targetPrinterName .. ")")
                    end
                end
            end
        else
            print("[Keren Hub] Gagal mendeteksi printer aktif.")
        end
    end)
end
