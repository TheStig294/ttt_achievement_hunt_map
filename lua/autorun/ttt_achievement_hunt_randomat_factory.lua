if not ((game.GetMap() == "ttt_achievement_hunt" or game.GetMap() == "ttt_achievement_hunt_final") and engine.ActiveGamemode() == "terrortown") then return end

-- Map logic for running the custom randomat in the map ttt_achievement_hunt
if SERVER then
    util.AddNetworkString("AHRandomatName")
    util.AddNetworkString("AHRandomatNamed")
    util.AddNetworkString("AHRandomatAlert")
    util.AddNetworkString("AHRandomatAlertSilent")
    local usedRandomatParts = {}

    -- Adding the cause/effect to the randomat part inserted
    hook.Add("EntityRemoved", "AHRandomatPartInsert", function(ent)
        local name = ent:GetName()
        if not isstring(name) then return end
        -- if GetRoundState() ~= ROUND_ACTIVE then return end
        if not (GetGlobalBool("AHEffectInserted") or GetGlobalBool("AHCauseInserted")) then return end

        if string.StartWith(name, "cause_") then
            local id = string.sub(name, 7, #name)
            id = tonumber(id)

            -- Remove incompatible cause and effects
            if id == 7 then
                for _, e in ipairs(ents.FindByName("effect_*")) do
                    local removeName = e:GetName()

                    if removeName == "effect_5" or removeName == "effect_6" then
                        -- Changing the ent's name so this hook isn't called
                        e:SetName("to_remove")
                        e:Remove()
                    end
                end
            elseif id == 8 then
                for _, e in ipairs(ents.FindByName("effect_5")) do
                    -- Changing the ent's name so this hook isn't called
                    e:SetName("to_remove")
                    e:Remove()
                end
            end

            SetGlobalInt("AHRandomatCause", id)
            table.insert(usedRandomatParts, name)
        elseif string.StartWith(name, "effect_") then
            local id = string.sub(name, 8, #name)
            id = tonumber(id)

            -- Remove incompatible cause and effects
            if id == 5 then
                for _, e in ipairs(ents.FindByName("cause_*")) do
                    local removeName = e:GetName()

                    if removeName == "cause_7" or removeName == "cause_8" then
                        -- Changing the ent's name so this hook isn't called
                        e:SetName("to_remove")
                        e:Remove()
                    end
                end
            elseif id == 6 then
                for _, e in ipairs(ents.FindByName("cause_7")) do
                    -- Changing the ent's name so this hook isn't called
                    e:SetName("to_remove")
                    e:Remove()
                end
            end

            SetGlobalInt("AHRandomatEffect", id)
            table.insert(usedRandomatParts, name)
        end
    end)

    hook.Add("TTTPrepareRound", "AHResetRandomatFactory", function()
        SetGlobalBool("AHRandomatComputerButtonLocked", false)
        SetGlobalInt("AHRandomatCause", 0)
        SetGlobalInt("AHRandomatEffect", 0)
        SetGlobalString("AHRandomatName", "noname")

        -- For enabling the "ShouldCollide" hook to work as a randomat cause
        for _, ply in ipairs(player.GetAll()) do
            ply:SetCustomCollisionCheck(true)
        end

        -- Removes all randomat parts that need to be removed
        timer.Simple(1, function()
            for _, ent in ipairs(ents.FindByName("effect_*")) do
                local name = ent:GetName()
                if not isstring(name) then continue end

                -- Remove all parts if make-a-randomat is disabled
                if GetGlobalBool("ttt_achievement_hunt_block_make_a_randomat") then
                    ent:Remove()
                    continue
                end
        
                -- Remove the "Trigger a randomat" effect if the randomat isn't installed
                if name == "effect_6" and not Randomat then
                    ent:Remove()
                    continue
                end

                -- Remove all used in a previous round
                for _, partName in ipairs(usedRandomatParts) do
                    if name == partName then
                        ent:Remove()
                        break
                    end
                end
            end

            for _, ent in ipairs(ents.FindByName("cause_*")) do
                local name = ent:GetName()
                if not isstring(name) then continue end

                -- Remove all parts if make-a-randomat is disabled
                if GetGlobalBool("ttt_achievement_hunt_block_make_a_randomat") then
                    ent:Remove()
                    continue
                end

                -- Remove all used in a previous round
                for _, partName in ipairs(usedRandomatParts) do
                    if name == partName then
                        ent:Remove()
                        break
                    end
                end
            end
        end)
    end)

    local randomatButton
    local namingPlayer

    hook.Add("TTTPrepareRound", "AHApplyNearPlayerHook", function()
        -- For enabling the "ShouldCollide" hook to work as a randomat cause
        timer.Simple(1, function()
            for _, ply in ipairs(player.GetAll()) do
                ply:SetCustomCollisionCheck(true)
                namingPlayer = nil
            end
        end)
    end)

    -- Preventing players from pressing the make randomat button for various reasons
    hook.Add("PlayerUse", "AHPressMakeARandomatButton", function(ply, ent)
        local name = ent:GetName()
        if not isstring(name) then return end
        if name ~= "button_randomat_computer" then return end

        if GetGlobalInt("AHRandomatCause", 0) == 0 or GetGlobalInt("AHRandomatEffect", 0) == 0 then
            ply:PrintMessage(HUD_PRINTCENTER, "Choose a cause and effect first!")

            return false
        elseif GetGlobalBool("AHRandomatComputerButtonLocked") and ply ~= namingPlayer then
            ply:PrintMessage(HUD_PRINTCENTER, "Someone is naming their randomat!")

            return false
        elseif GetGlobalString("AHRandomatName", "noname") == "noname" and ply ~= namingPlayer then
            net.Start("AHRandomatName")
            net.Send(ply)
            SetGlobalBool("AHRandomatComputerButtonLocked", true)
            randomatButton = ent
            namingPlayer = ply
            ply:PrintMessage(HUD_PRINTCENTER, "Name your randomat!")

            return false
        end
    end)

    net.Receive("AHRandomatNamed", function(len, ply)
        SetGlobalString("AHRandomatName", net.ReadString())
        SetGlobalBool("AHRandomatComputerButtonLocked", false)
        randomatButton:Fire("Press")
    end)
end

if CLIENT then
    net.Receive("AHRandomatName", function()
        local ply = LocalPlayer()
        -- Fade out the screen
        ply:ScreenFade(SCREENFADE.STAYOUT, Color(0, 0, 0, 200), 1, 1)
        -- Create basic frame
        local Frame = vgui.Create("DFrame")
        local width = 500
        local height = 100
        Frame:SetPos(ScrW() / 2 - width / 2, ScrH() / 2 - height / 2)
        Frame:SetSize(width, height)
        Frame:SetTitle("Name your randomat! (Press 'Enter' when done)")
        Frame:SetVisible(true)
        Frame:MakePopup()
        Frame:SetDraggable(false)
        Frame:ShowCloseButton(false)
        Frame:MakePopup()
        -- Create the name input
        local randomatName
        local NameEntry = vgui.Create("DTextEntry", Frame)
        local nameWidth = 450
        local nameHeight = 25
        NameEntry:SetPos(width / 2 - nameWidth / 2, height / 2 - nameHeight / 2)
        NameEntry:SetSize(nameWidth, nameHeight)
        NameEntry:SetText("(Enter name here)")

        -- Make the text field clear when you click into it.
        NameEntry.OnGetFocus = function(self)
            self:SetText("")
        end

        NameEntry.OnEnter = function(self)
            randomatName = self:GetValue()
            net.Start("AHRandomatNamed")
            net.WriteString(randomatName)
            net.SendToServer()
            Frame:Close()
            ply:ScreenFade(SCREENFADE.PURGE, Color(0, 0, 0, 200), 0, 0)
        end
    end)

    local memeASCII = {"░░░░░░░░▄▄▄▀▀▀▄▄███▄░░░░░░░░░░░░░░\n░░░░░▄▀▀░░░░░░░▐░▀██▌░░░░░░░░░░░░░\n░░░▄▀░░░░▄▄███░▌▀▀░▀█░░░░░░░░░░░░░\n░░▄█░░▄▀▀▒▒▒▒▒▄▐░░░░█▌░░░░░░░░░░░░\n░▐█▀▄▀▄▄▄▄▀▀▀▀▌░░░░░▐█▄░░░░░░░░░░░\n░▌▄▄▀▀░░░░░░░░▌░░░░▄███████▄░░░░░░\n░░░░░░░░░░░░░▐░░░░▐███████████▄░░░\n░░░░░le░░░░░░░▐░░░░▐█████████████▄\n░░░░toucan░░░░░░▀▄░░░▐█████████████▄ \n░░░░░░has░░░░░░░░▀▄▄███████████████ \n░░░░░arrived░░░░░░░░░░░░█▀██████░░", "░░█▀░░░░░░░░░░░▀▀███████░░░░░\n░░█▌░░░░░░░░░░░░░░░▀██████░░░\n░█▌░░░░░░░░░░░░░░░░███████▌░░\n░█░░░░░░░░░░░░░░░░░████████░░\n▐▌░░░░░░░░░░░░░░░░░▀██████▌░░\n░▌▄███▌░░░░▀████▄░░░░▀████▌░░\n▐▀▀▄█▄░▌░░░▄██▄▄▄▀░░░░████▄▄░\n▐░▀░░═▐░░░░░░══░░▀░░░░▐▀░▄▀▌▌\n▐░░░░░▌░░░░░░░░░░░░░░░▀░▀░░▌▌\n▐░░░▄▀░░░▀░▌░░░░░░░░░░░░▌█░▌▌\n░▌░░▀▀▄▄▀▀▄▌▌░░░░░░░░░░▐░▀▐▐░\n░▌░░▌░▄▄▄▄░░░▌░░░░░░░░▐░░▀▐░░\n░█░▐▄██████▄░▐░░░░░░░░█▀▄▄▀░░\n░▐░▌▌░░░░░░▀▀▄▐░░░░░░█▌░░░░░░\n░░█░░▄▀▀▀▀▄░▄═╝▄░░░▄▀░▌░░░░░░\n░░░▌▐░░░░░░▌░▀▀░░▄▀░░▐░░░░░░░\n░░░▀▄░░░░░░░░░▄▀▀░░░░█░░░░░░░\n░░░▄█▄▄▄▄▄▄▄▀▀░░░░░░░▌▌░░░░░░\n░░▄▀▌▀▌░░░░░░░░░░░░░▄▀▀▄░░░░░\n▄▀░░▌░▀▄░░░░░░░░░░▄▀░░▌░▀▄░░░\n░░░░▌█▄▄▀▄░░░░░░▄▀░░░░▌░░░▌▄▄\n░░░▄▐██████▄▄░▄▀░░▄▄▄▄▌░░░░▄░\n░░▄▌████████▄▄▄███████▌░░░░░▄\n░▄▀░██████████████████▌▀▄░░░░\n▀░░░█████▀▀░░░▀███████░░░▀▄░░\n░░░░▐█▀░░░▐░░░░░▀████▌░░░░▀▄░\n░░░░░░▌░░░▐░░░░▐░░▀▀█░░░░░░░▀\n░░░░░░▐░░░░▌░░░▐░░░░░▌░░░░░░░", "██████████▀▀▀▀▀▀▀▀▀▀▀▀▀██████████\n█████▀▀░░░░░░░░░░░░░░░░░░░▀▀█████\n███▀░░░░░░░░░░░░░░░░░░░░░░░░░▀███\n██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██\n█░░░░░░▄▄▄▄▄▄░░░░░░░░▄▄▄▄▄▄░░░░░█\n█░░░▄██▀░░░▀██░░░░░░██▀░░░▀██▄░░█\n█░░░██▄░░▀░░▄█░░░░░░█▄░░▀░░▄██░░█\n██░░░▀▀█▄▄▄██░░░██░░░██▄▄▄█▀▀░░██\n███░░░░░░▄▄▀░░░████░░░▀▄▄░░░░░███\n██░░░░░█▄░░░░░░▀▀▀▀░░░░░░░█▄░░░██\n██░░░▀▀█░█▀▄▄▄▄▄▄▄▄▄▄▄▄▄▀██▀▀░░██\n███░░░░░▀█▄░░█░░█░░░█░░█▄▀░░░░███\n████▄░░░░░░▀▀█▄▄█▄▄▄█▄▀▀░░░░▄████\n███████▄▄▄▄░░░░░░░░░░░░▄▄▄███████",
    "░░░░░░░░▀████▀▄▄░░░░░░░░░░░░░░▄█\n░░░░░░░░░░█▀░░░░▀▀▄▄▄▄▄░░░░▄▄▀▀█\n░░▄░░░░░░░░█░░░░░░░░░░▀▀▀▀▄░░▄▀\n░▄▀░▀▄░░░░░░▀▄░░░░░░░░░░░░░░▀▄▀\n▄▀░░░░█░░░░░█▀░░░▄█▀▄░░░░░░▄█\n▀▄░░░░░▀▄░░█░░░░░▀██▀░░░░░██▄█\n░▀▄░░░░▄▀░█░░░▄██▄░░░▄░░▄░░▀▀░█\n░░█░░▄▀░░█░░░░▀██▀░░░░▀▀░▀▀░░▄▀\n░█░░░█░░█░░░░░░▄▄░░░░░░░░░░░▄▀", 
    "░░░░░░░░░▄░░░░░░░░░░░░░░▄\n░░░░░░░░▌▒█░░░░░░░░░░░▄▀▒▌\n░░░░░░░░▌▒▒█░░░░░░░░▄▀▒▒▒▐\n░░░░░░░▐▄▀▒▒▀▀▀▀▄▄▄▀▒▒▒▒▒▐\n░░░░░▄▄▀▒░▒▒▒▒▒▒▒▒▒█▒▒▄█▒▐\n░░░▄▀▒▒▒░░░▒▒▒░░░▒▒▒▀██▀▒▌\n░░▐▒▒▒▄▄▒▒▒▒░░░▒▒▒▒▒▒▒▀▄▒▒▌\n░░▌░░▌█▀▒▒▒▒▒▄▀█▄▒▒▒▒▒▒▒█▒▐\n░▐░░░▒▒▒▒▒▒▒▒▌██▀▒▒░░░▒▒▒▀▄▌\n░▌░▒▄██▄▒▒▒▒▒▒▒▒▒░░░░░░▒▒▒▒▌\n▌▒▀▐▄█▄█▌▄░▀▒▒░░░░░░░░░░▒▒▒▐\n▐▒▒▐▀▐▀▒░▄▄▒▄▒▒▒▒▒▒░▒░▒░▒▒▒▒▌\n▐▒▒▒▀▀▄▄▒▒▒▄▒▒▒▒▒▒▒▒░▒░▒░▒▒▐\n░▌▒▒▒▒▒▒▀▀▀▒▒▒▒▒▒░▒░▒░▒░▒▒▒▌\n░▐▒▒▒▒▒▒▒▒▒▒▒▒▒▒░▒░▒░▒▒▄▒▒▐\n░░▀▄▒▒▒▒▒▒▒▒▒▒▒░▒░▒░▒▄▒▒▒▒▌\n░░░░▀▄▒▒▒▒▒▒▒▒▒▒▄▄▄▀▒▒▒▒▄▀\n░░░░░░▀▄▄▄▄▄▄▀▀▀▒▒▒▒▒▄▄▀\n░░░░░░░░░▒▒▒▒▒▒▒▒▒▒▀▀", 
    "⢀⡴⠑⡄⠀⠀⠀⠀⠀⠀⠀⣀⣀⣤⣤⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ \n⠸⡇⠀⠿⡀⠀⠀⠀⣀⡴⢿⣿⣿⣿⣿⣿⣿⣿⣷⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀ \n⠀⠀⠀⠀⠑⢄⣠⠾⠁⣀⣄⡈⠙⣿⣿⣿⣿⣿⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀ \n⠀⠀⠀⠀⢀⡀⠁⠀⠀⠈⠙⠛⠂⠈⣿⣿⣿⣿⣿⠿⡿⢿⣆⠀⠀⠀⠀⠀⠀⠀ \n⠀⠀⠀⢀⡾⣁⣀⠀⠴⠂⠙⣗⡀⠀⢻⣿⣿⠭⢤⣴⣦⣤⣹⠀⠀⠀⢀⢴⣶⣆ \n⠀⠀⢀⣾⣿⣿⣿⣷⣮⣽⣾⣿⣥⣴⣿⣿⡿⢂⠔⢚⡿⢿⣿⣦⣴⣾⠁⠸⣼⡿ \n⠀⢀⡞⠁⠙⠻⠿⠟⠉⠀⠛⢹⣿⣿⣿⣿⣿⣌⢤⣼⣿⣾⣿⡟⠉⠀⠀⠀⠀⠀ \n⠀⣾⣷⣶⠇⠀⠀⣤⣄⣀⡀⠈⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀ \n⠀⠉⠈⠉⠀⠀⢦⡈⢻⣿⣿⣿⣶⣶⣶⣶⣤⣽⡹⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀ \n⠀⠀⠀⠀⠀⠀⠀⠉⠲⣽⡻⢿⣿⣿⣿⣿⣿⣿⣷⣜⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀ \n⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣷⣶⣮⣭⣽⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀ \n⠀⠀⠀⠀⠀⠀⣀⣀⣈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀ \n⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀ \n⠀⠀⠀⠀⠀⠀⠀⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀ \n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠻⠿⠿⠿⠿⠛⠉", 
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣤⣤⣤⣤⣤⣶⣦⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⡿⠛⠉⠙⠛⠛⠛⠛⠻⢿⣿⣷⣤⡀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⠋⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⠈⢻⣿⣿⡄⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⣸⣿⡏⠀⠀⠀⣠⣶⣾⣿⣿⣿⠿⠿⠿⢿⣿⣿⣿⣄⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⣿⣿⠁⠀⠀⢰⣿⣿⣯⠁⠀⠀⠀⠀⠀⠀⠀⠈⠙⢿⣷⡄⠀\n⠀⠀⣀⣤⣴⣶⣶⣿⡟⠀⠀⠀⢸⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣷⠀\n⠀⢰⣿⡟⠋⠉⣹⣿⡇⠀⠀⠀⠘⣿⣿⣿⣿⣷⣦⣤⣤⣤⣶⣶⣶⣶⣿⣿⣿⠀\n⠀⢸⣿⡇⠀⠀⣿⣿⡇⠀⠀⠀⠀⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠃⠀\n⠀⣸⣿⡇⠀⠀⣿⣿⡇⠀⠀⠀⠀⠀⠉⠻⠿⣿⣿⣿⣿⡿⠿⠿⠛⢻⣿⡇⠀⠀\n⠀⣿⣿⠁⠀⠀⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣧⠀⠀\n⠀⣿⣿⠀⠀⠀⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⠀⠀\n⠀⣿⣿⠀⠀⠀⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⠀⠀\n⠀⢿⣿⡆⠀⠀⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⡇⠀⠀\n⠀⠸⣿⣧⡀⠀⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠃⠀⠀\n⠀⠀⠛⢿⣿⣿⣿⣿⣇⠀⠀⠀⠀⠀⣰⣿⣿⣷⣶⣶⣶⣶⠶⠀⢠⣿⣿⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⠀⣿⣿⡇⠀⣽⣿⡏⠁⠀⠀⢸⣿⡇⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⠀⣿⣿⡇⠀⢹⣿⡆⠀⠀⠀⣸⣿⠇⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⢿⣿⣦⣄⣀⣠⣴⣿⣿⠁⠀⠈⠻⣿⣿⣿⣿⡿⠏⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠈⠛⠻⠿⠿⠿⠿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀", 
    "⠐⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠂\n⠄⠄⣰⣾⣿⣿⣿⠿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣆⠄⠄\n⠄⠄⣿⣿⣿⡿⠋⠄⡀⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⠋⣉⣉⣉⡉⠙⠻⣿⣿⠄⠄\n⠄⠄⣿⣿⣿⣇⠔⠈⣿⣿⣿⣿⣿⡿⠛⢉⣤⣶⣾⣿⣿⣿⣿⣿⣿⣦⡀⠹⠄⠄\n⠄⠄⣿⣿⠃⠄⢠⣾⣿⣿⣿⠟⢁⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠄⠄\n⠄⠄⣿⣿⣿⣿⣿⣿⣿⠟⢁⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠄⠄\n⠄⠄⣿⣿⣿⣿⣿⡟⠁⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠄⠄\n⠄⠄⣿⣿⣿⣿⠋⢠⣾⣿⣿⣿⣿⣿⣿⡿⠿⠿⠿⠿⣿⣿⣿⣿⣿⣿⣿⣿⠄⠄\n⠄⠄⣿⣿⡿⠁⣰⣿⣿⣿⣿⣿⣿⣿⣿⠗⠄⠄⠄⠄⣿⣿⣿⣿⣿⣿⣿⡟⠄⠄\n⠄⠄⣿⡿⠁⣼⣿⣿⣿⣿⣿⣿⡿⠋⠄⠄⠄⣠⣄⢰⣿⣿⣿⣿⣿⣿⣿⠃⠄⠄\n⠄⠄⡿⠁⣼⣿⣿⣿⣿⣿⣿⣿⡇⠄⢀⡴⠚⢿⣿⣿⣿⣿⣿⣿⣿⣿⡏⢠⠄⠄\n⠄⠄⠃⢰⣿⣿⣿⣿⣿⣿⡿⣿⣿⠴⠋⠄⠄⢸⣿⣿⣿⣿⣿⣿⣿⡟⢀⣾⠄⠄\n⠄⠄⢀⣿⣿⣿⣿⣿⣿⣿⠃⠈⠁⠄⠄⢀⣴⣿⣿⣿⣿⣿⣿⣿⡟⢀⣾⣿⠄⠄\n⠄⠄⢸⣿⣿⣿⣿⣿⣿⣿⠄⠄⠄⠄⢶⣿⣿⣿⣿⣿⣿⣿⣿⠏⢀⣾⣿⣿⠄⠄\n⠄⠄⣿⣿⣿⣿⣿⣿⣿⣷⣶⣶⣶⣶⣶⣿⣿⣿⣿⣿⣿⣿⠋⣠⣿⣿⣿⣿⠄⠄\n⠄⠄⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⢁⣼⣿⣿⣿⣿⣿⠄⠄\n⠄⠄⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⢁⣴⣿⣿⣿⣿⣿⣿⣿⠄⠄\n⠄⠄⠈⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⢁⣴⣿⣿⣿⣿⠗⠄⠄⣿⣿⠄⠄\n⠄⠄⣆⠈⠻⢿⣿⣿⣿⣿⣿⣿⠿⠛⣉⣤⣾⣿⣿⣿⣿⣿⣇⠠⠺⣷⣿⣿⠄⠄\n⠄⠄⣿⣿⣦⣄⣈⣉⣉⣉⣡⣤⣶⣿⣿⣿⣿⣿⣿⣿⣿⠉⠁⣀⣼⣿⣿⣿⠄⠄\n⠄⠄⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣾⣿⣿⡿⠟⠄⠄\n⠠⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄",  
    "░░░░░░░░███████████████░░░░░░░░\n░░░░░█████████████████████░░░░░\n░░░░████████████████████████░░░\n░░░██████████████████████████░░\n░░█████████████████████████████\n░░███████████▀░░░░░░░░░████████\n░░███████████░░░░░░░░░░░░░░░███\n░████████████░░░░░░░░░░░░░░░░██\n░█░░███████░░░░░░░░░░░▄▄░░░░░██\n█░░░░█████░░░░░░▄███████░░██░░█\n█░░█░░░███░░░░░██▀▀░░░░░░░░██░█\n█░░░█░░░░░░░░░░░░▄██▄░░░░░░░███\n█░░▄█░░░░░░░░░░░░░░░░░░█▀▀█▄░██\n█░░░░░░░░░░░░░░░░░░░░░░█░░░░██░\n░███░░░░░░░░░░░░░░░░░░░█░░░░█░░\n░░█░█░░░░░░░█░░░░░██▀▄░▄██░░░█░\n░░█░█░░░░░░█░░░░░░░░░░░░░░░░░█░\n░░░██░░░░░░█░░░░▄▄▄▄▄▄░░░░░░█░░\n░░░██░░░░░░░█░░█▄▄▄▄░▀▀██░░█░░░\n░░░██░░░░░░░█░░▀████████░░█░░░░\n░░█░░█░░░░░░░█░░▀▄▄▄▄██░░█░░░░░\n░░█░░░█░░░░░░░█░░░░░░░░░█░░░░░░\n░█░░░░░█░░░░░░░░░░░░░░░░█░░░░░░\n░░░░░░░░█░░░░░░█░░░░░░░░█░░░░░░\n░░░░░░░░░░░░░░░░████████░░░░░░░", 
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣧⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣧⠀⠀⠀⢰⡿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⡟⡆⠀⠀⣿⡇⢻⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠀⣿⠀⢰⣿⡇⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⡄⢸⠀⢸⣿⡇⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⡇⢸⡄⠸⣿⡇⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⢸⡅⠀⣿⢠⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣥⣾⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⡿⡿⣿⣿⡿⡅⠀⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠉⠀⠉⡙⢔⠛⣟⢋⠦⢵⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣄⠀⠀⠁⣿⣯⡥⠃⠀⢳⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⡇⠀⠀⠀⠐⠠⠊⢀⠀⢸⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⡿⠀⠀⠀⠀⠀⠈⠁⠀⠀⠘⣿⣄⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⣠⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣷⡀⠀⠀⠀\n⠀⠀⠀⠀⣾⣿⣿⣿⣿⣿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣧⠀⠀\n⠀⠀⠀⡜⣭⠤⢍⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⢛⢭⣗⠀\n⠀⠀⠀⠁⠈⠀⠀⣀⠝⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠄⠠⠀⠀⠰⡅\n⠀⠀⠀⢀⠀⠀⡀⠡⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠔⠠⡕⠀\n⠀⠀⠀⠀⣿⣷⣶⠒⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⠀⠀⠀⠀\n⠀⠀⠀⠀⠘⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠰⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠈⢿⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠊⠉⢆⠀⠀⠀⠀\n⠀⢀⠤⠀⠀⢤⣤⣽⣿⣿⣦⣀⢀⡠⢤⡤⠄⠀⠒⠀⠁⠀⠀⠀⢘⠔⠀⠀⠀⠀\n⠀⠀⠀⡐⠈⠁⠈⠛⣛⠿⠟⠑⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠉⠑⠒⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀", 
    "⡆⣐⢕⢕⢕⢕⢕⢕⢕⢕⠅⢗⢕⢕⢕⢕⢕⢕⢕⠕⠕⢕⢕⢕⢕⢕⢕⢕⢕⢕\n⢐⢕⢕⢕⢕⢕⣕⢕⢕⠕⠁⢕⢕⢕⢕⢕⢕⢕⢕⠅⡄⢕⢕⢕⢕⢕⢕⢕⢕⢕\n⢕⢕⢕⢕⢕⠅⢗⢕⠕⣠⠄⣗⢕⢕⠕⢕⢕⢕⠕⢠⣿⠐⢕⢕⢕⠑⢕⢕⠵⢕\n⢕⢕⢕⢕⠁⢜⠕⢁⣴⣿⡇⢓⢕⢵⢐⢕⢕⠕⢁⣾⢿⣧⠑⢕⢕⠄⢑⢕⠅⢕\n⢕⢕⠵⢁⠔⢁⣤⣤⣶⣶⣶⡐⣕⢽⠐⢕⠕⣡⣾⣶⣶⣶⣤⡁⢓⢕⠄⢑⢅⢑\n⠍⣧⠄⣶⣾⣿⣿⣿⣿⣿⣿⣷⣔⢕⢄⢡⣾⣿⣿⣿⣿⣿⣿⣿⣦⡑⢕⢤⠱⢐\n⢠⢕⠅⣾⣿⠋⢿⣿⣿⣿⠉⣿⣿⣷⣦⣶⣽⣿⣿⠈⣿⣿⣿⣿⠏⢹⣷⣷⡅⢐\n⣔⢕⢥⢻⣿⡀⠈⠛⠛⠁⢠⣿⣿⣿⣿⣿⣿⣿⣿⡀⠈⠛⠛⠁⠄⣼⣿⣿⡇⢔\n⢕⢕⢽⢸⢟⢟⢖⢖⢤⣶⡟⢻⣿⡿⠻⣿⣿⡟⢀⣿⣦⢤⢤⢔⢞⢿⢿⣿⠁⢕\n⢕⢕⠅⣐⢕⢕⢕⢕⢕⣿⣿⡄⠛⢀⣦⠈⠛⢁⣼⣿⢗⢕⢕⢕⢕⢕⢕⡏⣘⢕\n⢕⢕⠅⢓⣕⣕⣕⣕⣵⣿⣿⣿⣾⣿⣿⣿⣿⣿⣿⣿⣷⣕⢕⢕⢕⢕⡵⢀⢕⢕\n⢑⢕⠃⡈⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢃⢕⢕⢕\n⣆⢕⠄⢱⣄⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⢁⢕⢕⠕⢁\n⣿⣦⡀⣿⣿⣷⣶⣬⣍⣛⣛⣛⡛⠿⠿⠿⠛⠛⢛⣛⣉⣭⣤⣂⢜⠕⢑⣡⣴⣿", 
    "________▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▄______\n_______█░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░█_____\n_______█░▒▒▒▒▒▒▒▒▒▒▄▀▀▄▒▒▒░░█▄▀▀▄_\n__▄▄___█░▒▒▒▒▒▒▒▒▒▒█▓▓▓▀▄▄▄▄▀▓▓▓█_\n█▓▓█▄▄█░▒▒▒▒▒▒▒▒▒▄▀▓▓▓▓▓▓▓▓▓▓▓▓▀▄_\n_▀▄▄▓▓█░▒▒▒▒▒▒▒▒▒█▓▓▓▄█▓▓▓▄▓▄█▓▓█_\n_____▀▀█░▒▒▒▒▒▒▒▒▒█▓▒▒▓▄▓▓▄▓▓▄▓▒▒█\n______▄█░░▒▒▒▒▒▒▒▒▒▀▄▓▓▀▀▀▀▀▀▀▓▄▀_\n____▄▀▓▀█▄▄▄▄▄▄▄▄▄▄▄▄██████▀█▀▀___\n____█▄▄▀_█▄▄▀_______█▄▄▀_▀▄▄█_____", 
    "⢸⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⡷⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠢⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠈⠑⢦⡀⠀⠀⠀⠀⠀\n⢸⠀⠀⠀⠀⢀⠖⠒⠒⠒⢤⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠙⢦⡀⠀⠀⠀⠀\n⢸⠀⠀⣀⢤⣼⣀⡠⠤⠤⠼⠤⡄⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠙⢄⠀⠀⠀⠀\n⢸⠀⠀⠑⡤⠤⡒⠒⠒⡊⠙⡏⠀⢀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠑⠢⡄⠀\n⢸⠀⠀⠀⠇⠀⣀⣀⣀⣀⢀⠧⠟⠁⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀\n⢸⠀⠀⠀⠸⣀⠀⠀⠈⢉⠟⠓⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸\n⢸⠀⠀⠀⠀⠈⢱⡖⠋⠁⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸\n⢸⠀⠀⠀⠀⣠⢺⠧⢄⣀⠀⠀⣀⣀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸\n⢸⠀⠀⠀⣠⠃⢸⠀⠀⠈⠉⡽⠿⠯⡆⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸\n⢸⠀⠀⣰⠁⠀⢸⠀⠀⠀⠀⠉⠉⠉⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸\n⢸⠀⠀⠣⠀⠀⢸⢄⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸\n⢸⠀⠀⠀⠀⠀⢸⠀⢇⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸\n⢸⠀⠀⠀⠀⠀⡌⠀⠈⡆⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸\n⢸⠀⠀⠀⠀⢠⠃⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸\n⢸⠀⠀⠀⠀⢸⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠷", 
    "⢀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⣠⣤⣶⣶\n⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⢰⣿⣿⣿⣿\n⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⣀⣀⣾⣿⣿⣿⣿\n⣿⣿⣿⣿⣿⡏⠉⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿\n⣿⣿⣿⣿⣿⣿⠀⠀⠀⠈⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⠉⠁⠀⣿\n⣿⣿⣿⣿⣿⣿⣧⡀⠀⠀⠀⠀⠙⠿⠿⠿⠻⠿⠿⠟⠿⠛⠉⠀⠀⠀⠀⠀⣸⣿\n⣿⣿⣿⣿⣿⣿⣿⣷⣄⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿\n⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⣴⣿⣿⣿⣿\n⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⢰⣹⡆⠀⠀⠀⠀⠀⠀⣭⣷⠀⠀⠀⠸⣿⣿⣿⣿\n⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⠈⠉⠀⠀⠤⠄⠀⠀⠀⠉⠁⠀⠀⠀⠀⢿⣿⣿⣿\n⣿⣿⣿⣿⣿⣿⣿⣿⢾⣿⣷⠀⠀⠀⠀⡠⠤⢄⠀⠀⠀⠠⣿⣿⣷⠀⢸⣿⣿⣿\n⣿⣿⣿⣿⣿⣿⣿⣿⡀⠉⠀⠀⠀⠀⠀⢄⠀⢀⠀⠀⠀⠀⠉⠉⠁⠀⠀⣿⣿⣿\n⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿\n⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿", 
    "⠄⠄⠄⠄⠄⠄⢀⣠⣤⣶⣶⣶⣤⣄⠄⠄⢀⣠⣤⣤⣤⣤⣀⠄⠄⠄⠄⠄⠄⠄\n⠄⠄⠄⠄⢠⣾⣿⣿⣿⣿⠿⠿⢿⣿⣿⡆⣿⣿⣿⣿⣿⣿⣿⣷⡄⠄⠄⠄⠄⠄\n⠄⠄⠄⣴⣿⣿⡟⣩⣵⣶⣾⣿⣷⣶⣮⣅⢛⣫⣭⣭⣭⣭⣭⣭⣛⣂⠄⠄⠄⠄\n⠄⠄⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣭⠛⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⠄\n⣠⡄⣿⣿⣿⣿⣿⣿⣿⠿⢟⣛⣫⣭⠉⠍⠉⣛⠿⡘⣿⠿⢟⣛⡛⠉⠙⠻⢿⡄\n⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣶⣶⣶⣶⣶⣶⣭⣍⠄⣡⣬⣭⣭⣅⣈⣀⣉⣁⠄\n⣿⣿⣿⣿⣿⣿⣿⣿⣶⣭⣛⡻⠿⠿⢿⣿⡿⢛⣥⣾⣿⣿⣿⣿⣿⣿⣿⠿⠋⠄\n⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⣩⣵⣾⣿⣿⣯⣙⠟⣋⣉⣩⣍⡁⠄⠄⠄\n⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣿⣿⣿⣿⣷⡄⠄⠄\n⣿⣿⣿⣿⣿⣿⡿⢟⣛⣛⣛⣛⠿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⡀⠄\n⣿⣿⣿⣿⣿⡟⢼⣿⣯⣭⣛⣛⣛⡻⠷⠶⢶⣬⣭⣭⣭⡭⠭⢉⡄⠶⠾⠟⠁⠄\n⣿⣿⣿⣿⣟⠻⣦⣤⣭⣭⣭⣭⣛⣛⡻⠿⠷⠶⢶⣶⠞⣼⡟⡸⣸⡸⠿⠄⠄⠄\n⣛⠿⢿⣿⣿⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠷⡆⣾⠟⡴⣱⢏⡜⠆⠄⠄⠄\n⣭⣙⡒⠦⠭⣭⣛⣛⣛⡻⠿⠿⠟⣛⣛⣛⣛⡋⣶⡜⣟⣸⣠⡿⣸⠇⣧⡀⠄⠄\n⣿⣿⣿⣿⣷⣶⣦⣭⣭⣭⣭⣭⣭⣥⣶⣶⣶⡆⣿⣾⣿⣿⣿⣷⣿⣸⠉⣷⠄⠄", 
    "⣿⣿⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠛⠻⣿⣿⣿⣿⣿⣿\n⣿⣿⣿⣿⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣄⡀⠀⢻⣿⣿⣿⣿⣿\n⣿⣿⣿⣿⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠸⣿⣿⣿⠃⢰⣿⣿⣿⣿⣿\n⣿⣿⣿⣿⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⣿⣿⣿⣿\n⣿⣿⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⢶⣶⣶⣾⣿⣿⣿⣿⣿⣿\n⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⢠⡀⠐⠀⠀⠀⠻⢿⣿⣿⣿⣿⣿⣿⣿\n⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⢸⣷⡄⠀⠣⣄⡀⠀⠉⠛⢿⣿⣿⣿⣿\n⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⠀⣿⣿⣦⠀⠹⣿⣷⣶⣦⣼⣿⣿⣿⣿\n⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣼⣿⣿⣿⣷⣄⣸⣿⣿⣿⣿⣿⣿⣿⣿\n⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿\n⣿⣿⡿⢛⡙⢻⠛⣉⢻⣉⢈⣹⣿⣿⠟⣉⢻⡏⢛⠙⣉⢻⣿⣿⣿\n⣿⣿⣇⠻⠃⣾⠸⠟⣸⣿⠈⣿⣿⣿⡀⠴⠞⡇⣾⡄⣿⠘⣿⣿⣿\n⣿⣿⣟⠛⣃⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣿⣿⣿⣿⣿\n⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿", 
    "⣿⣿⣿⣿⡿⠟⠛⠛⠛⠛⠉⠉⠙⠛⠛⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠟⠀⠀\n⣿⣿⣯⣥⣤⣶⣶⣶⣶⣿⣿⣿⣿⣿⣿⣷⣾⣿⣿⣿⣿⣿⣿⣿⣏⣀⣀⣀⡀⠀\n⣿⣿⣿⣿⣿⣿⣿⡿⠿⠛⠛⠻⠿⠟⠉⠉⠉⢻⣿⣿⣿⡿⠟⠋⣡⣼⣿⣿⣿⡄\n⣿⣿⣿⣟⣭⣤⣶⣶⣿⣿⠃⠀⠀⢀⣀⣤⣶⣿⣿⣿⣿⡅⡀⢀⣩⣤⣤⠀⠀⠀\n⣿⣿⣿⣿⣿⣿⣛⡛⠛⠛⠛⢋⣩⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣛⠛⠛⠓⠠⠀⠀\n⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣤⣤⣤⣦⠀\n⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇\n⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠿⠿⠿⢿⡿⢿⣿⣿⣿⠃\n⠿⠿⠿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣥⣄⣀⣀⠀⠀⠀⠀⠀⢰⣾⣿⣿⠏⠀\n⠀⠀⠀⠀⠀⠀⠉⣩⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣤⣜⡻⠋⠀⠀⠀\n⣰⣾⣷⣶⣿⣾⣖⣻⣿⣿⡿⣿⣿⣿⣿⠿⠿⠟⠛⠛⠛⠋⠉⠉⢉⡽⠃⠀⠀⠀\n⣿⣿⣿⣿⣿⣿⡉⠉⠉⠛⠛⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⡤⠚⠉⠀⠀⠀⠀⠀\n⠛⠛⣿⣿⣿⣿⣿⣿⣿⠉⠛⢶⣶⣄⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀\n⠠⣾⣿⣿⣿⣿⣿⠿⠟⠃⠀⠀⠀⠈⠲⣴⣦⣤⣤⣤⣶⡾⠁⠀⠀⠀⠀⠀⠀⠀\n⠄⠈⠉⠻⢿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠛⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀", 
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⡴⠞⠉⢉⣭⣿⣿⠿⣳⣤⠴⠖⠛⣛⣿⣿⡷⠖⣶⣤⡀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⣼⠁⢀⣶⢻⡟⠿⠋⣴⠿⢻⣧⡴⠟⠋⠿⠛⠠⠾⢛⣵⣿⠀⠀⠀⠀\n⣼⣿⡿⢶⣄⠀⢀⡇⢀⡿⠁⠈⠀⠀⣀⣉⣀⠘⣿⠀⠀⣀⣀⠀⠀⠀⠛⡹⠋⠀⠀⠀⠀\n⣭⣤⡈⢑⣼⣻⣿⣧⡌⠁⠀⢀⣴⠟⠋⠉⠉⠛⣿⣴⠟⠋⠙⠻⣦⡰⣞⠁⢀⣤⣦⣤⠀\n⠀⠀⣰⢫⣾⠋⣽⠟⠑⠛⢠⡟⠁⠀⠀⠀⠀⠀⠈⢻⡄⠀⠀⠀⠘⣷⡈⠻⣍⠤⢤⣌⣀\n⢀⡞⣡⡌⠁⠀⠀⠀⠀⢀⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⢿⡀⠀⠀⠀⠸⣇⠀⢾⣷⢤⣬⣉\n⡞⣼⣿⣤⣄⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⣿⠀⠸⣿⣇⠈⠻\n⢰⣿⡿⢹⠃⠀⣠⠤⠶⣼⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⣿⠀⠀⣿⠛⡄⠀\n⠈⠉⠁⠀⠀⠀⡟⡀⠀⠈⡗⠲⠶⠦⢤⣤⣤⣄⣀⣀⣸⣧⣤⣤⠤⠤⣿⣀⡀⠉⣼⡇⠀\n⣿⣴⣴⡆⠀⠀⠻⣄⠀⠀⠡⠀⠀⠀⠈⠛⠋⠀⠀⠀⡈⠀⠻⠟⠀⢀⠋⠉⠙⢷⡿⡇⠀\n⣻⡿⠏⠁⠀⠀⢠⡟⠀⠀⠀⠣⡀⠀⠀⠀⠀⠀⢀⣄⠀⠀⠀⠀⢀⠈⠀⢀⣀⡾⣴⠃⠀\n⢿⠛⠀⠀⠀⠀⢸⠁⠀⠀⠀⠀⠈⠢⠄⣀⠠⠼⣁⠀⡱⠤⠤⠐⠁⠀⠀⣸⠋⢻⡟⠀⠀\n⠈⢧⣀⣤⣶⡄⠘⣆⠀⠀⠀⠀⠀⠀⠀⢀⣤⠖⠛⠻⣄⠀⠀⠀⢀⣠⡾⠋⢀⡞⠀⠀⠀\n⠀⠀⠻⣿⣿⡇⠀⠈⠓⢦⣤⣤⣤⡤⠞⠉⠀⠀⠀⠀⠈⠛⠒⠚⢩⡅⣠⡴⠋⠀⠀⠀⠀\n⠀⠀⠀⠈⠻⢧⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⣻⠿⠋⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠉⠓⠶⣤⣄⣀⡀⠀⠀⠀⠀⠀⢀⣀⣠⡴⠖⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀", 
    "⣿⣿⣿⣿⣿⣿⣿⡿⡛⠟⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿\n⣿⣿⣿⣿⣿⣿⠿⠨⡀⠄⠄⡘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿\n⣿⣿⣿⣿⠿⢁⠼⠊⣱⡃⠄⠈⠹⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿\n⣿⣿⡿⠛⡧⠁⡴⣦⣔⣶⣄⢠⠄⠄⠹⣿⣿⣿⣿⣿⣿⣿⣤⠭⠏⠙⢿⣿⣿⣿⣿⣿\n⣿⡧⠠⠠⢠⣾⣾⣟⠝⠉⠉⠻⡒⡂⠄⠙⠻⣿⣿⣿⣿⣿⡪⠘⠄⠉⡄⢹⣿⣿⣿⣿\n⣿⠃⠁⢐⣷⠉⠿⠐⠑⠠⠠⠄⣈⣿⣄⣱⣠⢻⣿⣿⣿⣿⣯⠷⠈⠉⢀⣾⣿⣿⣿⣿\n⣿⣴⠤⣬⣭⣴⠂⠇⡔⠚⠍⠄⠄⠁⠘⢿⣷⢈⣿⣿⣿⣿⡧⠂⣠⠄⠸⡜⡿⣿⣿⣿\n⣿⣇⠄⡙⣿⣷⣭⣷⠃⣠⠄⠄⡄⠄⠄⠄⢻⣿⣿⣿⣿⣿⣧⣁⣿⡄⠼⡿⣦⣬⣰⣿\n⣿⣷⣥⣴⣿⣿⣿⣿⠷⠲⠄⢠⠄⡆⠄⠄⠄⡨⢿⣿⣿⣿⣿⣿⣎⠐⠄⠈⣙⣩⣿⣿\n⣿⣿⣿⣿⣿⣿⢟⠕⠁⠈⢠⢃⢸⣿⣿⣶⡘⠑⠄⠸⣿⣿⣿⣿⣿⣦⡀⡉⢿⣧⣿⣿\n⣿⣿⣿⣿⡿⠋⠄⠄⢀⠄⠐⢩⣿⣿⣿⣿⣦⡀⠄⠄⠉⠿⣿⣿⣿⣿⣿⣷⣨⣿⣿⣿\n⣿⣿⣿⡟⠄⠄⠄⠄⠄⠋⢀⣼⣿⣿⣿⣿⣿⣿⣿⣶⣦⣀⢟⣻⣿⣿⣿⣿⣿⣿⣿⣿\n⣿⣿⣿⡆⠆⠄⠠⡀⡀⠄⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿\n⣿⣿⡿⡅⠄⠄⢀⡰⠂⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"}

    surface.CreateFont("AHRandomatHeader", {
        font = "Roboto",
        size = 48
    })

    surface.CreateFont("AHRandomatSmallMsg", {
        font = "Roboto",
        size = 32
    })

    local function ShowMessage(big, msg, length)
        if msg == "AHMemeRandomatEffect" then
            msg = memeASCII[math.random(1, #memeASCII)]
        end

        if length == 0 then
            length = 5
        end

        local panel = vgui.Create("DNotify")
        panel:SetLife(length)

        if big then
            surface.SetFont("AHRandomatHeader")
        else
            surface.SetFont("AHRandomatSmallMsg")
        end

        panel:SetSize(surface.GetTextSize(msg))
        panel:Center()

        if not big then
            panel:CenterVertical(0.55)
        end

        local bg = vgui.Create("DPanel", panel)
        bg:SetBackgroundColor(Color(0, 0, 0, 200))
        bg:Dock(FILL)
        local lbl = vgui.Create("DLabel", bg)
        lbl:SetText(msg)

        if big then
            lbl:SetFont("AHRandomatHeader")
        else
            lbl:SetFont("AHRandomatSmallMsg")
        end

        lbl:SetTextColor(Color(255, 200, 0))
        lbl:SetWrap(true)
        lbl:Dock(FILL)
        lbl:SetText(msg)
        panel:AddItem(bg)
    end

    net.Receive("AHRandomatAlert", function()
        local big = net.ReadBool()
        local msg = net.ReadString()
        local length = net.ReadUInt(8)
        ShowMessage(big, msg, length)
        surface.PlaySound("ttt_achievement_hunt/custom_sounds/randomat_activate.mp3")
    end)

    net.Receive("AHRandomatAlertSilent", function()
        local big = net.ReadBool()
        local msg = net.ReadString()
        local length = net.ReadUInt(8)
        ShowMessage(big, msg, length)
    end)
end