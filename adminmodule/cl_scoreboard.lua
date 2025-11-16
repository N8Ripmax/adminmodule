local PLUGIN = PLUGIN

hook.Add("PopulateScoreboardPlayerMenu", "scoreboard_utils", function(client, menu)
    if (LocalPlayer():IsAdmin()) then
        menu:AddOption("Set name", function()
            Derma_StringRequest(
                "Set name",
                "",
                client:GetName(),
                function(text)
                    RunConsoleCommand("ix", "CharSetName", client:GetName(), text)
                end
            )
        end)

        menu:AddOption("Set model", function()
            Derma_StringRequest(
                "Set model",
                "",
                client:GetModel(),
                function(text)
                    RunConsoleCommand("ix", "CharSetModel", client:GetName(), text)
                end
            )
        end)

        menu:AddOption("Set description", function()
            Derma_StringRequest(
                "Set description",
                "",
                (client.GetCharacter and client:GetCharacter() and client:GetCharacter():GetDescription()) or "",
                function(text)
                    RunConsoleCommand("ix", "CharSetDesc", client:GetName(), text)
                end
            )
        end)
		
		menu:AddOption("Kick player", function()
			Derma_StringRequest(
				"Kick player",
				"Enter a reason:",
				"",
				function(reason)
					RunConsoleCommand("ix", "PlyKick", client:Nick(), reason)
				end
			)
		end)
		
		menu:AddOption("Ban player", function()
			Derma_StringRequest(
				"Ban duration",
				"Enter duration in minutes (0 = permanent):",
				"",
				function(duration)
				Derma_StringRequest(
					"Ban reason",
					"Enter a reason:",
					"",
					function(reason)
						RunConsoleCommand("ix", "PlyBan", client:Nick(), duration, reason)
					end
				)
				end
			)
		end)

        local submenuWhitelist = menu:AddSubMenu("Whitelist")
        local submenuUnwhitelist = menu:AddSubMenu("Unwhitelist")

        local whitelists = client:GetData("whitelists", {})
        whitelists[Schema.folder] = whitelists[Schema.folder] or {}

        for _, v in ipairs(ix.faction.indices) do
            if (not v.isDefault) then
                submenuWhitelist:AddOption(v.name, function()
                    RunConsoleCommand("ix", "PlyWhitelist", client:GetName(), v.name)
                end)
            end
        end

        for _, v in ipairs(ix.faction.indices) do
            if (not v.isDefault) then
                submenuUnwhitelist:AddOption(v.name, function()
                    RunConsoleCommand("ix", "PlyUnwhitelist", client:GetName(), v.name)
                end)
            end
        end

        local transfer = menu:AddSubMenu("Transfer")
        for k, v in ipairs(ix.faction.indices) do
            if k ~= (client.GetCharacter and client:GetCharacter() and client:GetCharacter():GetFaction()) then
                transfer:AddOption(v.name, function()
                    RunConsoleCommand("ix", "PlyTransfer", client:GetName(), v.name)
                end)
            end
        end

        local giveFlag = menu:AddSubMenu("Give flag")
        for k, v in pairs(ix.flag.list) do
            if client:GetCharacter():HasFlags(k) ~= true then
                giveFlag:AddOption(k .. " - " .. v.description, function()
                    RunConsoleCommand("ix", "CharGiveFlag", client:GetName(), k)
                end)
            end
        end

        local takeFlag = menu:AddSubMenu("Take flag")
        for k, v in pairs(ix.flag.list) do
            if client:GetCharacter():HasFlags(k) == true then
                takeFlag:AddOption(k .. " - " .. v.description, function()
                    RunConsoleCommand("ix", "CharTakeFlag", client:GetName(), k)
                end)
            end
        end

        menu:AddOption("Permanent kill", function()
            RunConsoleCommand("ix", "CharBan", client:GetName())
        end)
		menu:AddOption("Goto", function()
			RunConsoleCommand("ix", "Goto", client:Nick())
		end)

		menu:AddOption("Bring", function()
			RunConsoleCommand("ix", "Bring", client:Nick()) 
		end)
    end
end)