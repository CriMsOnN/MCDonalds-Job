Config = {}

Config.DrawDistance = 0.5
Config.EnablePlayerManagement = true
Config.EnablesocietyOwnedVehicles = false
Config.EnableVaultManagement = true
Config.MaxInService = -1
Config.AuthorizedVehicles = {
    { name = 'burrito3', label = 'Burrito'}
}

Config.Blips = {
    Blip = {
        Pos = {x = 191.21, y = -909.14, z = 31.8 },
        title = "MCDonalds",
        Sprite = 268,
        Scale = 1.4,
        Colour = 25,
    },
}

Config.Zones = {
    Cloakrooms = {
        Pos = {x=182.87, y=-898.87, z=31.82},
        Size = { x = 1.3, y = 1.3, z = 1.0},
        Color = { r = 30, g = 144, b = 255},
        Type = 23,
    },

    Fridge = {
        Pos = {x = 180.37, y = -904.57, z = 31.81},
        Size = { x = 1.6, y = 1.6, z = 1.0 },
        Color = { r = 248, g = 248, b = 255},
        Type = 23,
    },

    Vaults = {
        Pos = {x = 183.98, y = -897.35, z = 31.82},
        Size = { x = 1.3, y = 1.3, z = 1.0},
        Color = { r = 30, g = 144, b = 255},
        Type = 23,
    },

    Boss = {
        Pos = { x = 189.46, y = -905.86, z = 31.8}
    },

    Drinks = {
        Pos = { x = 190.99, y = -903.45, z = 31.8},
        Items = {
            { name = 'water', label = 'Water', price = 10}
        }
    },

    Foods = {
        Pos = { x = 187.76, y = -904.23, z = 31.8},
        Items = {
            { name = 'bread', label = 'Bread', price = 10}
        }
    }
}

Config.Uniforms = {
    work_clothes = {
        male = {
            ['tshirt_1'] = 15,  ['tshirt_2'] = 0,
            ['torso_1'] = 40,   ['torso_2'] = 0,
            ['decals_1'] = 0,   ['decals_2'] = 0,
            ['arms'] = 40,
            ['pants_1'] = 28,   ['pants_2'] = 2,
            ['shoes_1'] = 38,   ['shoes_2'] = 4,
            ['chain_1'] = 118,  ['chain_2'] = 0
        },
        female = {
            ['tshirt_1'] = 3,   ['tshirt_2'] = 0,
            ['torso_1'] = 8,    ['torso_2'] = 2,
            ['decals_1'] = 0,   ['decals_2'] = 0,
            ['arms'] = 5,
            ['pants_1'] = 44,   ['pants_2'] = 4,
            ['shoes_1'] = 0,    ['shoes_2'] = 0,
            ['chain_1'] = 0,    ['chain_2'] = 2
        }
      },
}