local PLUGIN = PLUGIN

ix.command.Add("SetRank", {
    description = "Set a player's rank",
    arguments = {
        ix.type.player,
        ix.type.text
    },
    OnRun = function(self, client, target, rank)
        local ranks = {
            owner = "owner",
            superadmin = "superadmin",
            admin = "admin",
            user = "user"
        }

        rank = rank:lower()
        if not ranks[rank] then
            return client:Notify("Invalid rank!")
        end

        local rankOrder = {user = 1, admin = 2, superadmin = 3, owner = 4}
        if rankOrder[rank] >= (rankOrder[client:GetUserGroup()] or 0) and client:GetUserGroup() ~= "owner" then
            return client:Notify("You cannot set someone to this rank!")
        end

        target:SetUserGroup(rank)
        client:NotifyLocalized("cChangeRank", client:Nick(), target:Nick(), rank)
    end
})


ix.command.Add("Goto", {
    description = "Teleport yourself to another player.",
    arguments = {
        ix.type.player
    },
    OnRun = function(self, client, target)
        if not client:IsAdmin() then
            return L("InsufficientPrivileges")
        end

        client:SetPos(target:GetPos() + Vector(0,0,50))
        client:NotifyLocalized("PlayerGoto", client:GetName(), target:GetName())
    end
})

ix.command.Add("Bring", {
    description = "Bring another player to where you are looking.",
    arguments = {
        ix.type.player
    },
    OnRun = function(self, client, target)
        if not client:IsAdmin() then
            return L("InsufficientPrivileges")
        end

        local trace = client:GetEyeTrace()
        if trace.Hit then
            local pos = trace.HitPos + Vector(0, 0, 10)
            target:SetPos(pos)

            client:NotifyLocalized("PlayerBrought", client:GetName(), target:GetName())
            target:NotifyLocalized("PlayerBroughtTarget", client:GetName())
        end
    end
})

ix.command.Add("PlyKick", {
    description = "Kick a player with a reason.",
    arguments = {
        ix.type.player,
        ix.type.text
    },
    OnRun = function(self, client, target, reason)
        if not client:IsAdmin() then
            return client:NotifyLocalized("InsufficientPrivileges")
        end

        if not IsValid(target) then
            return client:NotifyLocalized("InvalidTarget")
        end

        reason = reason or "No reason provided"

        target:Kick(reason)
        client:NotifyLocalized("KickMessage", client:Nick(), target:Nick(), reason)
        target:NotifyLocalized("YouWereKicked", client:Nick(), reason)
    end
})

ix.command.Add("PlyBan", {
    description = "Ban a player for a duration with a reason.",
    arguments = {
        ix.type.player,
        ix.type.number,
        ix.type.text
    },
    OnRun = function(self, client, target, duration, reason)
        if not client:IsAdmin() then
            return client:NotifyLocalized("InsufficientPrivileges")
        end

        if not IsValid(target) then
            return client:NotifyLocalized("InvalidTarget")
        end

        duration = math.max(tonumber(duration) or 0, 0)
        reason = reason or "No reason provided"

        game.ConsoleCommand("banid " .. duration .. " " .. target:SteamID() .. " kick\n")
        game.ConsoleCommand("writeid\n")

        target:Kick(reason)
        client:NotifyLocalized("BanMessage", client:Nick(), target:Nick(), tostring(duration), reason)
        target:NotifyLocalized("YouWereBanned", client:Nick(), tostring(duration), reason)
    end
})

ix.command.Add("CharGiveFlag", {
	description = "@cmdCharGiveFlag",
	privilege = "Manage Character Flags",
	superAdminOnly = true,
	arguments = {
		ix.type.character,
		bit.bor(ix.type.string, ix.type.optional)
	},
	OnRun = function(self, client, target, flags)

		if (!flags) then
			local available = ""

			for k, _ in SortedPairs(ix.flag.list) do
				if (!target:HasFlags(k)) then
					available = available .. k
				end
			end

			return client:RequestString("@flagGiveTitle", "@cmdCharGiveFlag", function(text)
				ix.command.Run(client, "CharGiveFlag", {target:GetName(), text})
			end, available)
		end

		target:GiveFlags(flags)

		for _, v in player.Iterator() do
			if (self:OnCheckAccess(v) or v == target:GetPlayer()) then
				v:NotifyLocalized("flagGive", client:GetName(), target:GetName(), flags)
			end
		end
	end
})

ix.command.Add("CharTakeFlag", {
	description = "@cmdCharTakeFlag",
	privilege = "Manage Character Flags",
	superAdminOnly = true,
	arguments = {
		ix.type.character,
		bit.bor(ix.type.string, ix.type.optional)
	},
	OnRun = function(self, client, target, flags)
		if (!flags) then
			return client:RequestString("@flagTakeTitle", "@cmdCharTakeFlag", function(text)
				ix.command.Run(client, "CharTakeFlag", {target:GetName(), text})
			end, target:GetFlags())
		end

		target:TakeFlags(flags)

		for _, v in player.Iterator() do
			if (self:OnCheckAccess(v) or v == target:GetPlayer()) then
				v:NotifyLocalized("flagTake", client:GetName(), flags, target:GetName())
			end
		end
	end
})

ix.command.Add("CharSetModel", {
	description = "@cmdCharSetModel",
	superAdminOnly = true,
	arguments = {
		ix.type.character,
		ix.type.string
	},
	OnRun = function(self, client, target, model)
		target:SetModel(model)
		target:GetPlayer():SetupHands()

		for _, v in player.Iterator() do
			if (self:OnCheckAccess(v) or v == target:GetPlayer()) then
				v:NotifyLocalized("cChangeModel", client:GetName(), target:GetName(), model)
			end
		end
	end
})

ix.command.Add("CharSetSkin", {
	description = "@cmdCharSetSkin",
	adminOnly = true,
	arguments = {
		ix.type.character,
		bit.bor(ix.type.number, ix.type.optional)
	},
	OnRun = function(self, client, target, skin)
		target:SetData("skin", skin)
		target:GetPlayer():SetSkin(skin or 0)

		for _, v in player.Iterator() do
			if (self:OnCheckAccess(v) or v == target:GetPlayer()) then
				v:NotifyLocalized("cChangeSkin", client:GetName(), target:GetName(), skin or 0)
			end
		end
	end
})

ix.command.Add("CharSetBodygroup", {
	description = "@cmdCharSetBodygroup",
	adminOnly = true,
	arguments = {
		ix.type.character,
		ix.type.string,
		bit.bor(ix.type.number, ix.type.optional)
	},
	OnRun = function(self, client, target, bodygroup, value)
		local index = target:GetPlayer():FindBodygroupByName(bodygroup)

		if (index > -1) then
			if (value and value < 1) then
				value = nil
			end

			local groups = target:GetData("groups", {})
				groups[index] = value
			target:SetData("groups", groups)
			target:GetPlayer():SetBodygroup(index, value or 0)

			ix.util.NotifyLocalized("cChangeGroups", nil, client:GetName(), target:GetName(), bodygroup, value or 0)
		else
			return "@invalidArg", 2
		end
	end
})

ix.command.Add("CharSetName", {
	description = "@cmdCharSetName",
	adminOnly = true,
	arguments = {
		ix.type.character,
		bit.bor(ix.type.text, ix.type.optional)
	},
	OnRun = function(self, client, target, newName)

		if (newName:len() == 0) then
			return client:RequestString("@chgName", "@chgNameDesc", function(text)
				ix.command.Run(client, "CharSetName", {target:GetName(), text})
			end, target:GetName())
		end

		for _, v in player.Iterator() do
			if (self:OnCheckAccess(v) or v == target:GetPlayer()) then
				v:NotifyLocalized("cChangeName", client:GetName(), target:GetName(), newName)
			end
		end

		target:SetName(newName:gsub("#", "#​"))
	end
})

ix.command.Add("CharKick", {
	description = "@cmdCharKick",
	adminOnly = true,
	arguments = ix.type.character,
	OnRun = function(self, client, target)
		target:Save(function()
			target:Kick()
		end)

		for _, v in player.Iterator() do
			if (self:OnCheckAccess(v) or v == target:GetPlayer()) then
				v:NotifyLocalized("charKick", client:GetName(), target:GetName())
			end
		end
	end
})

ix.command.Add("CharBan", {
	description = "@cmdCharBan",
	privilege = "Ban Character",
	arguments = {
		ix.type.character,
		bit.bor(ix.type.number, ix.type.optional)
	},
	adminOnly = true,
	OnRun = function(self, client, target, minutes)
		if (minutes) then
			minutes = minutes * 60
		end

		target:Ban(minutes)
		target:Save()

		for _, v in player.Iterator() do
			if (self:OnCheckAccess(v) or v == target:GetPlayer()) then
				v:NotifyLocalized("charBan", client:GetName(), target:GetName())
			end
		end
	end
})

ix.command.Add("PlyWhitelist", {
	description = "@cmdPlyWhitelist",
	privilege = "Manage Character Whitelist",
	superAdminOnly = true,
	arguments = {
		ix.type.player,
		ix.type.text
	},
	OnRun = function(self, client, target, name)
		if (name == "") then
			return "@invalidArg", 2
		end

		local faction = ix.faction.teams[name]

		if (!faction) then
			for _, v in ipairs(ix.faction.indices) do
				if (ix.util.StringMatches(L(v.name, client), name) or ix.util.StringMatches(v.uniqueID, name)) then
					faction = v

					break
				end
			end
		end

		if (faction) then
			if (target:SetWhitelisted(faction.index, true)) then
				for _, v in player.Iterator() do
					if (self:OnCheckAccess(v) or v == target) then
						v:NotifyLocalized("whitelist", client:GetName(), target:GetName(), L(faction.name, v))
					end
				end
			end
		else
			return "@invalidFaction"
		end
	end
})

ix.command.Add("PlyUnwhitelist", {
	description = "@cmdPlyUnwhitelist",
	privilege = "Manage Character Whitelist",
	superAdminOnly = true,
	arguments = {
		ix.type.string,
		ix.type.text
	},
	OnRun = function(self, client, target, name)
		local faction = ix.faction.teams[name]

		if (!faction) then
			for _, v in ipairs(ix.faction.indices) do
				if (ix.util.StringMatches(L(v.name, client), name) or ix.util.StringMatches(v.uniqueID, name)) then
					faction = v

					break
				end
			end
		end

		if (faction) then
			local targetPlayer = ix.util.FindPlayer(target)

			if (IsValid(targetPlayer) and targetPlayer:SetWhitelisted(faction.index, false)) then
				for _, v in player.Iterator() do
					if (self:OnCheckAccess(v) or v == targetPlayer) then
						v:NotifyLocalized("unwhitelist", client:GetName(), targetPlayer:GetName(), L(faction.name, v))
					end
				end
			else
				local steamID64 = util.SteamIDTo64(target)
				local query = mysql:Select("ix_players")
					query:Select("data")
					query:Where("steamid", steamID64)
					query:Limit(1)
					query:Callback(function(result)
						if (istable(result) and #result > 0) then
							local data = util.JSONToTable(result[1].data or "[]")
							local whitelists = data.whitelists and data.whitelists[Schema.folder]

							if (!whitelists or !whitelists[faction.uniqueID]) then
								return
							end

							whitelists[faction.uniqueID] = nil

							local updateQuery = mysql:Update("ix_players")
								updateQuery:Update("data", util.TableToJSON(data))
								updateQuery:Where("steamid", steamID64)
							updateQuery:Execute()

							for _, v in player.Iterator() do
								if (self:OnCheckAccess(v)) then
									v:NotifyLocalized("unwhitelist", client:GetName(), target, L(faction.name, v))
								end
							end
						end
					end)
				query:Execute()
			end
		else
			return "@invalidFaction"
		end
	end
})

ix.command.Add("CharDesc", {
	description = "@cmdCharDesc",
	arguments = bit.bor(ix.type.text, ix.type.optional),
	OnRun = function(self, client, description)
		if (!description:find("%S")) then
			return client:RequestString("@cmdCharDescTitle", "@cmdCharDescDescription", function(text)
				ix.command.Run(client, "CharDesc", {text})
			end, client:GetCharacter():GetDescription())
		end

		local info = ix.char.vars.description
		local result, fault, count = info:OnValidate(description)

		if (result == false) then
			return "@" .. fault, count
		end

		client:GetCharacter():SetDescription(description)
		return "@descChanged"
	end
})

ix.command.Add("PlyTransfer", {
	description = "@cmdPlyTransfer",
	adminOnly = true,
	arguments = {
		ix.type.character,
		ix.type.text
	},
	OnRun = function(self, client, target, name)
		local faction = ix.faction.teams[name]

		if (!faction) then
			for _, v in pairs(ix.faction.indices) do
				if (ix.util.StringMatches(L(v.name, client), name)) then
					faction = v

					break
				end
			end
		end

		if (faction) then
			local bHasWhitelist = target:GetPlayer():HasWhitelist(faction.index)

			if (bHasWhitelist) then
				target.vars.faction = faction.uniqueID
				target:SetFaction(faction.index)

				if (faction.OnTransferred) then
					faction:OnTransferred(target)
				end

				for _, v in player.Iterator() do
					if (self:OnCheckAccess(v) or v == target:GetPlayer()) then
						v:NotifyLocalized("cChangeFaction", client:GetName(), target:GetName(), L(faction.name, v))
					end
				end
			else
				return "@charNotWhitelisted", target:GetName(), L(faction.name, client)
			end
		else
			return "@invalidFaction"
		end
	end
})

ix.command.Add("CharSetClass", {
	description = "@cmdCharSetClass",
	adminOnly = true,
	arguments = {
		ix.type.character,
		ix.type.text
	},
	OnRun = function(self, client, target, class)
		local classTable

		for _, v in ipairs(ix.class.list) do
			if (ix.util.StringMatches(v.uniqueID, class) or ix.util.StringMatches(v.name, class)) then
				classTable = v
			end
		end

		if (classTable) then
			local oldClass = target:GetClass()
			local targetPlayer = target:GetPlayer()

			if (targetPlayer:Team() == classTable.faction) then
				target:SetClass(classTable.index)
				hook.Run("PlayerJoinedClass", targetPlayer, classTable.index, oldClass)

				targetPlayer:NotifyLocalized("becomeClass", L(classTable.name, targetPlayer))

				-- only send second notification if the character isn't setting their own class
				if (client != targetPlayer) then
					return "@setClass", target:GetName(), L(classTable.name, client)
				end
			else
				return "@invalidClassFaction"
			end
		else
			return "@invalidClass"
		end
	end
})

ix.command.Add("MapRestart", {
	description = "@cmdMapRestart",
	adminOnly = true,
	arguments = bit.bor(ix.type.number, ix.type.optional),
	OnRun = function(self, client, delay)
		delay = delay or 10
		ix.util.NotifyLocalized("mapRestarting", nil, delay)

		timer.Simple(delay, function()
			RunConsoleCommand("changelevel", game.GetMap())
		end)
	end
})