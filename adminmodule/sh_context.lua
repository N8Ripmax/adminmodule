CAMI.RegisterPrivilege({
    Name = "Owner",
    MinAccess = "superadmin"
})

CAMI.RegisterPrivilege({
    Name = "Superadmin",
    MinAccess = "superadmin"
})

CAMI.RegisterPrivilege({
    Name = "Admin",
    MinAccess = "admin"
})

properties.Add("ixViewPlayerProperty", {
    MenuLabel = "#View Player",
    Order = 1,
    MenuIcon = "icon16/user.png",
    Format = "%s | %s\nHealth: %s\nArmor: %s",

    Filter = function(self, entity, client)
        return CAMI.PlayerHasAccess(client, "Admin", nil) and entity:IsPlayer()
    end,

    Action = function(self, entity)
        self:MsgStart()
            net.WriteEntity(entity)
        self:MsgEnd()
    end,

    Receive = function(self, length, client)
        if (CAMI.PlayerHasAccess(client, "Admin", nil)) then
            local entity = net.ReadEntity()
            if (IsValid(entity) and entity:IsPlayer()) then
                client:NotifyLocalized("viewPlayer", entity:Nick(), entity:SteamID(), entity:Health(), entity:Armor())
            end
        end
    end
})

properties.Add("ixKickPlayerProperty", {
    MenuLabel = "#Kick Player",
    Order = 5,
    MenuIcon = "icon16/door_out.png",

    Filter = function(self, entity, client)
        return CAMI.PlayerHasAccess(client, "Admin", nil) and entity:IsPlayer()
    end,

    Action = function(self, entity)
        self:MsgStart()
            net.WriteEntity(entity)
        self:MsgEnd()
    end,

    Receive = function(self, length, client)
        if CAMI.PlayerHasAccess(client, "Admin", nil) then
            local target = net.ReadEntity()

            if IsValid(target) and target:IsPlayer() then
                client:RequestString("Kick Player", "Reason:", function(reason)
                    RunConsoleCommand("ix", "PlyKick", target:Nick(), reason)
                end)
            end
        end
    end
})

properties.Add("ixBanPlayerProperty", {
    MenuLabel = "#Ban Player",
    Order = 6,
    MenuIcon = "icon16/delete.png",

    Filter = function(self, entity, client)
        return CAMI.PlayerHasAccess(client, "Admin", nil) and entity:IsPlayer()
    end,

    Action = function(self, entity)
        self:MsgStart()
            net.WriteEntity(entity)
        self:MsgEnd()
    end,

    Receive = function(self, length, client)
        if CAMI.PlayerHasAccess(client, "Admin", nil) then
            local target = net.ReadEntity()

            if IsValid(target) and target:IsPlayer() then
                client:RequestString("Ban Player", "Duration in minutes (0 = permanent):", function(duration)
                    client:RequestString("Ban Player", "Reason:", function(reason)
                        RunConsoleCommand("ix", "PlyBan", target:Nick(), duration, reason)
                    end)

                end, "0")
            end
        end
    end
})

properties.Add("ixSetHealthProperty", {
    MenuLabel = "#Health",
    Order = 2,
    MenuIcon = "icon16/heart.png",

    Filter = function(self, entity, client)
        return CAMI.PlayerHasAccess(client, "Admin", nil) and entity:IsPlayer()
    end,

    MenuOpen = function(self, option, ent, tr)
        local submenu = option:AddSubMenu()
        for i = 100, 0, -25 do
            submenu:AddOption(i, function() self:SetHealth(ent, i) end)
        end
    end,

    SetHealth = function(self, target, health)
        self:MsgStart()
            net.WriteEntity(target)
            net.WriteUInt(health, 8)
        self:MsgEnd()
    end,

    Receive = function(self, length, client)
        if (CAMI.PlayerHasAccess(client, "Admin", nil)) then
            local entity = net.ReadEntity()
            local health = net.ReadUInt(8)

            if (IsValid(entity) and entity:IsPlayer()) then
                entity:SetHealth(health)
                if (entity:Health() == 0) then entity:Kill() end

                client:NotifyLocalized("setHealth", entity:Nick(), health)
            end
        end
    end
})

properties.Add("ixSetArmorProperty", {
    MenuLabel = "#Armor",
    Order = 3,
    MenuIcon = "icon16/shield.png",

    Filter = function(self, entity, client)
        return CAMI.PlayerHasAccess(client, "Admin", nil) and entity:IsPlayer()
    end,

    MenuOpen = function(self, option, ent, tr)
        local submenu = option:AddSubMenu()
        for i = 100, 0, -25 do
            submenu:AddOption(i, function() self:SetArmor(ent, i) end)
        end
    end,

    SetArmor = function(self, target, armor)
        self:MsgStart()
            net.WriteEntity(target)
            net.WriteUInt(armor, 8)
        self:MsgEnd()
    end,

    Receive = function(self, length, client)
        if (CAMI.PlayerHasAccess(client, "Admin", nil)) then
            local entity = net.ReadEntity()
            local armor = net.ReadUInt(8)

            if (IsValid(entity) and entity:IsPlayer()) then
                entity:SetArmor(armor)
                client:NotifyLocalized("setArmor", entity:Nick(), armor)
            end
        end
    end
})

properties.Add("ixSetDescriptionProperty", {
    MenuLabel = "#Edit Description",
    Order = 4,
    MenuIcon = "icon16/book_edit.png",

    Filter = function(self, entity, client)
        return CAMI.PlayerHasAccess(client, "Admin", nil) and entity:IsPlayer()
    end,

    Action = function(self, entity)
        self:MsgStart()
            net.WriteEntity(entity)
        self:MsgEnd()
    end,

    Receive = function(self, length, client)
        if (CAMI.PlayerHasAccess(client, "Admin", nil)) then
            local entity = net.ReadEntity()
            if (IsValid(entity) and entity:IsPlayer()) then
                client:RequestString("Set the character's description.", "New Description", function(text)
                    if (IsValid(entity) and entity:IsPlayer() and entity.GetCharacter and entity:GetCharacter()) then
                        entity:GetCharacter():SetDescription(text)
                        client:NotifyLocalized("descChanged", entity:Nick())
                    end
                end, (entity.GetCharacter and entity:GetCharacter() and entity:GetCharacter():GetDescription()) or "")
            end
        end
    end
})