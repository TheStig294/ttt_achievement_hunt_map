if not ((game.GetMap() == "ttt_achievement_hunt" or game.GetMap() == "ttt_achievement_hunt_final") and engine.ActiveGamemode() == "terrortown") then return end

local function TestActive()
    return GetGlobalBool("AHTestActive") and GetGlobalBool("AHTestIntroComplete") and not GetGlobalBool("AHTestOver")
end

-- Runs the interactions for pulling the lever, pressing the buttons, etc. for the "Prop-sonality quiz" in the ttt_achievement_hunt map
if SERVER then
    util.AddNetworkString("AHTestNatureDescription")
    util.AddNetworkString("AHRemoveTestNatureDescription")
    local nearTestEnts = {}
    local startTestLeverPos = Vector(3561.281250, -3620.968750, 761.250000)
    local Q = {}
    local askedQuestions = {}
    local initPly = nil
    local questionNumber = 0
    local startTestLever = nil
    local finishTestCount = 0
    resource.AddFile("resource/fonts/pmd.ttf")

    hook.Add("Think", "AHTestRun", function()
        if not TestActive() then return end
        -- Showing the test UI when players are near the test buttons after the test has begun
        nearTestEnts = ents.FindInSphere(startTestLeverPos, 200)

        for _, ply in ipairs(player.GetAll()) do
            ply:SetNWBool("AHNearTest", false)
        end

        for _, ent in ipairs(nearTestEnts) do
            if not IsPlayer(ent) then continue end
            ent:SetNWBool("AHNearTest", true)
        end
    end)

    local function ChooseFirstQuestion(ply, ent)
        SetGlobalBool("AHTestActive", true)
        startTestLever:EmitSound("ttt_achievement_hunt/custom_sounds/test_background.mp3")
        startTestLever:EmitSound("ttt_achievement_hunt/custom_sounds/test_background.mp3")

        timer.Create("AHTestSoundLoop", 79.661, 0, function()
            if not IsValid(startTestLever) then
                timer.Remove("AHTestSoundLoop")

                return
            end

            startTestLever:EmitSound("ttt_achievement_hunt/custom_sounds/test_background.mp3")
            startTestLever:EmitSound("ttt_achievement_hunt/custom_sounds/test_background.mp3")
        end)

        -- Choosing the initial question
        Q = table.Random(AHTestQuestions)
        SetGlobalString("AHTestQuestionID", Q.ID)
        table.insert(askedQuestions, Q.ID)
        questionNumber = 1
        -- Setting the player the test is to be judging
        initPly = ply
        initPly.AHTestPoints = {}
        AHEarnAchievement("tester")
    end

    -- These are the props Lewis mistook members of the yogscast for while playing TTT
    local yogsProps = {
        ["models/luria/night_in_the_woods/playermodels/mae.mdl"] = {
            ["prop"] = "models/props_junk/TrafficCone001a.mdl",
            ["printname"] = "a traffic cone!"
        },
        ["models/luria/night_in_the_woods/playermodels/mae_astral.mdl"] = {
            ["prop"] = "models/props_junk/TrafficCone001a.mdl",
            ["printname"] = "a traffic cone!"
        },
        ["models/player_phoenix.mdl"] = {
            ["prop"] = "models/props_c17/chair02a.mdl",
            ["printname"] = "a blue chair!"
        },
        ["models/bradyjharty/yogscast/sharky.mdl"] = {
            ["prop"] = "models/props_borealis/bluebarrel001.mdl",
            ["printname"] = "a blue barrel!"
        },
        ["models/solidsnakemgs4/solidsnakemgs4.mdl"] = {
            ["prop"] = "models/props_trainstation/trainstation_column001.mdl",
            ["printname"] = "a chimney!"
        }
    }

    local function TransformPlayerIntoProp(ply, propName)
        -- If wearing certain yogscast playermodels, get transformed into a yogscast-themed prop instead!
        local yogsProp = yogsProps[ply:GetModel()]

        if yogsProp then
            propName = yogsProp.prop
        end

        -- Turns you invisible and puts a prop model on top of you the follows you around and faces the way you do
        ply.oldViewOffset = ply:GetViewOffset()
        ply.oldViewOffsetDucked = ply:GetViewOffsetDucked()
        ply.IsAHProp = true
        ply:SetViewOffset(Vector(0, 0, 40))
        ply:SetViewOffsetDucked(Vector(0, 0, 28))
        local prop = ents.Create("prop_dynamic")
        prop:SetModel(propName)
        prop:Spawn()
        ply:SetNoDraw(true)

        -- Fix the view offset of respawning players as they are no longer props
        hook.Add("PlayerSpawn", "AHPropPlayerRespawn", function(spawnPly)
            timer.Simple(1, function()
                if spawnPly.oldViewOffset then
                    spawnPly:SetViewOffset(spawnPly.oldViewOffset)
                end

                if spawnPly.oldViewOffsetDucked then
                    spawnPly:SetViewOffsetDucked(spawnPly.oldViewOffsetDucked)
                end
            end)
        end)

        -- Makes the prop appear on top of and look the same direction as the player
        hook.Add("Think", "AHPropModel", function()
            -- If the player isn't there for whatever reason, or IsAHProp has been set to false, remove the prop and the hook
            if not IsValid(ply) or not ply.IsAHProp then
                ply.IsAHProp = false

                if IsValid(prop) then
                    prop:Remove()
                end

                hook.Remove("Think", "AHPropModel")

                return
            end

            -- Remove the prop and set the player to normal after they die
            if not IsValid(prop) or (IsValid(ply) and (not ply:Alive() or ply:IsSpec())) then
                ply:SetNoDraw(false)
                ply.IsAHProp = false

                if IsValid(prop) then
                    prop:Remove()
                end

                return
            end

            local pos = ply:GetPos()
            pos.z = pos.z + 25
            prop:SetPos(pos)
            prop:SetAngles(ply:GetAngles())
        end)

        if propName == "models/props_c17/oildrum001_explosive.mdl" then
            ply.IsExplosiveBarrel = true
        end

        -- If someone is turned into an explosive barrel, make them explode on taking damage
        hook.Add("PostEntityTakeDamage", "AHExplosiveBarrelPropExplode", function(ent, dmg, took)
            if not IsPlayer(ent) then return end

            if ent.IsExplosiveBarrel and took and dmg:GetDamage() > 0 then
                local explode = ents.Create("env_explosion")
                explode:SetPos(ent:GetPos())
                explode:SetOwner(ent)
                explode:Spawn()
                explode:SetKeyValue("iMagnitude", "100")
                explode:SetKeyValue("iRadiusOverride", "256")
                explode:Fire("Explode", 0, 0)
                explode:EmitSound("weapon_AWP.Single", 400, 400)
                hook.Remove("PostEntityTakeDamage", "AHExplosiveBarrelPropExplode")

                return true
            end
        end)
    end

    local function EndTest(ply, ent, nature)
        SetGlobalBool("AHTestOver", true)
        -- Displaying the result to everyone nearby
        local N = AHTestNatures[nature]
        local desc = N.Description
        local plys = {}
        local message = "The " .. N.ID .. " type!"

        for _, nearEnt in ipairs(nearTestEnts) do
            if not IsPlayer(nearEnt) then continue end
            table.insert(plys, nearEnt)
            nearEnt:PrintMessage(HUD_PRINTCENTER, message)

            timer.Simple(1.9, function()
                if not nearEnt then return end
                nearEnt:PrintMessage(HUD_PRINTCENTER, message)
            end)
        end

        -- Ensure the player who will be transformed always sees the test result message
        if IsValid(initPly) then
            table.insert(plys, initPly)
        end

        net.Start("AHTestNatureDescription")
        net.WriteString(desc)
        net.Send(plys)

        timer.Create("AHTestReset", #desc * 0.075 + 3, 1, function()
            net.Start("AHRemoveTestNatureDescription")
            net.Broadcast()
            -- Stops the music from looping and fades it out
            timer.Remove("AHTestSoundLoop")
            startTestLever:StopSound("ttt_achievement_hunt/custom_sounds/test_background.mp3")
            startTestLever:StopSound("ttt_achievement_hunt/custom_sounds/test_background.mp3")

            -- Resets the bushes used in the test area
            for _, brushEnt in ipairs(ents.FindByName("brush_test_*")) do
                brushEnt:Fire("Toggle")
            end

            -- Turns off the lights outside the tester
            for _, light in ipairs(ents.FindByName("light_test_on")) do
                light:Fire("TurnOff")
            end

            -- Displaying the name of the prop and transforming the player into a prop
            local propName = N.PropName
            -- If the player is wearing a yogs model, display the name of the yogscast-themed prop they were given
            local yogsProp = yogsProps[ply:GetModel()]

            if yogsProp then
                propName = yogsProp.printname
            end

            -- Only show the transformed into a prop message if the player who was tested is still alive
            if IsValid(initPly) and initPly:Alive() and not initPly:IsSpec() then
                for _, allPly in ipairs(player.GetAll()) do
                    if not IsPlayer(initPly) then continue end
                    allPly:PrintMessage(HUD_PRINTCENTER, initPly:Nick() .. " has transformed into " .. propName)
                    allPly:PrintMessage(HUD_PRINTTALK, initPly:Nick() .. " has transformed into " .. propName)
                end
            end

            -- Ensure the player who started the test always sees the name of the prop they transform into rather than the announcement message
            if IsValid(initPly) then
                if not initPly:Alive() or initPly:IsSpec() then
                    propName = propName .. " If you were alive..."
                end

                initPly:PrintMessage(HUD_PRINTCENTER, propName)
            end

            finishTestCount = finishTestCount + 1

            if finishTestCount == 2 then
                AHEarnAchievement("tester2")
            end

            TransformPlayerIntoProp(initPly, N.Prop)
        end)
    end

    hook.Add("PlayerUse", "AHTestInteraction", function(ply, ent)
        local name = ent:GetName()
        if not isstring(name) then return end
        if not string.StartWith(name, "button_test_") then return end

        if GetGlobalBool("AHAmongUsEventActive") then
            ply:PrintMessage(HUD_PRINTCENTER, "Disabled during Among Us event!")

            return false
        end

        if GetGlobalBool("AHTestOver") then
            ply:PrintMessage(HUD_PRINTCENTER, "Try again next round!")

            return false
        end

        -- Updating near test ents now to guarantee it's up to date for functions below that use it! 
        nearTestEnts = ents.FindInSphere(startTestLeverPos, 200)

        if name == "button_test_lever" then
            startTestLever = ent

            -- Only show the intro when the test is first started
            if not GetGlobalBool("AHTestIntroShown") then
                SetGlobalBool("AHTestIntroShown", true)
                ChooseFirstQuestion(ply, ent)

                local welcomeMsgs = {"Welcome to the personality test!", "Find out what kind of prop you are, by answering questions", "Be truthful when you answer them!", "Now are you ready " .. initPly:Nick() .. "? Then... let the questions begin!"}

                timer.Create("AHTestIntroMsgs", 1, #welcomeMsgs * 4, function()
                    local repsLeft = timer.RepsLeft("AHTestIntroMsgs")
                    local msgIndex

                    if repsLeft > #welcomeMsgs * 3 then
                        msgIndex = 1
                    elseif repsLeft > #welcomeMsgs * 2 then
                        msgIndex = 2
                    elseif repsLeft > #welcomeMsgs * 1 then
                        msgIndex = 3
                    else
                        msgIndex = 4
                    end

                    for _, nearEnt in ipairs(nearTestEnts) do
                        if not IsPlayer(nearEnt) then continue end
                        nearEnt:PrintMessage(HUD_PRINTCENTER, welcomeMsgs[msgIndex])

                        -- Ensuring the messages sent to the chat box aren't repeatedly sent, only when the next message is displayed
                        if repsLeft == #welcomeMsgs * 4 - 1 then
                            nearEnt:PrintMessage(HUD_PRINTTALK, welcomeMsgs[1])
                        elseif repsLeft == #welcomeMsgs * 3 - 1 then
                            nearEnt:PrintMessage(HUD_PRINTTALK, welcomeMsgs[2])
                        elseif repsLeft == #welcomeMsgs * 2 - 1 then
                            nearEnt:PrintMessage(HUD_PRINTTALK, welcomeMsgs[3])
                        elseif repsLeft == #welcomeMsgs * 1 - 1 then
                            nearEnt:PrintMessage(HUD_PRINTTALK, welcomeMsgs[4])
                        end
                    end

                    -- Start the test after the intro!
                    if timer.RepsLeft("AHTestIntroMsgs") == 0 then
                        SetGlobalBool("AHTestIntroComplete", true)
                    end
                end)
            elseif not GetGlobalBool("AHTestActive") then
                -- Immediately start the test if the intro has been shown before
                for _, nearEnt in ipairs(nearTestEnts) do
                    if not IsPlayer(nearEnt) then continue end
                    nearEnt:PrintMessage(HUD_PRINTCENTER, "Time to test your personality, " .. ply:Nick() .. "!")
                    nearEnt:PrintMessage(HUD_PRINTTALK, "Time to test your personality, " .. ply:Nick() .. "!")
                end

                ChooseFirstQuestion(ply, ent)

                timer.Create("AHTestImmediateIntro", 2, 1, function()
                    SetGlobalBool("AHTestIntroComplete", true)
                end)
            end
            -- Processing an answer
        elseif GetGlobalString("AHTestGivenAnswer", "noanswer") == "noanswer" and TestActive() then
            -- Setting the given answer to the last character of the button's name
            -- (Should be 1, 2, 3 or 4)
            local givenAnswer = tonumber(name[#name])

            -- Stop the player from answering a question with a button that isn't being used
            if givenAnswer > #Q.AnswerText then
                ply:PrintMessage(HUD_PRINTCENTER, "This question doesn't have an answer with that number")

                return
            end

            -- Set that an answer has been given so this hook isn't called multiple times
            SetGlobalString("AHTestGivenAnswer", givenAnswer)
            ent:EmitSound("ttt_achievement_hunt/custom_sounds/pmd_confirm.mp3")
            -- Add the points towards the personalities as given by the answer
            local points = Q.Points[givenAnswer]

            -- Set a new player being tested if the old player is no longer valid for some reason
            if not IsValid(initPly) then
                for _, nearEnt in ipairs(nearTestEnts) do
                    if not IsPlayer(nearEnt) then continue end
                    initPly = nearEnt
                    break
                end
            end

            for nature, value in pairs(points) do
                local oldPoints = initPly.AHTestPoints[nature]

                if oldPoints then
                    oldPoints = oldPoints + value
                else
                    initPly.AHTestPoints[nature] = value
                end
            end

            -- After a small delay, loads the next question or ends the test
            timer.Create("AHTestLoadNextQuestion", 0.3, 1, function()
                -- Ends the test and transforms the player who started the test into a prop, after 8 questions have been asked
                if questionNumber >= 8 then
                    -- Deciding the personality of the player given the personality points they now have
                    local nature = table.GetWinningKey(initPly.AHTestPoints)

                    for _, nearEnt in ipairs(nearTestEnts) do
                        if not IsPlayer(nearEnt) then continue end
                        nearEnt:PrintMessage(HUD_PRINTCENTER, "You seem to be...")
                        nearEnt:PrintMessage(HUD_PRINTTALK, "You seem to be...")

                        timer.Create("AHTestEnd", 2, 1, function()
                            EndTest(ply, ent, nature)
                        end)
                    end
                else
                    SetGlobalString("AHTestGivenAnswer", "noanswer")
                    questionNumber = questionNumber + 1
                    -- Randomly selecting a question that has not been asked before
                    local questionFound = false
                    local questionAsked = false

                    for _, question in RandomPairs(AHTestQuestions) do
                        questionAsked = false

                        for _, askedQuestion in ipairs(askedQuestions) do
                            if question.ID == askedQuestion then
                                questionAsked = true
                                break
                            end
                        end

                        if not questionAsked then
                            Q = question
                            questionFound = true
                            break
                        end
                    end

                    -- If all questions have been asked before, reset the table of asked questions!
                    if not questionFound then
                        table.Empty(askedQuestions)
                        Q = table.Random(AHTestQuestions)
                    end

                    -- Set the question ID for the HUD to display the question text, and add this question to the list of asked questions
                    SetGlobalString("AHTestQuestionID", Q.ID)
                    table.insert(askedQuestions, Q.ID)
                end
            end)
        end
    end)

    hook.Add("TTTPrepareRound", "AHTestReset", function()
        timer.Remove("AHTestImmediateIntro")
        timer.Remove("AHTestLoadNextQuestion")
        timer.Remove("AHTestEnd")
        timer.Remove("AHTestReset")
        SetGlobalBool("AHTestActive", false)
        SetGlobalBool("AHTestIntroComplete", false)
        SetGlobalString("AHTestGivenAnswer", "noanswer")
        SetGlobalBool("AHTestOver", false)
        hook.Remove("PlayerSpawn", "AHPropPlayerRespawn")

        -- Reset isProp flag on players
        for _, ply in ipairs(player.GetAll()) do
            ply.IsAHProp = false
            ply.IsExplosiveBarrel = false
        end

        -- Fix TTT not resetting the brushes used by the test properly between rounds
        timer.Simple(1, function()
            for _, brushEnt in ipairs(ents.FindByName("brush_test_*")) do
                if brushEnt:GetName() == "brush_test_off" then
                    brushEnt:Fire("Enable")
                else
                    brushEnt:Fire("Disable")
                end
            end
        end)
    end)
end

if CLIENT then
    -- Draws the test question boxes on the screen if the player is near the test buttons
    surface.CreateFont("PMDFont", {
        font = "PKMN Mystery Dungeon",
        extended = false,
        size = 24,
        weight = 500,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = true,
        additive = false,
        outline = false,
    })

    local boxColour = Color(33, 165, 33)
    local halfScreenWidth = ScrW() / 2
    local halfScreenHeight = ScrH() / 2
    local questionXPos = halfScreenWidth
    local questionYPos = halfScreenHeight
    local answerXPos
    local answerYPos
    local textAlign
    local ply
    local questionText
    local Q = {}
    local questionBox
    local textWidth
    local textHeight
    local textBorder = 90
    local lastEntPos
    local currentEntPos
    local buttonPos1 = Vector(3660, -3740, 763)
    local buttonPos2 = Vector(3620, -3740, 763)
    local buttonPos3 = Vector(3500, -3740, 763)
    local buttonPos4 = Vector(3460, -3740, 763)
    local cursorBox
    local answerTotal

    hook.Add("PostDrawHUD", "AHTestUI", function()
        if not ply then
            ply = LocalPlayer()
        end

        -- Checking the test is still active
        if not ply:GetNWBool("AHNearTest") or not TestActive() then return end
        -- Checking a question is set
        questionID = GetGlobalString("AHTestQuestionID", "noquestion")
        if questionID == "noquestion" then return end
        -- Loading the current question
        Q = AHTestQuestions[questionID]
        questionText = Q.QuestionText
        answerTotal = #Q.AnswerText

        -- Drawing the question box
        if questionBox then
            draw.TexturedQuad(questionBox)
        end

        textWidth, textHeight = draw.SimpleText(questionText, "PMDFont", questionXPos, questionYPos, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        questionBox = {
            texture = surface.GetTextureID("ttt_achievement_hunt/custom_textures/test_question_box.vmt"),
            color = color_white,
            x = questionXPos - (textWidth / 2) - (textBorder / 2),
            y = questionYPos - (textHeight / 2) - (textBorder / 3),
            w = textWidth + textBorder,
            h = textHeight + (textBorder / 1.5)
        }

        -- Drawing the answer boxes
        for index, answerText in ipairs(Q.AnswerText) do
            answerText = index .. ": " .. answerText

            if index == 1 then
                textAlign = TEXT_ALIGN_LEFT
                answerXPos = 0
                answerYPos = halfScreenHeight + (halfScreenHeight / 3)
            elseif index == 2 then
                textAlign = TEXT_ALIGN_RIGHT
                answerXPos = halfScreenWidth * 2
                answerYPos = halfScreenHeight + (halfScreenHeight / 3)
            elseif index == 3 then
                textAlign = TEXT_ALIGN_LEFT
                answerXPos = 0
                answerYPos = halfScreenHeight + (halfScreenHeight / 2)
            elseif index == 4 then
                textAlign = TEXT_ALIGN_RIGHT
                answerXPos = halfScreenWidth * 2
                answerYPos = halfScreenHeight + (halfScreenHeight / 2)
            end

            textWidth, textHeight = draw.WordBox(16, answerXPos, answerYPos, answerText, "PMDFont", boxColour, COLOR_WHITE, textAlign, TEXT_ALIGN_CENTER)
        end

        if not IsValid(ply:GetEyeTrace().Entity) then return end
        currentEntPos = ply:GetEyeTrace().Entity:GetPos()
        if currentEntPos ~= buttonPos1 and currentEntPos ~= buttonPos2 and currentEntPos ~= buttonPos3 and currentEntPos ~= buttonPos4 then return end
        -- Preventing the cursor from being shown on top of answers that don't exist
        if currentEntPos == buttonPos3 and answerTotal < 3 then return end
        if currentEntPos == buttonPos4 and answerTotal < 4 then return end

        -- Plays the cursor highlight sound
        if currentEntPos ~= lastEntPos then
            surface.PlaySound("ttt_achievement_hunt/custom_sounds/pmd_highlight.mp3")
        end

        -- Drawing a cursor on top of the answer corresponding to the answer the player is looking at
        lastEntPos = ply:GetEyeTrace().Entity:GetPos()

        cursorBox = {
            texture = surface.GetTextureID("ttt_achievement_hunt/custom_textures/test_cursor.vmt"),
            color = color_white,
            x = 0,
            y = 0,
            w = 10,
            h = 22
        }

        if lastEntPos == buttonPos1 then
            cursorBox.x = 0
            cursorBox.y = halfScreenHeight + (halfScreenHeight / 3) - 11
        elseif lastEntPos == buttonPos2 then
            cursorBox.x = halfScreenWidth * 2 - textWidth - 16
            cursorBox.y = halfScreenHeight + (halfScreenHeight / 3) - 11
        elseif lastEntPos == buttonPos3 then
            answerXPos = 0
            cursorBox.y = halfScreenHeight + (halfScreenHeight / 2) - 11
        elseif lastEntPos == buttonPos4 then
            cursorBox.x = halfScreenWidth * 2 - textWidth - 16
            cursorBox.y = halfScreenHeight + (halfScreenHeight / 2) - 11
        end

        draw.TexturedQuad(cursorBox)
    end)

    net.Receive("AHTestNatureDescription", function()
        local desc = net.ReadString()
        local descTbl = string.ToTable(desc)
        local descLength = string.len(desc)
        local charCount = 0
        descDisplayed = ""

        timer.Create("AHDisplayDescriptionTimer", 0.075, descLength, function()
            charCount = charCount + 1
            surface.PlaySound("ttt_achievement_hunt/custom_sounds/pmd_text.mp3")
            descDisplayed = descDisplayed .. descTbl[charCount]
        end)

        hook.Add("DrawOverlay", "AHDrawNatureDescription", function()
            draw.DrawText(descDisplayed, "PMDFont", halfScreenWidth, halfScreenHeight, COLOR_WHITE, TEXT_ALIGN_CENTER)
        end)
    end)

    net.Receive("AHRemoveTestNatureDescription", function()
        hook.Remove("DrawOverlay", "AHDrawNatureDescription")
    end)
end