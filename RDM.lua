local profile = {};
local sets = {
    ['Idle_Priority'] = {
        Main = 'Dark Staff',
		Ammo = 'Morion tathlum',
        Head = 'Baron\'s Chapeau',
        Neck = 'Black Neckerchief',
        Ear1 = 'Morion Earring',
        Ear2 = 'Morion Earring',
        Body = 'Baron\'s Saio',
        Hands = 'Baron\'s Cuffs',
        Ring1 = 'Eremite\'s Ring',
        Ring2 = 'Eremite\'s Ring',
        Back = 'Black cape +1',
        Waist = 'Friar\'s Rope',
        Legs = 'Custom Slacks',
        Feet = 'Custom M Boots',
    },
	['Resting'] = {
	Main = 'Dark Staff',
	},
	['Cure'] = {
	Main = 'Light Staff',
	Head = 'Traveler\'s Hat',
	Neck = 'Justice Badge',
	Hands = 'Devotee\'s mitts',
	Ring1 = 'Saintly Ring',
	Ring2 = 'Saintly Ring',
	Back = 'White cape',
	},
	['DebuffMND'] = {
	Main = 'Solid wand',
	Head = 'Traveler\'s Hat',
	Neck = 'Justice Badge',
	Hands = 'Devotee\'s mitts',
	Ring1 = 'Saintly Ring',
	Ring2 = 'Saintly Ring',
	Back = 'White Cape',
	},
	['DebuffINT'] = {
	Main = 'Solid wand',
	Head = 'Baron\'s chapeau',
	Neck = 'Black Neckerchief',
	Ear1 = 'Morion earring',
	Ear2 = 'Morion earring',
	Hands = 'Baron\'s cuffs',
	Ring1 = 'Eremite\'s ring',
	Ring2 = 'Eremite\'s ring',
	Back = 'Black cape +1',
	},
};
profile.Sets = sets;

profile.Packer = {};

-- Local elemental staves table assigning magic type to stave
local ElementalStaffTable = {
    ['Fire'] = 'Fire Staff',
    ['Earth'] = 'Earth Staff',
    ['Water'] = 'Water Staff',
    ['Wind'] = 'Wind Staff',
    ['Ice'] = 'Ice Staff',
    ['Thunder'] = 'Thunder Staff',
    ['Light'] = 'Light Staff',
    ['Dark'] = 'Dark Staff'
};

-- Spells table(s)
local Spells = {};

-- Cure spells
Spells.Cures = {
    ['Cure'] = true,
    ['Cure II'] = true,
    ['Cure III'] = true,
    ['Cure IV'] = true,
    ['Cure V'] = true,
    ['Cure VI'] = true,
    ['Curaga'] = true,
    ['Curaga II'] = true,
    ['Curaga III'] = true,
    ['Curaga IV'] = true,
    ['Curaga V'] = true,
    ['Cura'] = true,
    ['Cura II'] = true,
    ['Cura III'] = true,
}

-- Spells whose gear is of no consequence
Spells.ConserveMP = {
    ['Escape'] = true,
    ['Tractor'] = true,
    ['Warp'] = true,
    ['Warp II'] = true,
}

-- Elemental debuffs
Spells.ElementalDebuffs = {
    ['Burn'] = true,
    ['Choke'] = true,
    ['Drown'] = true,
    ['Frost'] = true,
    ['Rasp'] = true,
    ['Shock'] = true,
}

-- Enfeebles
Spells.Enfeebles = {
	['Paralyze'] = true,
	['Dia'] = true,
	['Dia II'] = true,
	['Slow'] = true,
	['Slow II'] = true,
	['Blind'] = true,
	['Sleep'] = true,
	['Sleep II'] = true,
}

-- Settings
local Settings = {
    CurrentLevel  = 0,
    IsFishing = false,
};

-- Start of the profile functions
profile.Packer = {};

-- When the profile loads
profile.OnLoad = function()
    gSettings.AllowAddSet = true;
end

-- When the profile unloads
profile.OnUnload = function()
end

-- When a manual command is sent to Ashitacast
profile.HandleCommand = function(args)

    -- Catch the "fishing" command
    if (args[1] == "fishing") then
        if (Settings.IsFishing == true) then
            Settings.IsFishing = false;
        else
            Settings.IsFishing = true;
        end
    end

end

-- When an action is complete and the character resets to a default state
profile.HandleDefault = function()

    -- Get the required data table(s)
    local player = gData.GetPlayer();

    -- Evaluate for level sync
    local curLevel = AshitaCore:GetMemoryManager():GetPlayer():GetMainJobLevel();
    if (curLevel ~= Settings.CurrentLevel) then
        gFunc.EvaluateLevels(profile.Sets, curLevel);
        Settings.CurrentLevel = curLevel;
    end
    
    -- When engaged
    if (player.Status == 'Engaged') then
        gFunc.EquipSet(sets.Engaged);

    -- When resting
    elseif (player.Status == 'Resting') then
        gFunc.EquipSet(sets.Resting);

    -- All other statuses
    else
        if (Settings.IsFishing == true) then
            gFunc.EquipSet(sets.UtilFishing);
        else
            gFunc.EquipSet(sets.Idle);
        end
    end

end

-- When job abilities are triggered
profile.HandleAbility = function()
end

-- When items are used
profile.HandleItem = function()
end

-- Before casting begins
profile.HandlePrecast = function()
    gFunc.EquipSet(sets.FastCast);
end

-- When a spell is cast
profile.HandleMidcast = function()
    local MndDebuffs = T{ 'Slow', 'Paralyze', 'Slow II', 'Paralyze II', 'Addle', 'Addle II' };
    local ElementalDebuffs = T{ 'Burn', 'Rasp', 'Drown', 'Choke', 'Frost', 'Shock' };
    local action = gData.GetAction();				
    if (action.Skill == 'Enfeebling Magic') then
        if (MndDebuffs:contains(action.Name)) then
            gFunc.EquipSet(sets.DebuffMND);
        else
            gFunc.EquipSet(sets.DebuffINT);
        end
        gFunc.Equip('main', ElementalStaffTable[action.Element]);
    elseif (action.Skill == 'Elemental Magic') then
        if (ElementalDebuffs:contains(action.Name)) then
            gFunc.EquipSet(sets.ElementalDebuff);
        elseif (action.Name == 'Impact') then
            gFunc.EquipSet(sets.Impact);
        else
            gFunc.EquipSet(sets.Nuke);
        end
        gFunc.Equip('main', ElementalStaffTable[action.Element]);
    elseif (action.Skill == 'Dark Magic') then
        if (action.Name == 'Stun') then
            gFunc.EquipSet(sets.Stun);
        else
            gFunc.EquipSet(sets.DarkMagic);
        end
        gFunc.Equip('main', ElementalStaffTable[action.Element]);
    elseif string.match(action.Name, 'Cure') or string.match(action.Name, 'Curaga') then
        gFunc.EquipSet(sets.Cure);
    elseif (action.Skill == 'Enhancing Magic') then
        gFunc.EquipSet(sets.Enhancing);
    else
        gFunc.EquipSet(sets.Haste);
    end
end

-- Before a shot is taken
profile.HandlePreshot = function()
end

-- When a shot is taken
profile.HandleMidshot = function()
end

-- When a weapons skill is triggered
profile.HandleWeaponskill = function()

    -- Get the required data table(s)
    local action = gData.GetAction();

    -- Physical weapon skill
    if (WeaponSkills.Physical[action.Name]) then
        gFunc.EquipSet(
            gFunc.Combine(
                sets.WSBase,
                sets.WSPhysical
            )
        );

    -- Magical weapon skill
    elseif (WeaponSkills.Magical[action.Name]) then
        gFunc.EquipSet(
            gFunc.Combine(
                sets.WSBase,
                sets.WSMagical
            )
        );

    -- Breath weapon skill
    elseif (WeaponSkills.Breath[action.Name]) then
        gFunc.EquipSet(
            gFunc.Combine(
                sets.WSBase,
                sets.WSBreath
            )
        );
    
    end

end

return profile;