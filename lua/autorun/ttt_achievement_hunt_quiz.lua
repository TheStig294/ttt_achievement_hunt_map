if not ((game.GetMap() == "ttt_achievement_hunt" or game.GetMap() == "ttt_achievement_hunt_final") and engine.ActiveGamemode() == "terrortown") then return end

local function QuizActive()
    return GetGlobalBool("AHQuizActive") and GetGlobalBool("AHQuizIntroComplete") and not GetGlobalBool("AHQuizOver")
end

-- Logic for the quiz gameshow in the green screen room on ttt_achievement_hunt
if SERVER then
    local nearQuizEnts = {}
    local startQuizButtonPos = Vector(1340, -3584, 758)
    local Q = {}
    local askedQuestions = {}
    local quizStartCount = 0

    hook.Add("Think", "AHQuizRun", function()
        if not QuizActive() then return end
        -- Showing the quiz UI when players are near the quiz buttons after the quiz has begun
        nearQuizEnts = ents.FindInSphere(startQuizButtonPos, 200)

        for _, ply in ipairs(player.GetAll()) do
            ply:SetNWBool("AHNearQuiz", false)
        end

        for _, ent in ipairs(nearQuizEnts) do
            if not IsPlayer(ent) then continue end
            ent:SetNWBool("AHNearQuiz", true)
        end
    end)

    local function ChooseFirstQuestion(ply, ent)
        SetGlobalBool("AHQuizActive", true)
        ent:EmitSound("ttt_achievement_hunt/custom_sounds/gameshow.mp3")
        ent:EmitSound("ttt_achievement_hunt/custom_sounds/gameshow.mp3")

        timer.Create("AHGameshowSoundLoop", 146.102, 0, function()
            ent:EmitSound("ttt_achievement_hunt/custom_sounds/gameshow.mp3")
            ent:EmitSound("ttt_achievement_hunt/custom_sounds/gameshow.mp3")
        end)

        -- Choosing the initial question
        Q = table.Random(AHQuizQuestions)
        SetGlobalString("AHQuizQuestionID", Q.ID)
        table.insert(askedQuestions, Q.ID)
        SetGlobalInt("AHQuizQuestionNumber", 1)

        -- Some questions need initialisation before being asked
        if isfunction(Q.QuestionFunction) then
            Q.QuestionFunction(ply, ent)
        end

        quizStartCount = quizStartCount + 1

        if quizStartCount == 2 then
            AHEarnAchievement("gameshow2")
        end
    end

    local function EndQuiz(ply, ent)
        SetGlobalBool("AHQuizOver", true)
        -- Stops the music and plays the ending music
        timer.Remove("AHGameshowSoundLoop")
        local button = GetGlobalEntity("AHBeginQuizButton")
        button:StopSound("ttt_achievement_hunt/custom_sounds/gameshow.mp3")
        button:StopSound("ttt_achievement_hunt/custom_sounds/gameshow.mp3")
        ent:EmitSound("ttt_achievement_hunt/custom_sounds/ganeshow_end.mp3")
        ent:EmitSound("ttt_achievement_hunt/custom_sounds/ganeshow_end.mp3")

        -- Resets the bushes used in the quiz area
        timer.Create("AHQuizIncorrectReset", 5.5, 1, function()
            for _, brushEnt in ipairs(ents.FindByName("brush_quiz_*")) do
                if brushEnt:GetName() == "brush_quiz_screen_green" or brushEnt:GetName() == "brush_quiz_screen_off" then
                    brushEnt:Fire("Toggle")
                else
                    brushEnt:Fire("Disable")
                end
            end
        end)

        if GetGlobalBool("AHQuizCorrect") then
            AHEarnAchievement("gameshow")

            for _, nearEnt in ipairs(nearQuizEnts) do
                if not IsPlayer(nearEnt) then continue end
                nearEnt:PrintMessage(HUD_PRINTCENTER, "You win! Come back next round!")
                nearEnt:PrintMessage(HUD_PRINTTALK, "You win! Come back next round!")
            end
        end
    end

    hook.Add("PlayerUse", "AHQuizInteraction", function(ply, ent)
        local name = ent:GetName()
        if not isstring(name) then return end
        if not string.StartWith(name, "button_quiz_") then return end

        if GetGlobalBool("AHAmongUsEventActive") then
            ply:PrintMessage(HUD_PRINTCENTER, "Disabled during Among Us event!")

            return false
        end

        if GetGlobalBool("AHQuizOver") then
            ply:PrintMessage(HUD_PRINTCENTER, "Try again next round!")

            return false
        end

        -- Updating near quiz ents now to guarantee it's up to date for functions below that use it! 
        nearQuizEnts = ents.FindInSphere(startQuizButtonPos, 200)

        if name == "button_quiz_begin" then
            SetGlobalEntity("AHBeginQuizButton", ent)

            if GetGlobalBool("AHQuizAllQuestionsAsked") then
                ply:PrintMessage(HUD_PRINTCENTER, "Wow, you've gone through every question! Come back next map!")
                AHEarnAchievement("gameshow")

                return false
            end

            -- Only show the intro when the quiz is first started
            if not GetGlobalBool("AHQuizIntroShown") then
                SetGlobalBool("AHQuizIntroShown", true)
                ChooseFirstQuestion(ply, ent)

                local welcomeMsgs = {"Welcome to the TTT Quiz!", "Correctly answer 3 questions to get a prize...", "...and come back next round for a new set of questions!", "Let's begin!"}

                timer.Create("AHQuizIntroMsgs", 1, #welcomeMsgs * 4, function()
                    local repsLeft = timer.RepsLeft("AHQuizIntroMsgs")
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

                    for _, nearEnt in ipairs(nearQuizEnts) do
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

                    -- Start the quiz after the intro!
                    if timer.RepsLeft("AHQuizIntroMsgs") == 0 then
                        SetGlobalBool("AHQuizIntroComplete", true)
                    end
                end)
            elseif not GetGlobalBool("AHQuizActive") then
                -- Immediately start the quiz if the intro has been shown before
                for _, nearEnt in ipairs(nearQuizEnts) do
                    if not IsPlayer(nearEnt) then continue end
                    nearEnt:PrintMessage(HUD_PRINTCENTER, "Here's a new set of questions!")
                    nearEnt:PrintMessage(HUD_PRINTTALK, "Here's a new set of questions!")
                end

                ChooseFirstQuestion(ply, ent)

                timer.Create("AHQuizImmediateIntro", 2, 1, function()
                    SetGlobalBool("AHQuizIntroComplete", true)
                end)
            end
            -- Processing an answer
        elseif GetGlobalString("AHQuizGivenAnswer", "noanswer") == "noanswer" and QuizActive() then
            -- Setting the given answer to the last letter of the button's name
            -- (Should be a, b, c or d)
            local givenAnswer = name[#name]
            SetGlobalString("AHQuizGivenAnswer", givenAnswer)
            local message = string.upper(givenAnswer) .. " is..."
            -- Some answers have special behaviour when they are given
            local answerFunction = nil

            if istable(Q.AnswerFunctions) and isfunction(Q.AnswerFunctions[givenAnswer]) then
                answerFunction = Q.AnswerFunctions[givenAnswer]
            end

            for _, nearEnt in ipairs(nearQuizEnts) do
                if not IsPlayer(nearEnt) then continue end
                nearEnt:PrintMessage(HUD_PRINTCENTER, message)
                nearEnt:PrintMessage(HUD_PRINTTALK, message)

                if isfunction(answerFunction) then
                    answerFunction(nearEnt, ent)
                end
            end

            timer.Create("AHQuizSuspense", 1, 4, function()
                if timer.RepsLeft("AHQuizSuspense") >= 2 then
                    for _, nearEnt in ipairs(nearQuizEnts) do
                        if not IsPlayer(nearEnt) then continue end
                        nearEnt:PrintMessage(HUD_PRINTCENTER, message)
                    end
                end

                if timer.RepsLeft("AHQuizSuspense") == 0 then
                    local correctAnswer = Q.CorrectAnswer

                    if isfunction(correctAnswer) then
                        correctAnswer = correctAnswer(ply, ent)
                    end

                    if correctAnswer == givenAnswer then
                        SetGlobalBool("AHQuizCorrect", true)

                        for _, nearEnt in ipairs(nearQuizEnts) do
                            if not IsPlayer(nearEnt) then continue end
                            nearEnt:PrintMessage(HUD_PRINTCENTER, "CORRECT!")
                            nearEnt:PrintMessage(HUD_PRINTTALK, "CORRECT!")
                        end

                        ent:EmitSound("ttt_achievement_hunt/custom_sounds/ding.mp3")
                        ent:EmitSound("ttt_achievement_hunt/custom_sounds/ding.mp3")
                    else
                        -- If an incorrect answer is given, ends the quiz
                        SetGlobalBool("AHQuizCorrect", false)

                        for _, nearEnt in ipairs(nearQuizEnts) do
                            if not IsPlayer(nearEnt) then continue end
                            nearEnt:PrintMessage(HUD_PRINTCENTER, "Incorrect...")
                            nearEnt:PrintMessage(HUD_PRINTTALK, "Incorrect...")
                        end

                        EndQuiz(ply, ent)
                    end

                    -- 2 seconds after showing the result, loads the next question or ends the quiz
                    timer.Create("AHQuizLoadNextQuestion", 2, 1, function()
                        if GetGlobalBool("AHQuizCorrect") then
                            -- Ends the quiz and gives a prize if 3 questions are answered correctly!
                            if GetGlobalInt("AHQuizQuestionNumber", 0) == 3 then
                                for _, nearEnt in ipairs(nearQuizEnts) do
                                    if not IsPlayer(nearEnt) then continue end
                                    nearEnt:PrintMessage(HUD_PRINTCENTER, "You correctly answered 3 questions!")
                                    nearEnt:PrintMessage(HUD_PRINTTALK, "You correctly answered 3 questions!")

                                    timer.Create("AHQuizPrize", 2, 1, function()
                                        local PrizeFunc = table.Random(AHQuizPrizes)["function"]
                                        PrizeFunc(nearEnt, ent)

                                        timer.Create("AHQuizEndWin", 2, 1, function()
                                            EndQuiz(ply, ent)
                                        end)
                                    end)
                                end
                            else
                                SetGlobalString("AHQuizGivenAnswer", "noanswer")
                                SetGlobalInt("AHQuizQuestionNumber", GetGlobalInt("AHQuizQuestionNumber", 0) + 1)
                                -- Randomly selecting a question that has not been asked before
                                local questionFound = false
                                local questionAsked = false

                                for _, question in RandomPairs(AHQuizQuestions) do
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

                                if not questionFound then
                                    table.Empty(askedQuestions)
                                    Q = table.Random(AHQuizQuestions)
                                    SetGlobalBool("AHQuizAllQuestionsAsked", true)
                                end

                                SetGlobalString("AHQuizQuestionID", Q.ID)
                                table.insert(askedQuestions, Q.ID)

                                -- Some questions need initialisation before being asked
                                if isfunction(Q.QuestionFunction) then
                                    Q.QuestionFunction(ply, ent)
                                end
                            end
                        else
                            for _, nearEnt in ipairs(nearQuizEnts) do
                                if not IsPlayer(nearEnt) then continue end
                                nearEnt:PrintMessage(HUD_PRINTCENTER, "Try again next round!")
                                nearEnt:PrintMessage(HUD_PRINTTALK, "Try again next round!")
                            end
                        end
                    end)
                end
            end)
        end
    end)

    hook.Add("TTTPrepareRound", "AHQuizReset", function()
        timer.Remove("AHGameshowSoundLoop")
        timer.Remove("AHQuizIncorrectReset")
        timer.Remove("AHQuizIntroMsgs")
        timer.Remove("AHQuizImmediateIntro")
        timer.Remove("AHQuizSuspense")
        timer.Remove("AHQuizLoadNextQuestion")
        timer.Remove("AHQuizPrize")
        timer.Remove("AHQuizEndWin")
        SetGlobalBool("AHQuizActive", false)
        SetGlobalBool("AHQuizIntroComplete", false)
        SetGlobalString("AHQuizGivenAnswer", "noanswer")
        SetGlobalBool("AHQuizCorrect", false)
        SetGlobalBool("AHQuizOver", false)
        SetGlobalInt("AHQuizQuestionNumber", 0)

        -- Cleanup any quiz prize
        for _, ply in ipairs(player.GetAll()) do
            for _, prize in pairs(AHQuizPrizes) do
                if isfunction(prize.reset) then
                    prize:reset(ply)
                end
            end
        end

        timer.Simple(1, function()
            for _, brushEnt in ipairs(ents.FindByName("brush_quiz_*")) do
                if brushEnt:GetName() == "brush_quiz_screen_green" then
                    brushEnt:Fire("Enable")
                else
                    brushEnt:Fire("Disable")
                end
            end
        end)
    end)
end

if CLIENT then
    -- Draws the quiz question boxes on the screen if the player is near the quiz buttons
    surface.CreateFont("AHQuizFont", {
        font = "Trebuchet24",
        size = 24,
        weight = 1000
    })

    local boxColour = Color(0, 0, 255)
    local halfScreenWidth = ScrW() / 2
    local halfScreenHeight = ScrH() / 2
    local questionXPos = halfScreenWidth
    local questionYPos = halfScreenHeight
    local answerXPos
    local answerYPos
    local textAlign
    local ply
    local questionText
    local questionNumber
    local Q = {}

    hook.Add("PostDrawHUD", "AHQuizUI", function()
        if not ply then
            ply = LocalPlayer()
        end

        -- Checking a question is set
        questionNumber = GetGlobalInt("AHQuizQuestionNumber", 0)
        if not ply:GetNWBool("AHNearQuiz") or not QuizActive() or questionNumber == 0 then return end
        questionID = GetGlobalString("AHQuizQuestionID", "noquestion")
        if questionID == "noquestion" then return end
        -- Loading the current question
        Q = AHQuizQuestions[questionID]
        questionText = "Question " .. questionNumber .. ": " .. Q.QuestionText
        -- Drawing the question box
        draw.WordBox(16, questionXPos, questionYPos, questionText, "AHQuizFont", boxColour, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Drawing the answer boxes
        for answerIndex, answerText in pairs(Q.AnswerText) do
            if isfunction(answerText) then
                answerText = answerText()
            end

            if answerIndex == "a" then
                answerText = "A: " .. answerText
                textAlign = TEXT_ALIGN_LEFT
                answerXPos = 0
                answerYPos = halfScreenHeight + (halfScreenHeight / 3)
            elseif answerIndex == "b" then
                answerText = "B: " .. answerText
                textAlign = TEXT_ALIGN_RIGHT
                answerXPos = halfScreenWidth * 2
                answerYPos = halfScreenHeight + (halfScreenHeight / 3)
            elseif answerIndex == "c" then
                answerText = "C: " .. answerText
                textAlign = TEXT_ALIGN_LEFT
                answerXPos = 0
                answerYPos = halfScreenHeight + (halfScreenHeight / 2)
            elseif answerIndex == "d" then
                answerText = "D: " .. answerText
                textAlign = TEXT_ALIGN_RIGHT
                answerXPos = halfScreenWidth * 2
                answerYPos = halfScreenHeight + (halfScreenHeight / 2)
            end

            draw.WordBox(16, answerXPos, answerYPos, answerText, "AHQuizFont", boxColour, COLOR_WHITE, textAlign, TEXT_ALIGN_CENTER)
        end
    end)
end