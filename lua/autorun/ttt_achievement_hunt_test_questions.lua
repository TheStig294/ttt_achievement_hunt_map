if not ((game.GetMap() == "ttt_achievement_hunt" or game.GetMap() == "ttt_achievement_hunt_final") and engine.ActiveGamemode() == "terrortown") then return end
-- Props and descriptions for the different personalities given during the end of the "Prop-sonality quiz" in the ttt_achievement_hunt map
AHTestNatures = {}

AHTestNatures.Bold = {
    ["ID"] = "Bold",
    ["Description"] = "The Bold Type! - You're so brave, and you never back down from anything!\nAnd you're also gutsy and brash in a way that others aren't!\nYou're not shy about asking to take home all the leftovers at restaurants, right?\nIf someone's treating you to dinner, you have no problem with ordering lots of good stuff!\nAnd you aren't fazed by doing things that most others would think twice about doing.\nPerhaps you don't even notice when others are upset with you!\nYou know, you have the potential to become a truly great person...because you'll be the last one standing!\nSo, a bold type like you should be...",
    ["Prop"] = "models/props_c17/streetsign005d.mdl",
    ["PropName"] = "a danger sign!"
}

AHTestNatures.Brave = {
    ["ID"] = "Brave",
    ["Description"] = "The Brave Type! - You don't know the meaning of fear!\nYou're not afraid to keep moving forward in the face of danger.\nYou also have a strong sense of justice and can't turn a blind eye to someone in trouble.\nBut you sometimes push your own personal sense of justice a little too hard.\nBe careful that you don't get too pushy!\nSo, a brave type like you should be...",
    ["Prop"] = "models/props_junk/harpoon002a.mdl",
    ["PropName"] = "a harpoon!"
}

AHTestNatures.Calm = {
    ["ID"] = "Calm",
    ["Description"] = "The Calm Type! - You're very compassionate and considerate, and you put friends ahead of yourself.\nYou're so generous and kindhearted that you can laugh, forgive, and forget when your friends make mistakes.\nBut be aware that your compassion can sometimes get the best of you, putting you too far behind everyone else!\nSo, a calm type like you should be...",
    ["Prop"] = "models/maxofs2d/gm_painting.mdl",
    ["PropName"] = "a painting!"
}

AHTestNatures.Docile = {
    ["ID"] = "Docile",
    ["Description"] = "The Docile Type! - You're quite sensitive to others!\nYou listen attentively and respectfully, and you're quick to pick up on things.\nBecause you're so good at listening, do you find that your friends tell you their problems and concerns often?\nPerhaps people laugh at you sometimes for being so earnest and not recognizing jokes for what they are.\nBut you're honestly surprised and bashful about this aspect of yourself...And then honestly laugh about it!\nSo, a docile, sensitive type like you should be...",
    ["Prop"] = "models/maxofs2d/companion_doll.mdl",
    ["PropName"] = "a doll!"
}

AHTestNatures.Hardy = {
    ["ID"] = "Hardy",
    ["Description"] = "The Hardy Type! - You're so determined!\nYou don't whine or feel sorry for yourself, and you never need help with anything.\nYou also have a strong sense of responsibility.\nYou work toward your goals steadily and never require attention along the way.\nYour resilient spirit is the only thing you need to guide you toward your goals.\nBut be careful!\nYou risk wearing yourself out if you work too long all on your own!\nYou should recognize that sometimes you need help from friends.\nSo, a hardy, determined type like you should be...",
    ["Prop"] = "models/props_c17/oildrum001.mdl",
    ["PropName"] = "a barrel!"
}

AHTestNatures.Hasty = {
    ["ID"] = "Hasty",
    ["Description"] = "The Hasty Type! - You talk quickly!\nYou eat quickly!\nYou walk quickly!\nPeople often see you as a hard worker because you're always moving around so fast!\nBut be careful!\nIf you always rush so fast, you may make mistakes more often than others do.\nAnd what a waste that would be!\nRelax every now and then with a nice, deep breath!\nSo, a hasty type like you should be...",
    ["Prop"] = "models/xqm/jetbody3.mdl",
    ["PropName"] = "a jet!"
}

AHTestNatures.Impish = {
    ["ID"] = "Impish",
    ["Description"] = "The Impish Type! - You're cheerful, and you love pranks.\nYou love competition, but you hate losing.\nYour personality seems crystal clear to others.\nWith you, what you see is what you get!\nYou cheer others with your dazzling smile.\nBut you may be afraid of showing what's in your heart and revealing your true self.\nYou may not want to keep your worries to yourself.\nYou're only human, so ask your friends for advice when you need it.\nSo, an impish type like you should be...",
    ["Prop"] = "models/props_c17/oildrum001_explosive.mdl",
    ["PropName"] = "an explosive barrel!"
}

AHTestNatures.Jolly = {
    ["ID"] = "Jolly",
    ["Description"] = "The Jolly Type! - Always laughing and smiling, you uplift everyone around you.\nYou love jokes!\nYou have a good sense of humor, and you're compassionate.\nYou're always making others around you laugh.\nYou have a sunny, positive outlook, and you have a vitality that raises the lowest spirits to giddy heights!\nBut sometimes you get carried away and say things that get you in trouble.\nWhat an adventure life must be like for you, bouncing around like that all day!\nSo, a jolly type like you should be...",
    ["Prop"] = "models/balloons/balloon_star.mdl",
    ["PropName"] = "a balloon!"
}

AHTestNatures.Quiet = {
    ["ID"] = "Quiet",
    ["Description"] = "The Quiet Type! - And very calm!\nYou're great with numbers, and you analyze information before making decisions.\nYou rarely make mistakes, because you make decisions so calmly and rationally.\nYou also may find it hard to guess what others are thinking, and they may find you a touch cold at times.\nYou may not want to keep your feelings to yourself so much of the time.\nSo, a quiet and calm type like you should be...",
    ["Prop"] = "models/props_lab/chess.mdl",
    ["PropName"] = "a chess board!"
}

AHTestNatures.Quirky = {
    ["ID"] = "Quirky",
    ["Description"] = "The Quirky Type! - You want to be on the cutting edge of fashion!\nYou want to own all the latest stuff, right? But you grow bored of your old things and only like new things!\nYou're true to your emotions, and you follow your desires.\nPeople have a hard time keeping up with you because you change so quickly.\nYou may want to reflect upon how your words and actions affect others.\nSo, a quirky type like you should be...",
    ["Prop"] = "models/player/items/humans/top_hat.mdl",
    ["PropName"] = "a top hat!"
}

AHTestNatures.Rash = {
    ["ID"] = "Rash",
    ["Description"] = "The Rash Type! - You seem to be even a bit hasty at times!\nYou may run out of your house an forget to lock the door once in a while.\nAnd you may leave things like umbrellas behind when you leave places.\nMaybe you even dash outside in your slippers every now and then!\nPerhaps you even wear your shirts inside out all the time!\nOh, is that even rasher than you really are? So sorry!\nBut know that your friends think your funny little flubs are adorable!\nSo, without further ado...a rash and hasty type like you should be...",
    ["Prop"] = "models/nateswheel/nateswheel.mdl",
    ["PropName"] = "a wheel!"
}

AHTestNatures.Relaxed = {
    ["ID"] = "Relaxed",
    ["Description"] = "The Relaxed type! - You're so casual, leisurely, and carefree.\nYou don't rush or stress yourself out, and you don't worry about anything.\nYou like to take a seat and kick up your feet!\nYou definitely have an easygoing personality, and you don't sweat the details.\nPeople naturally flock to you because they find you to be a free spirit, which is so refreshing!\nSo, a relaxed type like you should be...",
    ["Prop"] = "models/props_interiors/Furniture_Couch02a.mdl",
    ["PropName"] = "a couch!"
}

-- The "Prop-sonality quiz" questions and each answer's points towards each personality type
AHTestQuestions = {}

AHTestQuestions.Blurt = {
    ["ID"] = "Blurt",
    ["QuestionText"] = "Have you ever blurted something out without thinking about the consequences first?",
    ["AnswerText"] = {"Yes", "No"},
    ["Points"] = {
        {
            ["Relaxed"] = 2
        },
        {
            ["Hardy"] = 1
        }
    }
}

AHTestQuestions.Decided = {
    ["ID"] = "Decided",
    ["QuestionText"] = "Once you've decided something, do you see it through to the end?",
    ["AnswerText"] = {"Yes", "No"},
    ["Points"] = {
        {
            ["Hardy"] = 2
        },
        {
            ["Quirky"] = 1
        }
    }
}

AHTestQuestions.Meet = {
    ["ID"] = "Meet",
    ["QuestionText"] = "Have you ever said \"nice to meet you\" to someone you've met previously?",
    ["AnswerText"] = {"Yes", "No"},
    ["Points"] = {
        {
            ["Brave"] = 2,
            ["Relaxed"] = 1
        },
        {
            ["Calm"] = 1
        }
    }
}

AHTestQuestions.Mirror = {
    ["ID"] = "Mirror",
    ["QuestionText"] = "Have you ever looked at your reflection in a mirror and thought, \"What a cool person\"?",
    ["AnswerText"] = {"Certainly!", "Well, not really..."},
    ["Points"] = {
        {
            ["Jolly"] = 1
        },
        {
            ["Calm"] = 1
        }
    }
}

AHTestQuestions.Outside = {
    ["ID"] = "Outside",
    ["QuestionText"] = "Do you prefer to be outside rather than inside?",
    ["AnswerText"] = {"Outside", "Inside"},
    ["Points"] = {
        {
            ["Bold"] = 1,
            ["Jolly"] = 2,
            ["Relaxed"] = 1
        },
        {
            ["Calm"] = 1
        }
    }
}

AHTestQuestions.Hogging = {
    ["ID"] = "Hogging",
    ["QuestionText"] = "Have you ever realized you were hogging the conversation?",
    ["AnswerText"] = {"Yes", "No"},
    ["Points"] = {
        {
            ["Rash"] = 2
        },
        {
            ["Docile"] = 1,
            ["Quiet"] = 1
        }
    }
}

AHTestQuestions.Switch = {
    ["ID"] = "Switch",
    ["QuestionText"] = "When you see a switch, do you feel an overwhelming urge to flip it?",
    ["AnswerText"] = {"Yes", "No"},
    ["Points"] = {
        {
            ["Hasty"] = 2
        },
        {
            ["Calm"] = 1
        }
    }
}

AHTestQuestions.Bought = {
    ["ID"] = "Bought",
    ["QuestionText"] = "Have you ever forgotten you bought something and bought another one?",
    ["AnswerText"] = {"Yes", "No"},
    ["Points"] = {
        {
            ["Hasty"] = 1,
            ["Quirky"] = 2,
            ["Rash"] = 1
        },
        {
            ["Quiet"] = 1
        }
    }
}

AHTestQuestions.Joke = {
    ["ID"] = "Joke",
    ["QuestionText"] = "Have you ever told a joke that just completely fell flat?",
    ["AnswerText"] = {"Yes", "No"},
    ["Points"] = {
        {
            ["Impish"] = 1
        },
        {
            ["Calm"] = 2
        }
    }
}

AHTestQuestions.Parties = {
    ["ID"] = "Parties",
    ["QuestionText"] = "Do you like lively parties?",
    ["AnswerText"] = {"Yes", "No"},
    ["Points"] = {
        {
            ["Jolly"] = 2
        },
        {
            ["Quiet"] = 1
        }
    }
}

AHTestQuestions.Karaoke = {
    ["ID"] = "Karaoke",
    ["QuestionText"] = "Do you like karaoke?",
    ["AnswerText"] = {"Yes", "No"},
    ["Points"] = {
        {
            ["Jolly"] = 2
        },
        {
            ["Hasty"] = 1
        }
    }
}

AHTestQuestions.Paths = {
    ["ID"] = "Paths",
    ["QuestionText"] = "You're hiking up a mountain when you reach diverging paths. Which kind do you take?",
    ["AnswerText"] = {"Narrow", "Wide"},
    ["Points"] = {
        {
            ["Impish"] = 2
        },
        {
            ["Quirky"] = 2
        }
    }
}

AHTestQuestions.Fall = {
    ["ID"] = "Fall",
    ["QuestionText"] = "Your friend takes a spectacular fall! What do you do?",
    ["AnswerText"] = {"Help my friend up!", "Laugh! It's too funny!"},
    ["Points"] = {
        {
            ["Brave"] = 2
        },
        {
            ["Impish"] = 2,
            ["Rash"] = 1
        }
    }
}

AHTestQuestions.Late = {
    ["ID"] = "Late",
    ["QuestionText"] = "Your friend is running a little late to meet you. Is that OK?",
    ["AnswerText"] = {"Yes", "Not at all!"},
    ["Points"] = {
        {
            ["Bold"] = 2,
            ["Relaxed"] = 1
        },
        {
            ["Hasty"] = 1
        }
    }
}

AHTestQuestions.Life = {
    ["ID"] = "Life",
    ["QuestionText"] = "Do you think that, no matter what, life goes on?",
    ["AnswerText"] = {"All the time!", "Never"},
    ["Points"] = {
        {
            ["Jolly"] = 1,
            ["Relaxed"] = 2
        },
        {
            ["Quiet"] = 1
        }
    }
}

AHTestQuestions.Blame = {
    ["ID"] = "Blame",
    ["QuestionText"] = "Do you think blaming something you did on someone else is sometimes necessary?",
    ["AnswerText"] = {"Of course!", "No way!"},
    ["Points"] = {
        {
            ["Quiet"] = 2
        },
        {
            ["Brave"] = 2
        }
    }
}

AHTestQuestions.Movie = {
    ["ID"] = "Movie",
    ["QuestionText"] = "You're at a movie theater. What are you there to see?",
    ["AnswerText"] = {"An action movie", "A drama", "A romantic movie"},
    ["Points"] = {
        {
            ["Impish"] = 2
        },
        {
            ["Hardy"] = 2
        },
        {
            ["Quirky"] = 2
        }
    }
}

AHTestQuestions.Exam = {
    ["ID"] = "Exam",
    ["QuestionText"] = "You have an exam tomorrow! What do you do?",
    ["AnswerText"] = {"Study all night long", "Get some sleep! I'm sure it will be fine!"},
    ["Points"] = {
        {
            ["Hardy"] = 2
        },
        {
            ["Relaxed"] = 2
        }
    }
}

AHTestQuestions.Snacks = {
    ["ID"] = "Snacks",
    ["QuestionText"] = "You're packing snacks for a party when you get hungry. What do you do?",
    ["AnswerText"] = {"Eat just a tiny bit", "Hold myself back and pack it all up", "What snacks? They're in my belly!"},
    ["Points"] = {
        {
            ["Hasty"] = 2
        },
        {
            ["Hardy"] = 2
        },
        {
            ["Rash"] = 2
        }
    }
}

AHTestQuestions.Expiration = {
    ["ID"] = "Expiration",
    ["QuestionText"] = "You see a cake that is past its expiration date, but only by one day. What do you do?",
    ["AnswerText"] = {"Not a problem! Chow time!", "Throw it out straight away", "Get someone to try it first."},
    ["Points"] = {
        {
            ["Brave"] = 2,
            ["Relaxed"] = 1
        },
        {
            ["Hasty"] = 2
        },
        {
            ["Bold"] = 2
        }
    }
}

AHTestQuestions.Stuffed = {
    ["ID"] = "Stuffed",
    ["QuestionText"] = "You've just stuffed yourself with a good meal when a great dessert arrives. What do you do?",
    ["AnswerText"] = {"Eat it. Who cares if I'm stuffed?", "Turn it down. It's too fattening!", "Yum! I love dessert the most!"},
    ["Points"] = {
        {
            ["Hasty"] = 2,
            ["Rash"] = 1
        },
        {
            ["Hardy"] = 1
        },
        {
            ["Bold"] = 2,
            ["Jolly"] = 2,
            ["Relaxed"] = 1
        }
    }
}

AHTestQuestions.Terrible = {
    ["ID"] = "Terrible",
    ["QuestionText"] = "Your friend has made a meal that tastes terrible. They ask, \"How is it?\" You say...?",
    ["AnswerText"] = {"Terrible!", "Just smile", "\"Um, it's...good.\""},
    ["Points"] = {
        {
            ["Brave"] = 1,
            ["Quiet"] = 1
        },
        {
            ["Calm"] = 2
        },
        {
            ["Rash"] = 1
        }
    }
}

AHTestQuestions.Fancy = {
    ["ID"] = "Fancy",
    ["QuestionText"] = "You're eating at a very fancy restaurant known for its food. Which course do you select?",
    ["AnswerText"] = {"Seared steak", "Healthy fish", "Anything! It's all good!"},
    ["Points"] = {
        {
            ["Impish"] = 2
        },
        {
            ["Hardy"] = 1
        },
        {
            ["Bold"] = 2
        }
    }
}

AHTestQuestions.Dessert = {
    ["ID"] = "Dessert",
    ["QuestionText"] = "Everyone's sharing a dessert, and there's an extra piece. What do you do?",
    ["AnswerText"] = {"Don't tell anyone", "Let everyone know", "First come, first served!"},
    ["Points"] = {
        {
            ["Bold"] = 2
        },
        {
            ["Docile"] = 2,
            ["Rash"] = 2
        },
        {
            ["Impish"] = 2
        }
    }
}

AHTestQuestions.Dinner = {
    ["ID"] = "Dinner",
    ["QuestionText"] = "Your friend offers to treat you to dinner. What do you do?",
    ["AnswerText"] = {"I'm there!", "Allow me.", "Thanks..."},
    ["Points"] = {
        {
            ["Bold"] = 2
        },
        {
            ["Jolly"] = 2
        },
        {
            ["Quirky"] = 2
        }
    }
}

AHTestQuestions.Laughing = {
    ["ID"] = "Laughing",
    ["QuestionText"] = "Everyone around you is laughing hard at something you think is pretty boring. What do you do?",
    ["AnswerText"] = {"Nothing, really.", "Laugh along", "It depends on the situation"},
    ["Points"] = {
        {
            ["Brave"] = 2,
            ["Bold"] = 1
        },
        {
            ["Docile"] = 1
        },
        {
            ["Quiet"] = 1,
            ["Quirky"] = 1
        }
    }
}

AHTestQuestions.Busy = {
    ["ID"] = "Busy",
    ["QuestionText"] = "Do you prefer to be busy or to have a lot of free time?",
    ["AnswerText"] = {"Being busy", "Free time!", "In between"},
    ["Points"] = {
        {
            ["Hardy"] = 1,
            ["Hasty"] = 1
        },
        {
            ["Calm"] = 2
        },
        {
            ["Quirky"] = 2
        }
    }
}

AHTestQuestions.Last = {
    ["ID"] = "Last",
    ["QuestionText"] = "You're about to buy the last one of something, when someone else gets to it first! How do you feel?",
    ["AnswerText"] = {"Whatever", "Annoyed. I was here first!"},
    ["Points"] = {
        {
            ["Calm"] = 2
        },
        {
            ["Jolly"] = 2,
            ["Relaxed"] = 2
        }
    }
}

AHTestQuestions.New = {
    ["ID"] = "New",
    ["QuestionText"] = "You run into a new person that you haven't talked to very much before. What do you do?",
    ["AnswerText"] = {"Make small talk", "Say nothing!", "Make an excuse to get away!"},
    ["Points"] = {
        {
            ["Calm"] = 1
        },
        {
            ["Quirky"] = 1
        },
        {
            ["Quiet"] = 2
        }
    }
}

AHTestQuestions.Socks = {
    ["ID"] = "Socks",
    ["QuestionText"] = "You take off your shoes to realize your socks are two different colors! What do you do?",
    ["AnswerText"] = {"Get embarrassed!", "Again?!", "I meant to do that!"},
    ["Points"] = {
        {
            ["Docile"] = 2
        },
        {
            ["Rash"] = 2
        },
        {
            ["Jolly"] = 2
        }
    }
}

AHTestQuestions.News = {
    ["ID"] = "News",
    ["QuestionText"] = "Good news and bad news... Which one do you want to hear first?",
    ["AnswerText"] = {"The good news", "The bad news"},
    ["Points"] = {
        {
            ["Relaxed"] = 2
        },
        {
            ["Bold"] = 1
        }
    }
}

AHTestQuestions.Resolutions = {
    ["ID"] = "Resolutions",
    ["QuestionText"] = "Did you make any New Year's resolutions?",
    ["AnswerText"] = {"Of course!", "Nope."},
    ["Points"] = {
        {
            ["Hardy"] = 2
        },
        {
            ["Quirky"] = 2,
            ["Rash"] = 1
        }
    }
}

AHTestQuestions.Marathon = {
    ["ID"] = "Marathon",
    ["QuestionText"] = "You're running a marathon, and at the start you fall flat on your face! What will you do?",
    ["AnswerText"] = {"I'm not giving up yet!", "Just give up.", "Shout, \"START OVER!\""},
    ["Points"] = {
        {
            ["Brave"] = 1,
            ["Hardy"] = 2
        },
        {
            ["Rash"] = 2
        },
        {
            ["Quirky"] = 2
        }
    }
}

AHTestQuestions.Difficult = {
    ["ID"] = "Difficult",
    ["QuestionText"] = "You've been asked to do a difficult task. What will you do?",
    ["AnswerText"] = {"Do it myself", "Ask someone to help", "Make someone else do it!"},
    ["Points"] = {
        {
            ["Brave"] = 1,
            ["Hardy"] = 2
        },
        {
            ["Docile"] = 1
        },
        {
            ["Bold"] = 2
        }
    }
}

AHTestQuestions.Price = {
    ["ID"] = "Price",
    ["QuestionText"] = "You notice that something you bought yesterday is marked down to half price! How do you feel?",
    ["AnswerText"] = {"Heartbroken...", "Aaaargh!", "Bad timing, I guess..."},
    ["Points"] = {
        {
            ["Hardy"] = 2
        },
        {
            ["Docile"] = 2
        },
        {
            ["Bold"] = 2,
            ["Calm"] = 2
        }
    }
}

AHTestQuestions.Phone = {
    ["ID"] = "Phone",
    ["QuestionText"] = "The phone's ringing! What do you do?",
    ["AnswerText"] = {"Answer right away!", "Wait a bit before answering"},
    ["Points"] = {
        {
            ["Hasty"] = 2
        },
        {
            ["Quiet"] = 1
        }
    }
}

AHTestQuestions.Win = {
    ["ID"] = "Win",
    ["QuestionText"] = "You've won a cash prize! Big time! You say...",
    ["AnswerText"] = {"Woo-hoo!", "Best not tell too many others..."},
    ["Points"] = {
        {
            ["Hasty"] = 1,
            ["Jolly"] = 1
        },
        {
            ["Quiet"] = 2
        }
    }
}

AHTestQuestions.TV = {
    ["ID"] = "TV",
    ["QuestionText"] = "You're on a stroll when a TV crew pounces on you for an interview. What do you do?",
    ["AnswerText"] = {"Answer questions properly", "Yuck it up! Woo-hoo! I'm on TV!"},
    ["Points"] = {
        {
            ["Brave"] = 2
        },
        {
            ["Bold"] = 2
        }
    }
}

AHTestQuestions.Mornings = {
    ["ID"] = "Mornings",
    ["QuestionText"] = "How are your mornings?",
    ["AnswerText"] = {"Always in a rush!", "Always perfect", "They are OK"},
    ["Points"] = {
        {
            ["Brave"] = 2,
            ["Impish"] = 2
        },
        {
            ["Quiet"] = 1
        },
        {
            ["Docile"] = 1
        }
    }
}

AHTestQuestions.Party = {
    ["ID"] = "Party",
    ["QuestionText"] = "You've been invited to a wonderful party. It's time for the party to start, but there's nobody there! You think...?",
    ["AnswerText"] = {"Did something happen?", "Maybe I have the day wrong?", "Let's get this party started!"},
    ["Points"] = {
        {
            ["Docile"] = 2
        },
        {
            ["Jolly"] = 2,
            ["Relaxed"] = 2
        },
        {
            ["Bold"] = 2
        }
    }
}

AHTestQuestions.Studying = {
    ["ID"] = "Studying",
    ["QuestionText"] = "What's your studying style?",
    ["AnswerText"] = {"Working hard, every day", "If I remember to...", "I just cover what I need to"},
    ["Points"] = {
        {
            ["Hardy"] = 2
        },
        {
            ["Quirky"] = 2,
            ["Hasty"] = 1
        },
        {
            ["Quiet"] = 1
        }
    }
}

AHTestQuestions.Souvenir = {
    ["ID"] = "Souvenir",
    ["QuestionText"] = "You've been handed a large bag as a souvenir. What do you do?",
    ["AnswerText"] = {"Open it!", "Have a quick look and wait until I get home to open it", "Say thanks"},
    ["Points"] = {
        {
            ["Rash"] = 2
        },
        {
            ["Docile"] = 2
        },
        {
            ["Relaxed"] = 2
        }
    }
}