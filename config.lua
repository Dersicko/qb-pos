Config = {}

Config.POSJobs = {
    ["uwu"] = {
        Locations = {
            ["main"] = {
                label = "Uwu Cafe",
                coords = {x = -585.1, y = -1060.32, z = 22.34, h = 272.0},
                blip = 489,
                color = 8,
            },
        },
        MaxEmployees = 5,
        ActiveOrders = {

        },
        Perimeter = {
            {
                zone = {
                    vector2(-563.39404296875, -1087.8220214844),
                    vector2(-563.61328125, -1044.9580078125),
                    vector2(-615.24127197266, -1041.2225341797),
                    vector2(-611.08673095703, -1087.4351806641)
                },
                minZ = 20.0,
                maxZ = 28.0
            }
        },
        TimeClocks = {
            {
                coords = vector3(-596.62, -1049.39, 22.34),
                heading = 180.0,
                width = 0.6,
                height = 2.5,
                icon = "fas fa-user-check",
                label = "Clock Meowt/In",
            }
        },
        Registers = {
            {
                coords = vector3(-584.05, -1061.15, 22.4),
                radius = 0.5,
            },
            {
                coords = vector3(-583.79, -1058.56, 22.55),
                radius = 0.5,
            }
        },
        Stash = {
            {
                coords = vector3(-587.41, -1059.58, 22.6),
                radius = 1.0
            }
        },
        Trays = {
            {
                coords = vector3(-583.98, -1062.37, 22.78),
                icon = "fas fa-heart",
                radius = 0.5,
            },
            {
                coords = vector3(-584.04, -1059.46, 22.48),
                icon = "fas fa-heart",
                radius = 0.5,
            }
        },
        Fridge = {
            {
                coords = vector3(-588.5, -1066.59, 22.34),
                icon = "fas fa-temperature-low",
                heading = 93.65,
                width = 1.0,
                height = 4.5
            }
        },
        Sinks = {
            {
                coords = vector3(-587.99, -1062.49, 22.55),
                radius = 0.5,
            }
        },
        BossArea = {
            {
                
            }
        },
        WorkAreas = {
            ["grill"] = {
                coords = vector3(-590.48, -1056.52, 22.36),
                heading = 261.0,
                width = 0.7,
                height = 1.2,
                icon = "fas fa-fire",
                label = "Use Stovetop",
                progressText = "Cooking",
                progressTime = 4000,
                animDict = "amb@prop_human_bbq@male@base",
                anim = "base",
            },
            ["choppingboard"] = {
                coords = vector3(-591.0, -1063.12, 22.26),
                heading = 273.88,
                width = 0.6,
                height = 1.5,
                icon = "fas fa-utensils",
                label = "Chop Food",
                progressText = "Chopping",
                progressTime = 4000,
                animDict = "anim@heists@prison_heiststation@cop_reactions",
                anim = "cop_b_idle",
            },
            ["drinks"] = {
                coords = vector3(-586.79, -1061.99, 22.35),
                heading = 268.65,
                width = 0.6,
                height = 1.7,
                icon = "fas fa-mug-hot",
                label = "Pour Drink",
                progressText = "Pouring",
                progressTime = 4000,
                animDict = "mp_arresting",
                anim = "a_uncuff",
            },
            ["oven"] = {
                coords = vector3(-590.38, -1059.9, 22.34),
                heading = 274.0,
                width = 0.7,
                height = 2.5,
                icon = "fas fa-mug-hot",
                label = "Use Oven",
                progressText = "Baking",
                progressTime = 4000,
                animDict = "amb@world_human_stand_fire@male@idle_a",
                anim = "idle_a",
            }
        },
        Items = {
            ['chickenwrap'] = {
                ingredients = {
                    { hash = 'chickenpatty', quantity = 1 },
                    { hash = 'tortillas', quantity = 1 },
                },
                food = true,
                quantity = 1,
                workarea = "grill",
            },
            ['frenchtoast'] = {
                ingredients = {
                    { hash = 'eggs', quantity = 1 },
                    { hash = 'bread', quantity = 1 },
                },
                food = true,
                quantity = 1,
                workarea = "grill",
            },
            ['cupcake'] = {
                ingredients = {
                    { hash = 'cupcakemix', quantity = 1 },
                },
                food = true,
                quantity = 6,
                workarea = "oven",
            },
            ['macarons'] = {
                ingredients = {
                    { hash = 'almondflour', quantity = 1 },
                },
                food = true,
                quantity = 6,
                workarea = "oven",
            },
            ['mochichocolate'] = {
                ingredients = {
                    { hash = 'mochiflour', quantity = 1 },
                    { hash = 'rawchocolatebar', quantity = 1 },
                },
                food = true,
                quantity = 6,
                workarea = "choppingboard",
            },
            ['mochimint'] = {
                ingredients = {
                    { hash = 'mochiflour', quantity = 1 },
                    { hash = 'mintleaf', quantity = 1 },
                },
                food = true,
                quantity = 6,
                workarea = "choppingboard",
            },
            ['mochiraspberry'] = {
                ingredients = {
                    { hash = 'mochiflour', quantity = 1 },
                    { hash = 'raspberries', quantity = 1 },
                },
                food = true,
                quantity = 6,
                workarea = "choppingboard",
            },
            ['mochitangerine'] = {
                ingredients = {
                    { hash = 'mochiflour', quantity = 1 },
                    { hash = 'tangerines', quantity = 1 },
                },
                food = true,
                quantity = 6,
                workarea = "choppingboard",
            },
            ['mochivanilla'] = {
                ingredients = {
                    { hash = 'mochiflour', quantity = 1 },
                    { hash = 'vanillaextract', quantity = 1 },
                },
                food = true,
                quantity = 6,
                workarea = "choppingboard",
            },
            ['mochiwatermelon'] = {
                ingredients = {
                    { hash = 'mochiflour', quantity = 1 },
                    { hash = 'watermelon', quantity = 1 },
                },
                food = true,
                quantity = 6,
                workarea = "choppingboard",
            },
            ['ramen'] = {
                ingredients = {
                    { hash = 'ramennoodles', quantity = 1 },
                    { hash = 'ramenbroth', quantity = 1 },
                },
                food = true,
                quantity = 1,
                workarea = "grill",
            },
            ['bobaraz'] = {
                ingredients = {
                    { hash = 'tapioca', quantity = 1 },
                    { hash = 'raspberries', quantity = 1 },
                },
                drink = true,
                quantity = 1,
                workarea = "drinks",
            },
            ['bobachocolate'] = {
                ingredients = {
                    { hash = 'tapioca', quantity = 1 },
                    { hash = 'rawchocolatebar', quantity = 1 },
                },
                drink = true,
                quantity = 1,
                workarea = "drinks",
            },
            ['bobamint'] = {
                ingredients = {
                    { hash = 'tapioca', quantity = 1 },
                    { hash = 'mintleaf', quantity = 1 },
                },
                drink = true,
                quantity = 1,
                workarea = "drinks",
            },
            ['bobastrawberry'] = {
                ingredients = {
                    { hash = 'tapioca', quantity = 1 },
                    { hash = 'strawberries', quantity = 1 },
                },
                drink = true,
                quantity = 1,
                workarea = "drinks",
            },
            ['bobavanilla'] = {
                ingredients = {
                    { hash = 'tapioca', quantity = 1 },
                    { hash = 'vanillaextract', quantity = 1 },
                },
                drink = true,
                quantity = 1,
                workarea = "drinks",
            },
            ['bobawatermelon'] = {
                ingredients = {
                    { hash = 'tapioca', quantity = 1 },
                    { hash = 'watermelon', quantity = 1 },
                },
                drink = true,
                quantity = 1,
                workarea = "drinks",
            },
            ['chaitea'] = {
                ingredients = {
                    { hash = 'rawtea', quantity = 1 }
                },
                drink = true,
                quantity = 1,
                workarea = "drinks",
            },
            ['waterbottle'] = {
                drink = true,
                quantity = 1,
                workarea = "drinks",
            },
        },
        Animals = {
            hash = 'a_c_cat_01',
            icon = 'fas fa-cat',
            label = 'That face ^m^',
            animDict = 'creatures@cat@amb@world_cat_sleeping_ground@idle_a',
            anim = 'idle_a',
            models = {
                [1] = { hash = 'a_c_cat_01', coords = vector4(-574.16, -1053.91, 22.34, 146.09), sitting = true },
                [2] = { hash = 'a_c_cat_01', coords = vector4(-576.37, -1054.71, 22.43, 143.33), sitting = true },
                [3] = { hash = 'a_c_cat_01', coords = vector4(-584.91, -1052.77, 22.35, 232.57), sitting = true },
                [4] = { hash = 'a_c_cat_01', coords = vector4(-582.36, -1054.65, 22.43, 255.45), sitting = false },
                [5] = { hash = 'a_c_cat_01', coords = vector4(-582.18, -1056.0, 22.43, 306.29), sitting = true },
                [6] = { hash = 'a_c_cat_01', coords = vector4(-575.52, -1063.21, 22.34, 44.51), sitting = true },
                [7] = { hash = 'a_c_cat_01', coords = vector4(-581.82, -1066.43, 22.34, 287.58), sitting = true },
                [8] = { hash = 'a_c_cat_01', coords = vector4(-583.49, -1069.39, 22.99, 293.01) , sitting = false },
                [9] = { hash = 'a_c_cat_01', coords = vector4(-584.27, -1065.85, 22.34, 181.7), sitting = true },  
                [10] = { hash = 'a_c_cat_01', coords = vector4(-581.1, -1063.61, 22.79, 219.69), sitting = false },
                [11] = { hash = 'a_c_cat_01', coords = vector4(-572.98, -1057.41, 24.5, 88.18), sitting = true }
            },
        },
        AnimalSayings = {
            [1] = "*Meow Meow*",
            [2] = "I want to squeeze your face so hard!",
            [3] = "Warm kitty, soft kitty, little ball of fur.",
            [4] = "Here kitty kitty!",
            [5] = "Omg, it's purring!",
            [6] = "Mr. Whiskers, you're looking fine today.",
        },
        Receipt = {
            receipt = 'uwu-ticket',
            commission = 0.1,
        }
    },
    ["cluckinbell"] = {
        Locations = {
            ["main"] = {
                label = "Cluckin' Bell",
                coords = {x = -517.92, y = -694.76, z = 33.17, h = 179.86},
                blip = 89,
                color = 5,
            },
        },
        MaxEmployees = 5,
        ActiveOrders = {

        },
        Perimeter = {
            {
                zone = {
                    vector2(-497.48715209961, -669.75274658203),
                    vector2(-535.56378173828, -670.10955810547),
                    vector2(-532.435546875, -718.93023681641),
                    vector2(-498.37344360352, -711.32434082031)
                },
                minZ = 31.0,
                maxZ = 35.0
            }
        },
        TimeClocks = {
            {
                coords = vector3(-510.22, -702.89, 33.37),
                heading = 180.44,
                width = 0.6,
                height = 2.5,
                icon = "fas fa-user-check",
                label = "Cluck In/Out",
            }
        },
        Registers = {
            {
                coords = vector3(-520.21, -697.48, 33.37),
                radius = 0.5,
            },
            {
                coords = vector3(-518.6, -697.5, 33.37),
                radius = 0.5,
            },
            {
                coords = vector3(-516.95, -697.57, 33.37),
                radius = 0.5,
            },
            {
                coords = vector3(-515.31, -697.48, 33.37),
                radius = 0.5,
            }
        },
        Stash = {
            {
                coords = vector3(-518.72, -700.26, 33.12),
                radius = 1.25
            }
        },
        Trays = {
            {
                coords = vector3(-516.12, -697.49, 33.37),
                icon = "fas fa-drumstick-bite",
                radius = 0.5,
            },
            {
                coords = vector3(-517.76, -697.49, 33.37),
                icon = "fas fa-drumstick-bite",
                radius = 0.5,
            },
            {
                coords = vector3(-519.53, -697.64, 33.37),
                icon = "fas fa-drumstick-bite",
                radius = 0.5,
            },
        },
        Fridge = {
            {
                coords = vector3(-514.1, -702.88, 33.37),
                icon = "fas fa-temperature-low",
                heading = 183.78,
                width = 1.2,
                height = 1.0
            }
        },
        Sinks = {
            {
                coords = vector3(-512.47, -702.94, 33.37),
                radius = 0.5,
            },
        },
        WorkAreas = {
            ["grill"] = {
                coords = vector3(-516.38, -700.20, 33.37),
                heading = 358.46,
                width = 1.1,
                height = 1.5,
                icon = "fas fa-fire",
                label = "Grill",
                progressText = "Grilling",
                progressTime = 4000,
                animDict = "amb@prop_human_bbq@male@base",
                anim = "base",
            },
            ["choppingboard"] = {
                coords = vector3(-519.98, -702.84, 33.37),
                heading = 174.84,
                width = 1.2,
                height = 1.5,
                icon = "fas fa-utensils",
                label = "Chop Food",
                progressText = "Chopping",
                progressTime = 4000,
                animDict = "anim@heists@prison_heiststation@cop_reactions",
                anim = "cop_b_idle",
            },
            ["fryer"] = {
                coords = vector3(-521.45, -701.37, 33.37),
                heading = 91.12,
                width = 1.5,
                height = 1.5,
                icon = "fas fa-utensils",
                label = "Use Fryer",
                progressText = "Frying",
                progressTime = 4000,
                animDict = "mp_arresting",
                anim = "a_uncuff",
            },
            ["countertop"] = {
                coords = vector3(-517.21, -702.93, 33.04),
                heading = 181.13,
                width = 1.5,
                height = 3.5,
                icon = "fas fa-mortar-pestle",
                label = "Use Countertop",
                progressText = "Preparing",
                progressTime = 4000,
                animDict = "mini@repair",
                anim = "fixing_a_ped",
            },
            ["drinks"] = {
                coords = vector3(-514.46, -699.13, 33.37),
                heading = 269.0,
                width = 0.6,
                height = 1.7,
                icon = "fas fa-mug-hot",
                label = "Pour Drink",
                progressText = "Pouring",
                progressTime = 4000,
                animDict = "mp_arresting",
                anim = "a_uncuff",
            }
        },
        Items = {
            ["cluckmighty"] = {
                ingredients = {
                    { hash = "burgerbun", quantity = 1, },
                    { hash = "slicedpickle", quantity = 1, },
                    { hash = "cheddar", quantity = 1, },
                    { hash = "lettuce", quantity = 1, },
                    { hash = "chickenmeat", quantity = 1, },
                },
                food = true,
                workarea = "countertop",
                quantity = 1,
            },
            ["clucklittle"] = {
                ingredients = {
                    { hash = 'burgerbun', quantity = 1, },
                    { hash = 'cheddar', quantity = 1, },
                    { hash = 'lettuce', quantity = 1, },
                    { hash = 'slicedpickle', quantity = 1, },
                    { hash = 'chickenmeat', quantity = 1, },
                },
                food = true,
                workarea = "countertop",
                quantity = 1,
            },
            ["clucksalad"] = {
                ingredients = {
                    { hash = 'cheddar', quantity = 1, },
                    { hash = 'slicedonion', quantity = 1, },
                    { hash = 'lettuce', quantity = 1, },
                },
                food = true,
                workarea = "countertop",
                quantity = 1,
            },
            ["clucksoup"] = {
                ingredients = {
                    { hash = 'chickenmeat', quantity = 1, },
                    { hash = 'cluckecola', quantity = 1, },
                    { hash = 'cluckfarmer', quantity = 1, },
                },
                food = true,
                workarea = "countertop",
                quantity = 1,
            },
            ['slicedpotato'] = {
                ingredients = {
                    { hash = 'potato', quantity = 1 },
                },
                workarea = "choppingboard",
                quantity = 3,
            },
            ['slicedpickle'] = {
                ingredients = {
                    { hash = 'pickle', quantity = 1 },
                },
                workarea = "choppingboard",
                quantity = 3,
            },
            ['slicedonion'] = {
                ingredients = {
                    {hash = 'onion', quantity = 1 },
                },
                workarea = "choppingboard",
                quantity = 3,
            },
            ['chickenmeat'] = {
                ingredients = {
                    { hash = 'chickenpatty', quantity = 1 },
                },
                workarea = "grill",
                quantity = 6,
            },
            ['cluckfries'] = {
                ingredients = {
                    { hash = 'slicedpotato', quantity = 1 },
                },
                food = true,
                workarea = "fryer",
                quantity = 1,
            },
            ['cluckveggie'] = {
                ingredients = {
                    { hash = 'frozenveggie', quantity = 1 },
                },
                food = true,
                workarea = "fryer",
                quantity = 3,
            },
            ['cluckrings'] = {
                ingredients = {
                    { hash = 'frozendough', quantity = 1 },
                },
                food = true,
                workarea = "fryer",
                quantity = 12,
            },
            ['cluckballs'] = {
                ingredients = {
                    { hash = 'frozendough', quantity = 1 },
                },
                food = true,
                workarea = "fryer",
                quantity = 6,
            },
            ['cluckbites'] = {
                ingredients = {
                    { hash = 'frozennugget', quantity = 1 },
                },
                food = true,
                workarea = "fryer",
                quantity = 6,
            },
            ['cluckfarmer'] = {
                ingredients = {
                    { hash = 'cluckfoot', quantity = 1 },
                },
                food = true,
                workarea = "grill",
                quantity = 1,
            },
            ['cluckwings'] = {
                ingredients = {
                    { hash = 'rawwings', quantity = 1 },
                },
                food = true,
                workarea = "fryer",
                quantity = 3,
            },
            ['burgerbun'] = {
                ingredients = {
                    { hash = 'frozendough', quantity = 1 },
                },
                workarea = "grill",
                quantity = 12,
            },
            ['cluckecola'] = {
                workarea = 'drinks',
                quantity = 1,
                drink = true,
            },
            ['clucksprunk'] = {
                workarea = 'drinks',
                quantity = 1,
                drink = true,
            },
            ['clucktang'] = {
                workarea = 'drinks',
                quantity = 1,
                drink = true,
            },
        },
        Animals = {
            hash = 'a_c_hen',
            icon = 'fas fa-drumstick-bite',
            label = 'Farm to table!',
            animDict = 'creatures@hen@amb@world_hen_pecking@idle_a',
            anim = 'idle_c',
            models = {
                [1] = { coords = vector4(-510.95, -694.24, 33.17, 10.79), sitting = true},
                [2] = { coords = vector4(-523.72, -689.75, 33.17, 275.57), sitting = true},
                [3] = { coords = vector4(-519.63, -689.48, 33.17, 296.03), sitting = true},
                [4] = { coords = vector4(-517.29, -688.03, 34.18, 115.51), sitting = true},
                [5] = { coords = vector4(-519.8, -684.88, 33.17, 91.35), sitting = false},
                [6] = { coords = vector4(-522.43, -685.66, 33.17, 170.19), sitting = true},
                [7] = { coords = vector4(-524.13, -696.53, 33.17, 51.84), sitting = true},
                [8] = { coords = vector4(-525.43, -696.23, 33.17, 287.64), sitting = true},
                [9] = { coords = vector4(-524.96, -695.25, 33.17, 198.84), sitting = false},
                [10] = { coords = vector4(-516.48, -692.66, 33.17, 209.97), sitting = true},  
                [11] = { coords = vector4(-515.2, -692.34, 34.37, 270.52), sitting = false},
            },
        },
        AnimalSayings = {
            [1] = 'Co-ka. Co-ka Caww.',
            [2] = 'Cha-chi Cha-chi Cha-chi',
            [3] = 'A coodle doodle doo',
            [4] = 'Coo-coo ka-cha',
            [5] = 'Chick chick chi-caww',
            [6] = 'Bawk bawk bawk',
        },
        Receipt = {
            receipt = 'cluckinbell-ticket',
            commission = 0.1,
        }
    },
    -- ["yellowjack"] = {
    --     Locations = {
    --         ['main'] = {
    --             label = "Yellowjack",
    --             coords = vector3(1983.14, 3054.45, 47.22),
    --             blip = 93,
    --             color = 33,
    --         }
    --     },
    --     ActiveOrders = {},
    --     TimeClocks = {
    --         {
    --             coords = vector3(1986.02, 3047.64, 47.6),
    --             heading = 237.1,
    --             width = 0.6,
    --             height = 2.5,
    --             icon = "fas fa-user-check",
    --             label = "Jack In/Off",
    --         }
    --     },
    --     Registers = {
    --         { coords = vector3(1984.0, 3052.47, 47.27), radius = 0.75 }
    --     },
    --     Trays = {
    --         {
    --             coords = vector3(1984.62, 3053.73, 47.2),
    --             icon = "fas fa-whiskey-glass",
    --             radius = 0.75,
    --         },
    --     },
    --     BossArea = {
    --         {

    --         }
    --     },
    --     Stash = {
    --         { coords = vector3(1984.98, 3048.2, 47.38), radius = 1.5 }
    --     },
    --     WorkAreas = {
    --         ['drinks'] = {

    --         },
    --         ['grill'] = {
    --             coords = vector3(1984.32, 3050.28, 47.22),
    --         }
    --     },
    --     Items = {
    --         ['sliders'] = {
    --             ingredients = {
    --                 { hash = 'burgerbun', quantity = 1 },
    --                 { hash = 'cookedburger', quantity = 1 }
    --             },
    --             quantity = 4,
    --             workarea = 'grill',
    --         },
    --         ['barnuts'] = {
    --             ingredients = {
    --                 { hash = 'mixednuts', quantity = 1 }
    --             },
    --             quantity = 4,
    --             workarea = 'countertop',
    --         },
    --         ['patriotbeer'] = {
    --             ingredients = {
    --                 { hash = 'hops', quantity = 1 },
    --                 { hash = 'malt', quantity = 1 }
    --             },
    --             quantity = 4,
    --             workarea = 'drinks'
    --         },
    --         ['pisswasser'] = {
    --             ingredients = {
    --                 { hash = 'waterbottle', quantity = 1 },
    --                 { hash = 'patriotbeer', quantity = 1 }
    --             },
    --             quantity = 4,
    --             workarea = 'drinks'
    --         }
    --     },
    --     Receipt = {
    --         receipt = 'yellowjack-ticket',
    --         commission = 0.1
    --     },
    -- },
    ["unicorn"] = {
        ActiveOrders = {},
        Receipt = 'unicorn-ticket',
    },
    ["galaxy"] = {
        ActiveOrders = {},
        Receipt = 'galaxy-ticket',
    },
    ["hayes"] = {
        ActiveOrders = {},
        Receipt = {
            receipt = 'hayes-ticket',
            commission = 0.1,
        }
    },
}