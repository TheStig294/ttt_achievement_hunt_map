if not ((game.GetMap() == "ttt_achievement_hunt" or game.GetMap() == "ttt_achievement_hunt_final") and engine.ActiveGamemode() == "terrortown") then return end
-- Defines the achievements to earn on the ttt_achievement_hunt map
AHAchievements = {}

AHAchievements.welcomeback = {
    ["id"] = "welcomeback",
    ["name"] = "Welcome Back!",
    ["desc"] = "Press the button at the front entrance to the main building",
    ["big"] = false,
    ["delay"] = 8
}

AHAchievements.portal = {
    ["id"] = "portal",
    ["name"] = "For Science!",
    ["desc"] = "Walk through a portal",
    ["big"] = false,
    ["delay"] = 0
}

AHAchievements.lever = {
    ["id"] = "lever",
    ["name"] = "Pull the lever!",
    ["desc"] = "Turn on/off one of the drawbridges",
    ["big"] = false,
    ["delay"] = 0
}

AHAchievements.hams = {
    ["id"] = "hams",
    ["name"] = "Aurora Borealis",
    ["desc"] = "Find a smoking oven, eat steamed hams!",
    ["big"] = true,
    ["delay"] = 0
}

AHAchievements.hat = {
    ["id"] = "hat",
    ["name"] = "Spiffing!",
    ["desc"] = "Steal a top hat from a pig",
    ["big"] = false,
    ["delay"] = 0
}

AHAchievements.spa = {
    ["id"] = "spa",
    ["name"] = "Just Relax...",
    ["desc"] = "Find the hidden weapon in the \"traitor spa\"",
    ["big"] = false,
    ["delay"] = 0
}

AHAchievements.movie = {
    ["id"] = "movie",
    ["name"] = "> alongtimeago",
    ["desc"] = "Watch a movie in the theatre room",
    ["big"] = false,
    ["delay"] = 0
}

AHAchievements.airship = {
    ["id"] = "airship",
    ["name"] = "Take Off!",
    ["desc"] = "Start flying the \"S.S. Square Box\"",
    ["big"] = false,
    ["delay"] = 0
}

AHAchievements.minecart = {
    ["id"] = "minecart",
    ["name"] = "Weeeeeeee!",
    ["desc"] = "Hit someone with the minecart",
    ["big"] = true,
    ["delay"] = 0
}

AHAchievements.lemon = {
    ["id"] = "lemon",
    ["name"] = "Life's Manager",
    ["desc"] = "Press E on a lemon on the lemonade stand",
    ["big"] = false,
    ["delay"] = 0
}

AHAchievements.chests = {
    ["id"] = "chests",
    ["name"] = "Where's Mine?",
    ["desc"] = "Open a chest in the top and bottom floors of the chest house",
    ["big"] = false,
    ["delay"] = 0
}

AHAchievements.tom = {
    ["id"] = "tom",
    ["name"] = "Somehow...",
    ["desc"] = "Open \"The Senate's\" chest in the chest house",
    ["big"] = false,
    ["delay"] = 0
}

AHAchievements.randomat = {
    ["id"] = "randomat",
    ["name"] = "Baba is You",
    ["desc"] = "Make a randomat in the randomat factory!",
    ["big"] = false,
    ["delay"] = 0
}

AHAchievements.randomat3 = {
    ["id"] = "randomat3",
    ["name"] = "Random Rounds",
    ["desc"] = "Make 3 randomats over 3 rounds!",
    ["big"] = true,
    ["delay"] = 0
}

AHAchievements.gameshow = {
    ["id"] = "gameshow",
    ["name"] = "Come on down!",
    ["desc"] = "Win the quiz gameshow, or go through every quiz show question!",
    ["big"] = true,
    ["delay"] = 6
}

AHAchievements.gameshow2 = {
    ["id"] = "gameshow2",
    ["name"] = "Round 2!",
    ["desc"] = "Start the quiz gameshow on 2 different rounds",
    ["big"] = false,
    ["delay"] = 0
}

AHAchievements.tester = {
    ["id"] = "tester",
    ["name"] = "You seem to be...",
    ["desc"] = "Activate the personality tester in the far corner of the map",
    ["big"] = false,
    ["delay"] = 0
}

AHAchievements.tester2 = {
    ["id"] = "tester2",
    ["name"] = "Prop Hunt",
    ["desc"] = "Transform 2 people into props using the personality tester",
    ["big"] = true,
    ["delay"] = 0
}

AHAchievements.stillalive = {
    ["id"] = "stillalive",
    ["name"] = "Huge Success",
    ["desc"] = "Play a bit of a certain song on the note blocks in the main building",
    ["big"] = false,
    ["delay"] = 0
}

AHAchievements.sheep = {
    ["id"] = "sheep",
    ["name"] = "Beep Beep",
    ["desc"] = "Spawn too many sheep...",
    ["big"] = false,
    ["delay"] = 2
}

AHAchievements.disk = {
    ["id"] = "disk",
    ["name"] = "Royalty Free",
    ["desc"] = "Find and play the music disk hidden in the main building",
    ["big"] = false,
    ["delay"] = 0
}

AHAchievements.bow = {
    ["id"] = "bow",
    ["name"] = "Take Aim",
    ["desc"] = "Find the bow, and pick up an arrow after hitting the ground",
    ["big"] = true,
    ["delay"] = 0
}

AHAchievements.sword = {
    ["id"] = "sword",
    ["name"] = "Homerun!",
    ["desc"] = "Craft the diamond sword in the main building, and hit someone with it!",
    ["big"] = true,
    ["delay"] = 0
}

AHAchievements.amongus = {
    ["id"] = "amongus",
    ["name"] = "Sus",
    ["desc"] = "Find the hidden amogus, and bring it to the indicator",
    ["big"] = true,
    ["delay"] = 4
}

AHAchievements.doorbell = {
    ["id"] = "doorbell",
    ["name"] = "Ding Dong",
    ["desc"] = "Ring a doorbell in the main building's second floor",
    ["big"] = false,
    ["delay"] = 0
}

AHAchievements.ammo = {
    ["id"] = "ammo",
    ["name"] = "Dispenser Here!",
    ["desc"] = "Refill ammo at the 'ammo here' spot in the main building",
    ["big"] = false,
    ["delay"] = 0
}

AHAchievements.environment = {
    ["id"] = "environment",
    ["name"] = "Patience...",
    ["desc"] = "See nighttime or rain, by playing enough rounds or otherwise",
    ["big"] = true,
    ["delay"] = 0
}

AHAchievements.reward = {
    ["id"] = "reward",
    ["name"] = "Final Reward!",
    ["desc"] = "Complete all other achievements, and enter the giant squid...",
    ["big"] = true,
    ["delay"] = 0
}