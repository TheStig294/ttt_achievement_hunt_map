if not ((game.GetMap() == "ttt_achievement_hunt" or game.GetMap() == "ttt_achievement_hunt_final") and engine.ActiveGamemode() == "terrortown") then return end
-- Props and descriptions for the different personalities given during the end of the "Prop-sonality quiz" in the ttt_achievement_hunt map
AHTestPersonalities = {}

AHTestPersonalities.Fearless = {
    ["ID"] = "Fearless",
    ["Description"] = "The Fearless! - You let nothing stand in your way!\nA fearless type like you could be...",
    ["Prop"] = "models/props_c17/streetsign005d.mdl",
    ["PropName"] = "a danger sign!"
}

AHTestPersonalities.Courageous = {
    ["ID"] = "Courageous",
    ["Description"] = "The Courageous! - You put aside your fear even when the going gets tough!\nA courageous type like you could be...",
    ["Prop"] = "models/props_junk/harpoon002a.mdl",
    ["PropName"] = "a harpoon!"
}

AHTestPersonalities.Soothing = {
    ["ID"] = "Soothing",
    ["Description"] = "The Soothing! - You don't like conflict, and are very considerate of others!\nA soothing type like you could be...",
    ["Prop"] = "models/maxofs2d/gm_painting.mdl",
    ["PropName"] = "a painting!"
}

AHTestPersonalities.Gentle = {
    ["ID"] = "Gentle",
    ["Description"] = "The Gentle! - Calm and honest, you attentively listen to others,\nand try your best to help your friends.\nA gentle type like you could be...",
    ["Prop"] = "models/maxofs2d/companion_doll.mdl",
    ["PropName"] = "a doll!"
}

AHTestPersonalities.Determined = {
    ["ID"] = "Determined",
    ["Description"] = "The Determined! - You have a sense of responsibility and purpose,\nand steadily work towards your goals, despite everything that gets in the way!\nA determined type like you could be...",
    ["Prop"] = "models/props_c17/oildrum001.mdl",
    ["PropName"] = "a barrel!"
}

AHTestPersonalities.Headlong = {
    ["ID"] = "Headlong",
    ["Description"] = "The Headlong! - You don't like wasting time, and want to jump right into things!\nYou're a hard worker, and just want to get things done!\nA headlong type like you could be...",
    ["Prop"] = "models/xqm/jetbody3.mdl",
    ["PropName"] = "a jet!"
}

AHTestPersonalities.Mischievous = {
    ["ID"] = "Mischievous",
    ["Description"] = "The Mischievous! - You don't mind a little prank!\nYou like a bit of competition, and much better when you win!\nSo, a cheerful, mischievous type like you could be...",
    ["Prop"] = "models/props_c17/oildrum001_explosive.mdl",
    ["PropName"] = "an explosive barrel!"
}

AHTestPersonalities.Merry = {
    ["ID"] = "Merry",
    ["Description"] = "The Merry! - Always laughing and smiling, you uplift everyone around you!\nYou love joking around with your good sense of humour, and are very compassionate towards others.\nA merry type like you could be...",
    ["Prop"] = "models/balloons/balloon_star.mdl",
    ["PropName"] = "a balloon!"
}

AHTestPersonalities.Peaceful = {
    ["ID"] = "Peaceful",
    ["Description"] = "The Peaceful! - You appreciate a break from others, and time on your own to think.\nYou don't like making mistakes or having to confront others, and are methodical with your decisions!\nA peaceful type like you could be...",
    ["Prop"] = "models/props_lab/chess.mdl",
    ["PropName"] = "a chess board!"
}

AHTestPersonalities.Eccentric = {
    ["ID"] = "Eccentric",
    ["Description"] = "The Eccentric! - You always are up-to-date with all the latest things!\nYou're keep true to yourself, and don't mind change if it will do good!\nAn eccentric type like you could be...",
    ["Prop"] = "models/player/items/humans/top_hat.mdl",
    ["PropName"] = "a top hat!"
}

AHTestPersonalities.Quick = {
    ["ID"] = "Quick",
    ["Description"] = "The Quick! - You're fast and adaptive, and focused on what to do next!\nYou might make a mistake every now and then, but it's worth it to be on top of things!\nSo, without further ado, a quick type like you could be...",
    ["Prop"] = "models/nateswheel/nateswheel.mdl",
    ["PropName"] = "a wheel!"
}

AHTestPersonalities.Content = {
    ["ID"] = "Content",
    ["Description"] = "The Content! - Cool, calm and collected, you try to not rush things!\nYou know stress doesn't help, and don't sweat the details!\nYou keep calm, and carry on!\nA content type like you could be...",
    ["Prop"] = "models/props_interiors/Furniture_Couch02a.mdl",
    ["PropName"] = "a couch!"
}

-- The "Prop-sonality quiz" questions and each answer's points towards each personality type
AHTestQuestions = {}

AHTestQuestions.Thinking = {
    ["ID"] = "Thinking",
    ["QuestionText"] = "Are you good at thinking before you act?",
    ["AnswerText"] = {"Yes", "No"},
    ["Points"] = {
        {
            ["Determined"] = 1
        },
        {
            ["Content"] = 2
        }
    }
}

AHTestQuestions.Finish = {
    ["ID"] = "Finish",
    ["QuestionText"] = "Do you normally finish the things you work towards?",
    ["AnswerText"] = {"Yes", "No"},
    ["Points"] = {
        {
            ["Determined"] = 2
        },
        {
            ["Eccentric"] = 1
        }
    }
}

AHTestQuestions.Greet = {
    ["ID"] = "Greet",
    ["QuestionText"] = "Do you go up to greet people? (Or do they come to you?)",
    ["AnswerText"] = {"Yes", "No"},
    ["Points"] = {
        {
            ["Courageous"] = 2,
            ["Content"] = 1
        },
        {
            ["Peaceful"] = 1
        }
    }
}

AHTestQuestions.Cool = {
    ["ID"] = "Cool",
    ["QuestionText"] = "Do you think you are a \"cool\" person?",
    ["AnswerText"] = {"Certainly!", "Well, not really..."},
    ["Points"] = {
        {
            ["Merry"] = 1
        },
        {
            ["Soothing"] = 1
        }
    }
}

AHTestQuestions.Outside = {
    ["ID"] = "Outside",
    ["QuestionText"] = "Where do you prefer being?",
    ["AnswerText"] = {"Outside", "Inside"},
    ["Points"] = {
        {
            ["Fearless"] = 1,
            ["Merry"] = 2,
            ["Content"] = 1
        },
        {
            ["Soothing"] = 1
        }
    }
}

AHTestQuestions.Hogging = {
    ["ID"] = "Hogging",
    ["QuestionText"] = "Do you sometimes find yourself hogging a conversation?",
    ["AnswerText"] = {"Yes", "No"},
    ["Points"] = {
        {
            ["Quick"] = 2
        },
        {
            ["Gentle"] = 1,
            ["Peaceful"] = 1
        }
    }
}

AHTestQuestions.Switch = {
    ["ID"] = "Switch",
    ["QuestionText"] = "There's a random switch just sitting there... Do you flip it?",
    ["AnswerText"] = {"Yes", "No"},
    ["Points"] = {
        {
            ["Headlong"] = 2
        },
        {
            ["Soothing"] = 1
        }
    }
}

AHTestQuestions.Bought = {
    ["ID"] = "Bought",
    ["QuestionText"] = "Do you spend more time buying things you want, or things you need?",
    ["AnswerText"] = {"Want", "Need"},
    ["Points"] = {
        {
            ["Headlong"] = 1,
            ["Eccentric"] = 2,
            ["Quick"] = 1
        },
        {
            ["Peaceful"] = 1
        }
    }
}

AHTestQuestions.Joke = {
    ["ID"] = "Joke",
    ["QuestionText"] = "Do you normally think before you tell a joke?",
    ["AnswerText"] = {"Yes", "No"},
    ["Points"] = {
        {
            ["Soothing"] = 2
        },
        {
            ["Mischievous"] = 1
        }
    }
}

AHTestQuestions.Parties = {
    ["ID"] = "Parties",
    ["QuestionText"] = "How do you go with huge parties?",
    ["AnswerText"] = {"Love them!", "Not my favourite"},
    ["Points"] = {
        {
            ["Merry"] = 2
        },
        {
            ["Peaceful"] = 1
        }
    }
}

AHTestQuestions.Karaoke = {
    ["ID"] = "Karaoke",
    ["QuestionText"] = "Some of your friends are doing karaoke! Do you join in?",
    ["AnswerText"] = {"Yes", "No"},
    ["Points"] = {
        {
            ["Merry"] = 2
        },
        {
            ["Headlong"] = 1
        }
    }
}

AHTestQuestions.Prank = {
    ["ID"] = "Prank",
    ["QuestionText"] = "A friend has pranked you! How do you feel?",
    ["AnswerText"] = {"Dang it, you got me!", "Ugh..."},
    ["Points"] = {
        {
            ["Mischievous"] = 2,
            ["Merry"] = 1
        },
        {
            ["Quick"] = 1,
            ["Peaceful"] = 2
        }
    }
}

AHTestQuestions.Fall = {
    ["ID"] = "Fall",
    ["QuestionText"] = "Oh no, your friend takes a spectacular fall! What's you first reaction?",
    ["AnswerText"] = {"Help them up!", "Laugh! It's too funny!"},
    ["Points"] = {
        {
            ["Courageous"] = 2
        },
        {
            ["Mischievous"] = 2,
            ["Quick"] = 1
        }
    }
}

AHTestQuestions.Late = {
    ["ID"] = "Late",
    ["QuestionText"] = "A friend is running a fair bit late, do you mind?",
    ["AnswerText"] = {"Yes", "Not at all!"},
    ["Points"] = {
        {
            ["Headlong"] = 2
        },
        {
            ["Fearless"] = 1,
            ["Soothing"] = 2
        }
    }
}

AHTestQuestions.Life = {
    ["ID"] = "Life",
    ["QuestionText"] = "Do you find yourself saying to others, \"life goes on\"?",
    ["AnswerText"] = {"Sometimes", "Not really..."},
    ["Points"] = {
        {
            ["Merry"] = 1,
            ["Content"] = 2
        },
        {
            ["Peaceful"] = 1
        }
    }
}

AHTestQuestions.Blame = {
    ["ID"] = "Blame",
    ["QuestionText"] = "Would you ever blame something you did on someone else?",
    ["AnswerText"] = {"Maybe", "No way!"},
    ["Points"] = {
        {
            ["Mischievous"] = 2
        },
        {
            ["Courageous"] = 2
        }
    }
}

AHTestQuestions.Movie = {
    ["ID"] = "Movie",
    ["QuestionText"] = "It's time for halloween night with friends! What movie are you going to watch?",
    ["AnswerText"] = {"Something funny", "Something spooky", "Something different"},
    ["Points"] = {
        {
            ["Mischievous"] = 2
        },
        {
            ["Courageous"] = 2
        },
        {
            ["Eccentric"] = 2
        }
    }
}

AHTestQuestions.Exam = {
    ["ID"] = "Exam",
    ["QuestionText"] = "You have an exam tomorrow! What do you do?",
    ["AnswerText"] = {"Study all night long", "Get some sleep! I'm sure it will be fine!"},
    ["Points"] = {
        {
            ["Determined"] = 2
        },
        {
            ["Content"] = 2
        }
    }
}

AHTestQuestions.Dishes = {
    ["ID"] = "Dishes",
    ["QuestionText"] = "You're putting together some dishes for a party. Can you help yourself from having some?",
    ["AnswerText"] = {"Too focused on the cooking!", "Try some just to test...", "Set some aside just for myself!"},
    ["Points"] = {
        {
            ["Headlong"] = 2
        },
        {
            ["Determined"] = 2
        },
        {
            ["Quick"] = 2
        }
    }
}

AHTestQuestions.Expiration = {
    ["ID"] = "Expiration",
    ["QuestionText"] = "You just realised you ate something on its expiration date, but didn't notice anything off. What do you do?",
    ["AnswerText"] = {"Eh, still tastes fine!", "Oops! Better have something else...", "Get a second opinion"},
    ["Points"] = {
        {
            ["Courageous"] = 2,
            ["Content"] = 1
        },
        {
            ["Headlong"] = 2
        },
        {
            ["Fearless"] = 2
        }
    }
}

AHTestQuestions.Meal = {
    ["ID"] = "Meal",
    ["QuestionText"] = "A friend asks what you think of a meal they made, but you didn't like it. What do you say?",
    ["AnswerText"] = {"Suggest how to improve", "Not my favourite", "Pretty good!"},
    ["Points"] = {
        {
            ["Quick"] = 2
        },
        {
            ["Courageous"] = 1,
            ["Peaceful"] = 1
        },
        {
            ["Soothing"] = 2,
            ["Content"] = 1
        }
    }
}

AHTestQuestions.Restaurant = {
    ["ID"] = "Restaurant",
    ["QuestionText"] = "Time to order at a restaurant! What do you pick?",
    ["AnswerText"] = {"Something you love", "Something healthy", "Something you haven't tried"},
    ["Points"] = {
        {
            ["Mischievous"] = 2
        },
        {
            ["Determined"] = 2
        },
        {
            ["Fearless"] = 2
        }
    }
}

AHTestQuestions.Shared = {
    ["ID"] = "Shared",
    ["QuestionText"] = "You realise the last piece of a shared dish is on the table. What do you do?",
    ["AnswerText"] = {"Leave it for someone else", "Let everyone know", "Take it before someone else!"},
    ["Points"] = {
        {
            ["Content"] = 2
        },
        {
            ["Gentle"] = 2,
            ["Quick"] = 2
        },
        {
            ["Mischievous"] = 2
        }
    }
}

AHTestQuestions.Out = {
    ["ID"] = "Out",
    ["QuestionText"] = "Your friends are organising a night out! How do you respond?",
    ["AnswerText"] = {"Whatever you're doing I'll be there!", "Suggest places", "I'm too busy..."},
    ["Points"] = {
        {
            ["Fearless"] = 2
        },
        {
            ["Merry"] = 2
        },
        {
            ["Eccentric"] = 2
        }
    }
}

AHTestQuestions.Laughing = {
    ["ID"] = "Laughing",
    ["QuestionText"] = "Everyone's laughing, but you don't know why. What do you do?",
    ["AnswerText"] = {"Nothing", "Laugh along anyway!", "Depends what was said"},
    ["Points"] = {
        {
            ["Courageous"] = 2,
            ["Fearless"] = 1
        },
        {
            ["Gentle"] = 1
        },
        {
            ["Peaceful"] = 1,
            ["Eccentric"] = 1
        }
    }
}

AHTestQuestions.Busy = {
    ["ID"] = "Busy",
    ["QuestionText"] = "Do you like to keep busy? Or prefer to relax?",
    ["AnswerText"] = {"Keep busy", "Relax!", "In between"},
    ["Points"] = {
        {
            ["Determined"] = 1,
            ["Headlong"] = 1
        },
        {
            ["Soothing"] = 2
        },
        {
            ["Eccentric"] = 2
        }
    }
}

AHTestQuestions.Last = {
    ["ID"] = "Last",
    ["QuestionText"] = "You're about to grab the last of something, then someone else takes it! How do you feel?",
    ["AnswerText"] = {"Oh well", "Awww come on!"},
    ["Points"] = {
        {
            ["Soothing"] = 2,
            ["Content"] = 2
        },
        {
            ["Mischievous"] = 2,
        }
    }
}

AHTestQuestions.Know = {
    ["ID"] = "Know",
    ["QuestionText"] = "You're forced to be with someone you don't know for a long while, what do you do?",
    ["AnswerText"] = {"Try and talk to them", "Keep to yourself", "Get away!"},
    ["Points"] = {
        {
            ["Soothing"] = 2
        },
        {
            ["Eccentric"] = 2
        },
        {
            ["Peaceful"] = 2
        }
    }
}

AHTestQuestions.Backwards = {
    ["ID"] = "Backwards",
    ["QuestionText"] = "You've been wearing something backwards the whole day! How do you react?",
    ["AnswerText"] = {"Whoops...", "Yeah I do that sometimes", "Actually that was on purpose!"},
    ["Points"] = {
        {
            ["Gentle"] = 2
        },
        {
            ["Quick"] = 2
        },
        {
            ["Merry"] = 2
        }
    }
}

AHTestQuestions.News = {
    ["ID"] = "News",
    ["QuestionText"] = "What do you want to hear first?",
    ["AnswerText"] = {"The good news", "The bad news", "Both at once!"},
    ["Points"] = {
        {
            ["Merry"] = 2
        },
        {
            ["Fearless"] = 1
        },
        {
            ["Eccentric"] = 2
        }
    }
}

AHTestQuestions.Resolutions = {
    ["ID"] = "Resolutions",
    ["QuestionText"] = "How do you go with new year's resolutions?",
    ["AnswerText"] = {"I've kept some!", "I don't bother", "I try to keep mine, but haven't"},
    ["Points"] = {
        {
            ["Determined"] = 2
        },
        {
            ["Eccentric"] = 2,
            ["Quick"] = 1
        },
        {
            ["Courageous"] = 2
        }
    }
}

AHTestQuestions.Sprinting = {
    ["ID"] = "Sprinting",
    ["QuestionText"] = "You fell over right at the start of a sprinting race. How do you react?",
    ["AnswerText"] = {"Get up and keep running!", "Well that's that..."},
    ["Points"] = {
        {
            ["Courageous"] = 1,
            ["Determined"] = 2
        },
        {
            ["Quick"] = 2
        }
    }
}

AHTestQuestions.Work = {
    ["ID"] = "Work",
    ["QuestionText"] = "Your boss just gave your group a ton of work to do. What do you do?",
    ["AnswerText"] = {"Head down, get straight to it!", "Ask for help", "Someone else can do it, I don't have time!"},
    ["Points"] = {
        {
            ["Courageous"] = 1,
            ["Determined"] = 2
        },
        {
            ["Gentle"] = 1
        },
        {
            ["Quick"] = 2
        }
    }
}

AHTestQuestions.Sale = {
    ["ID"] = "Sale",
    ["QuestionText"] = "Something you just bought is now on sale! What do you do?",
    ["AnswerText"] = {"Get a refund!", "Aaaargh!", "Oh well"},
    ["Points"] = {
        {
            ["Determined"] = 2
        },
        {
            ["Gentle"] = 2
        },
        {
            ["Fearless"] = 2,
            ["Soothing"] = 2
        }
    }
}

AHTestQuestions.Phone = {
    ["ID"] = "Phone",
    ["QuestionText"] = "Your phone is ringing, what do you do?",
    ["AnswerText"] = {"Drop everything and answer!", "Quickly finish what your doing", "Wait... Someone's calling me?"},
    ["Points"] = {
        {
            ["Headlong"] = 2
        },
        {
            ["Determined"] = 1
        },
        {
            ["Peaceful"] = 2
        }
    }
}

AHTestQuestions.Win = {
    ["ID"] = "Win",
    ["QuestionText"] = "You've won the lottery! How do you react?",
    ["AnswerText"] = {"Woo-hoo!", "Best not tell too many others...", "I don't buy lottery tickets"},
    ["Points"] = {
        {
            ["Headlong"] = 1,
            ["Merry"] = 1
        },
        {
            ["Peaceful"] = 2
        },
        {
            ["Determined"] = 1
        }
    }
}

AHTestQuestions.TV = {
    ["ID"] = "TV",
    ["QuestionText"] = "A news reporter randomly chooses you for a question. How do you respond?",
    ["AnswerText"] = {"Answer!", "I'm on TV! Whoo!", "Keep walking and get away!"},
    ["Points"] = {
        {
            ["Courageous"] = 2
        },
        {
            ["Fearless"] = 2
        },
        {
            ["Peaceful"] = 1
        }
    }
}

AHTestQuestions.Mornings = {
    ["ID"] = "Mornings",
    ["QuestionText"] = "When do you wake up?",
    ["AnswerText"] = {"Early", "Late", "Nothing consistent!"},
    ["Points"] = {
        {
            ["Quick"] = 2
        },
        {
            ["Peaceful"] = 1
        },
        {
            ["Gentle"] = 2,
            ["Mischievous"] = 1
        }
    }
}

AHTestQuestions.Party = {
    ["ID"] = "Party",
    ["QuestionText"] = "You've arrived at a party, but no-one is there. How do you react?",
    ["AnswerText"] = {"Did I make a mistake?", "Ah it's fine, I'm just early!", "Let's get this party started!"},
    ["Points"] = {
        {
            ["Gentle"] = 2
        },
        {
            ["Merry"] = 2,
            ["Content"] = 2
        },
        {
            ["Fearless"] = 2
        }
    }
}

AHTestQuestions.Studying = {
    ["ID"] = "Studying",
    ["QuestionText"] = "What's your studying style?",
    ["AnswerText"] = {"A bit at a time, every day", "If I remember...", "Just cover what I need to"},
    ["Points"] = {
        {
            ["Determined"] = 2
        },
        {
            ["Eccentric"] = 2,
            ["Headlong"] = 1
        },
        {
            ["Peaceful"] = 1
        }
    }
}

AHTestQuestions.Souvenir = {
    ["ID"] = "Souvenir",
    ["QuestionText"] = "You've been given a bag of goodies on leaving a party. What do you do?",
    ["AnswerText"] = {"Open it straight away", "Have a quick look and wait until I get home to open it", "Say thanks of course!"},
    ["Points"] = {
        {
            ["Quick"] = 2
        },
        {
            ["Gentle"] = 2
        },
        {
            ["Content"] = 2
        }
    }
}

AHTestQuestions.Yogscast = {
    ["ID"] = "Yogscast",
    ["QuestionText"] = "Who's your favourite member of the Yogscast?",
    ["AnswerText"] = {"Lewis", "Simon", "Someone else", "Don't know"},
    ["Points"] = {
        {
            ["Eccentric"] = 2
        },
        {
            ["Merry"] = 2
        },
        {
            ["Content"] = 2
        },
        {
            ["Gentle"] = 2
        }
    }
}