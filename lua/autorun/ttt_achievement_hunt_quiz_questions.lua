if not ((game.GetMap() == "ttt_achievement_hunt" or game.GetMap() == "ttt_achievement_hunt_final") and engine.ActiveGamemode() == "terrortown") then return end

local function PrintCentreShadowed(ply, text)
    net.Start("AHMapDisplayShadowedText")
    net.WriteString(text)
    net.WriteString("AHQuizFontLarge")
    net.WriteInt(2, 8)
    net.Send(ply)
    ply:ChatPrint(text)
end

-- Random prizes for correctly answering 3 questions in one round
AHQuizPrizes = {}

AHQuizPrizes.health = {
    ["function"] = function(ply)
        PrintCentreShadowed(ply, "Random prize: Full heal, 2x health!")
        ply:GetMaxHealth(ply:GetMaxHealth())
        ply:SetHealth(2 * ply:GetMaxHealth())
    end
}

AHQuizPrizes.knife = {
    ["function"] = function(ply)
        PrintCentreShadowed(ply, "Random prize: 1-shot knife!")
        local knife = ply:Give("weapon_ttt_knife")
        knife.Primary.Damage = 1000
    end
}

AHQuizPrizes.healthstation = {
    ["function"] = function(ply)
        PrintCentreShadowed(ply, "Random prize: Health station!")
        ply:Give("weapon_ttt_health_station")
    end
}

AHQuizPrizes.sprint = {
    ["function"] = function(ply)
        PrintCentreShadowed(ply, "Random prize: Super sprint!")
        ply.OGRunSpeed = ply:GetRunSpeed()
        ply:SetRunSpeed(ply:GetRunSpeed() * 1.5)
    end,
    ["reset"] = function(ply)
        if isnumber(ply.OGRunSpeed) then
            ply:SetRunSpeed(ply.OGRunSpeed)
        end
    end
}

AHQuizPrizes.damage = {
    ["function"] = function(ply)
        PrintCentreShadowed(ply, "Random prize: deal extra damage!")
        ply.AHDamageBonus = true

        hook.Add("EntityTakeDamage", "AHQuizDamageBonus", function(target, dmginfo)
            local attacker = dmginfo:GetAttacker()
            if not IsPlayer(attacker) then return end

            if attacker.AHDamageBonus then
                dmginfo:ScaleDamage(1.5)
            end
        end)
    end,
    ["reset"] = function(ply)
        hook.Remove("EntityTakeDamage", "AHQuizDamageBonus")
        ply.AHDamageBonus = false
    end
}

AHQuizPrizes.damageresist = {
    ["function"] = function(ply)
        PrintCentreShadowed(ply, "Random prize: damage resistance!")
        ply.AHDamageResistance = true

        hook.Add("EntityTakeDamage", "AHQuizDamageResistance", function(target, dmginfo)
            if target.AHDamageResistance then
                dmginfo:ScaleDamage(0.5)
            end
        end)
    end,
    ["reset"] = function(ply)
        hook.Remove("EntityTakeDamage", "AHQuizDamageResistance")
        ply.AHDamageResistance = false
    end
}

AHQuizPrizes.regen = {
    ["function"] = function(ply)
        PrintCentreShadowed(ply, "Random prize: Health Regen!")
        ply.AHRegen = true

        timer.Create("AHQuizRegen", 1, 0, function()
            for _, regenPly in ipairs(player.GetAll()) do
                if regenPly.AHRegen then
                    local health = regenPly:Health()
                    local maxHealth = regenPly:GetMaxHealth()

                    if health < maxHealth then
                        if health + 2 > maxHealth then
                            regenPly:SetHealth(maxHealth)
                        else
                            regenPly:SetHealth(health + 2)
                        end
                    end
                end
            end
        end)
    end,
    ["reset"] = function(ply)
        timer.Remove("AHQuizRegen")
        ply.AHRegen = false
    end
}

-- Defines what each of the quiz questions are
AHQuizQuestions = {}

AHQuizQuestions.polo = {
    ["Asked"] = false,
    ["ID"] = "polo",
    ["QuestionText"] = "How many holes in a polo?",
    ["AnswerText"] = {
        ["a"] = "One",
        ["b"] = "Two",
        ["c"] = "Three",
        ["d"] = "Four"
    },
    ["CorrectAnswer"] = "d"
}

AHQuizQuestions.time = {
    ["Asked"] = false,
    ["ID"] = "time",
    ["QuestionText"] = "What time is it?",
    ["AnswerText"] = {
        -- The actual local time of the server/client, formatted in 24-hour time
        ["a"] = function() return os.date("%I:%M %p", os.time()) end,
        ["b"] = "Summertime! It's our vacation...",
        ["c"] = "It's prop blasting time...",
        ["d"] = "It's time to du-du-du-du-dududududuel!"
    },
    ["CorrectAnswer"] = "a",
    ["AnswerFunctions"] = {
        ["b"] = function(ply, ent)
            ent:EmitSound("ttt_achievement_hunt/custom_sounds/what_time_is_it.mp3")
            ent:EmitSound("ttt_achievement_hunt/custom_sounds/what_time_is_it.mp3")
        end,
        ["c"] = function(ply, ent)
            ent:EmitSound("ttt_achievement_hunt/custom_sounds/chest_microsoft_word_blast.mp3")
            ent:EmitSound("ttt_achievement_hunt/custom_sounds/chest_microsoft_word_blast.mp3")
        end,
        ["d"] = function(ply, ent)
            ent:EmitSound("ttt_achievement_hunt/custom_sounds/time_to_duel.mp3")
            ent:EmitSound("ttt_achievement_hunt/custom_sounds/time_to_duel.mp3")
        end
    }
}

AHQuizQuestions.water = {
    ["Asked"] = false,
    ["ID"] = "water",
    ["QuestionText"] = "Does the water kill you?",
    ["AnswerText"] = {
        ["a"] = "Yes",
        ["b"] = "No",
        ["c"] = "Maybe",
        ["d"] = "Can you even tell?"
    },
    ["CorrectAnswer"] = function()
        if GetGlobalBool("AHQuizWaterKill") then
            return "a"
        else
            return "b"
        end
    end,
    ["QuestionFunction"] = function()
        for _, ent in ipairs(ents.FindByName("brush_quiz_water")) do
            ent:Fire("Enable")
        end

        if math.random() < 0.5 then
            SetGlobalBool("AHQuizWaterKill", true)

            for _, ent in ipairs(ents.FindByName("brush_quiz_water_kill")) do
                ent:Fire("Enable")
            end
        else
            SetGlobalBool("AHQuizWaterKill", false)
        end
    end
}

AHQuizQuestions.forevertraitor = {
    ["Asked"] = false,
    ["ID"] = "forevertraitor",
    ["QuestionText"] = "Forever traitor?",
    ["AnswerText"] = {
        ["a"] = "Forever traitor!",
        ["b"] = "I'm afraid I can't forever traitor...",
        ["c"] = "What?",
        ["d"] = "Wtf is a 'Forever traitor'?"
    },
    ["CorrectAnswer"] = function(ply, ent)
        if ply:GetRole() == ROLE_TRAITOR or (ply.IsTraitorTeam and ply:IsTraitorTeam()) then
            return "b"
        else
            return "a"
        end
    end,
    ["AnswerFunctions"] = {
        ["a"] = function(ply, ent)
            if ply:GetRole() == ROLE_TRAITOR or (ply.IsTraitorTeam and ply:IsTraitorTeam()) then
                ply:Kill()
                ply:ChatPrint("You broke forever traitor!")
            end
        end
    }
}

AHQuizQuestions.bucket = {
    ["Asked"] = false,
    ["ID"] = "bucket",
    ["QuestionText"] = "Is this a bucket?",
    ["AnswerText"] = {
        ["a"] = "Yes",
        ["b"] = "No",
        ["c"] = "...why wouldn't it be?",
        ["d"] = "Is it not?"
    },
    ["CorrectAnswer"] = "a",
    ["QuestionFunction"] = function()
        local bucket = ents.Create("prop_physics")
        bucket:SetModel("models/props_junk/metalbucket01a.mdl")
        bucket:PhysicsInit(SOLID_VPHYSICS)
        bucket:SetMoveType(MOVETYPE_VPHYSICS)
        bucket:SetSolid(SOLID_VPHYSICS)
        bucket:GetPhysicsObject():SetMass(0.5)
        bucket:SetPos(Vector(1340, -3584, 778))
        bucket:Spawn()
    end
}

AHQuizQuestions.airboat = {
    ["Asked"] = false,
    ["ID"] = "airboat",
    ["QuestionText"] = "Would running into someone with an airboat hurt them?",
    ["AnswerText"] = {
        ["a"] = "Uh... of course it would?",
        ["b"] = "No, it wouldn't!",
        ["c"] = "You mean in real life or TTT?",
        ["d"] = "Airboats?"
    },
    ["CorrectAnswer"] = function(ply, ent)
        if GetGlobalBool("AHQuizAirboatTTT") then
            return "b"
        else
            return "a"
        end
    end,
    ["AnswerFunctions"] = {
        ["a"] = function(ply, ent)
            if GetGlobalBool("AHQuizAirboatTTT") then
                ply:ChatPrint("Everyone knows airboats don't damage people in TTT...")
            end
        end,
        ["b"] = function(ply, ent)
            if not GetGlobalBool("AHQuizAirboatTTT") then
                ply:ChatPrint("What? Of course hitting someone with an airboat would hurt!")
            end
        end
    },
    ["QuestionFunction"] = function(ply, ent)
        if math.random() < 0.5 then
            SetGlobalBool("AHQuizAirboatTTT", true)
        else
            SetGlobalBool("AHQuizAirboatTTT", false)
        end
    end
}

AHQuizQuestions.maplength = {
    ["Asked"] = false,
    ["ID"] = "maplength",
    ["QuestionText"] = "How long did this map take to make?",
    ["AnswerText"] = {
        ["a"] = "3 weeks",
        ["b"] = "1 month",
        ["c"] = "3 months",
        ["d"] = "4 months"
    },
    ["CorrectAnswer"] = "d"
}

AHQuizQuestions.woodchuck = {
    ["Asked"] = false,
    ["ID"] = "woodchuck",
    ["QuestionText"] = "How much wood would a woodchuck chuck if a woodchuck could chuck wood?",
    ["AnswerText"] = {
        ["a"] = "A woodchuck would chuck as much wood as a woodchuck could chuck if a woodchuck could chuck wood",
        ["b"] = "So much wood would a woodchuck chuck as a woodchuck would if a woodchuck could chuck wood!",
        ["c"] = "It would chuck, it would, as much as it could, and chuck as much wood as a woodchuck would if a woodchuck could chuck wood",
        ["d"] = "3"
    },
    ["CorrectAnswer"] = "a"
}

AHQuizQuestions.stillalive = {
    ["Asked"] = false,
    ["ID"] = "stillalive",
    ["QuestionText"] = "Is anyone else still alive?",
    ["AnswerText"] = {
        ["a"] = "Yes",
        ["b"] = "*silence*",
        ["c"] = "Perhaps",
        ["d"] = "No"
    },
    ["CorrectAnswer"] = function(ply, ent)
        if GetGlobalBool("AHQuizStillAlive") then
            return "a"
        else
            return "d"
        end
    end,
    ["AnswerFunctions"] = {
        ["a"] = function(activatePly, _)
            SetGlobalBool("AHQuizStillAlive", false)

            for _, ply in ipairs(player.GetAll()) do
                if ply ~= activatePly and ply:Alive() and not ply:IsSpec() then
                    SetGlobalBool("AHQuizStillAlive", true)
                    break
                end
            end
        end,
        ["b"] = function(activatePly, _)
            SetGlobalBool("AHQuizStillAlive", false)

            for _, ply in ipairs(player.GetAll()) do
                if ply ~= activatePly and ply:Alive() and not ply:IsSpec() then
                    SetGlobalBool("AHQuizStillAlive", true)
                    break
                end
            end
        end,
        ["c"] = function(activatePly, _)
            SetGlobalBool("AHQuizStillAlive", false)

            for _, ply in ipairs(player.GetAll()) do
                if ply ~= activatePly and ply:Alive() and not ply:IsSpec() then
                    SetGlobalBool("AHQuizStillAlive", true)
                    break
                end
            end
        end,
        ["d"] = function(activatePly, _)
            SetGlobalBool("AHQuizStillAlive", false)

            for _, ply in ipairs(player.GetAll()) do
                if ply ~= activatePly and ply:Alive() and not ply:IsSpec() then
                    SetGlobalBool("AHQuizStillAlive", true)
                    break
                end
            end
        end
    }
}

if SERVER then
    util.AddNetworkString("AHQuizWeaponName")
end

AHQuizQuestions.gunholding = {
    ["Asked"] = false,
    ["ID"] = "gunholding",
    ["QuestionText"] = "What's that weapon you have?",
    ["AnswerText"] = {
        ["a"] = "Nothing...",
        ["b"] = "Just a normal gun",
        ["c"] = function(_, _) return GetGlobalString("AHQuizGunHolding", "A weapon of some kind...") end,
        ["d"] = "It was just a crowbar!"
    },
    ["CorrectAnswer"] = "c",
    ["QuestionFunction"] = function(ply, ent)
        net.Start("AHQuizWeaponName")
        net.Send(ply)

        net.Receive("AHQuizWeaponName", function()
            local name = net.ReadString()
            SetGlobalString("AHQuizGunHolding", name)
        end)
    end
}

if CLIENT then
    net.Receive("AHQuizWeaponName", function()
        local name = "A weapon of some kind..."
        local wep = LocalPlayer():GetActiveWeapon()

        for _, heldWep in RandomPairs(LocalPlayer():GetWeapons()) do
            if istable(heldWep.CanBuy) and heldWep.CanBuy ~= {} then
                wep = heldWep
                break
            end
        end

        if isstring(wep.PrintName) then
            name = LANG.TryTranslation(wep.PrintName)
        end

        net.Start("AHQuizWeaponName")
        net.WriteString(name)
        net.SendToServer()
    end)
end

AHQuizQuestions.whosbad = {
    ["Asked"] = false,
    ["ID"] = "whosbad",
    ["QuestionText"] = "Who's bad?",
    ["AnswerText"] = {
        ["a"] = "No-one",
        ["b"] = "We don't know",
        ["c"] = function(ply, ent) return GetGlobalString("AHQuizWhosBad", "Someone") end,
        ["d"] = "Michael Jackson"
    },
    ["CorrectAnswer"] = function(ply, ent)
        if GetGlobalString("AHQuizWhosBad", "Someone") ~= "Someone" then
            return "c"
        else
            return "d"
        end
    end,
    ["QuestionFunction"] = function()
        SetGlobalString("AHQuizWhosBad", "Someone")

        for _, ply in RandomPairs(player.GetAll()) do
            if ply.IsTraitorTeam and ply:IsTraitorTeam() then
                SetGlobalString("AHQuizWhosBad", ply:Nick())
                break
            elseif ply:GetRole() == ROLE_TRAITOR then
                SetGlobalString("AHQuizWhosBad", ply:Nick())
                break
            end
        end
    end
}

AHQuizQuestions.rickroll = {
    ["Asked"] = false,
    ["ID"] = "rickroll",
    ["QuestionText"] = "Rick Astley has the movie “UP”. If he weren't to give it to you, that would disappoint you, does he...",
    ["AnswerText"] = {
        ["a"] = "Give you up",
        ["b"] = "Let you down",
        ["c"] = "Run around",
        ["d"] = "Desert you"
    },
    ["CorrectAnswer"] = "z",
    ["AnswerFunctions"] = {
        ["a"] = function(ply, _)
            ply:ChatPrint("But he is never gonna give you up!")
        end,
        ["b"] = function(ply, _)
            ply:ChatPrint("But he is never gonna let you down!")
        end,
        ["c"] = function(ply, _)
            ply:ChatPrint("But he is never gonna run around!")
        end,
        ["d"] = function(ply, _)
            ply:ChatPrint("But he is never gonna desert you!")
        end
    }
}

AHQuizQuestions.rdm = {
    ["Asked"] = false,
    ["ID"] = "rdm",
    ["QuestionText"] = "What does RDM stand for?",
    ["AnswerText"] = {
        ["a"] = "RythianDoingMurders",
        ["b"] = "RandomDeathMatch",
        ["c"] = "RandomlyDoneMurder",
        ["d"] = "ReallyDickMove"
    },
    ["CorrectAnswer"] = "b"
}

AHQuizQuestions.life = {
    ["Asked"] = false,
    ["ID"] = "life",
    ["QuestionText"] = "What is the meaning of life, the universe, and everything?",
    ["AnswerText"] = {
        ["a"] = "Ah, but to understand the answer, what is the question?",
        ["b"] = "Blackjack and hookers",
        ["c"] = "Don't speak if you're dead!",
        ["d"] = "42"
    },
    ["CorrectAnswer"] = "d"
}

AHQuizQuestions.randomats = {
    ["Asked"] = false,
    ["ID"] = "randomats",
    ["QuestionText"] = "How many different randomats are there?",
    ["AnswerText"] = {
        ["a"] = "Whats a randomat?",
        ["b"] = "200-300",
        ["c"] = "300-400",
        ["d"] = "400+"
    },
    ["CorrectAnswer"] = "c"
}

AHQuizQuestions.ligma = {
    ["Asked"] = false,
    ["ID"] = "ligma",
    ["QuestionText"] = "What's Ligma?",
    ["AnswerText"] = {
        ["a"] = "A disease",
        ["b"] = "Nonsense",
        ["c"] = "A joke",
        ["d"] = "Ligma balls"
    },
    ["CorrectAnswer"] = "d"
}

AHQuizQuestions.tneconni = {
    ["Asked"] = false,
    ["ID"] = "tneconni",
    ["QuestionText"] = "Which of these is not a pasta?",
    ["AnswerText"] = {
        ["a"] = "cavatelli",
        ["b"] = "paccheri",
        ["c"] = "tneconni",
        ["d"] = "ravioli"
    },
    ["CorrectAnswer"] = "c",
    ["AnswerFunctions"] = {
        ["c"] = function(ply, _)
            ply:ChatPrint("Yep, that's 'innocent' backwards!")
        end
    }
}