PLUGIN.name = "Admin Module"
PLUGIN.author = "frod"
PLUGIN.description = "A built-in admin module specifically designed for Helix."

if CLIENT then
    local shieldIcon = Material("icon16/shield.png")

    function ix.util.Notify(message, color)
        chat.AddText(
            color or Color(150, 150, 200),
            message
        )
    end

    function ix.util.NotifyLocalized(key, ...)
        chat.AddText(
            Color(150, 150, 200),
            shieldIcon,
            L(key, ...)
        )
    end
end

if SERVER then
    concommand.Add("helix_setowner", function(ply, cmd, args)
        if IsValid(ply) then
            ply:ChatPrint("You have insufficient privileges to run this command.")
            return
        end

        local steamID = args[1]
        if not steamID then
            print("Usage: helix_setowner <steamID>")
            return
        end

        local target = player.GetBySteamID(steamID)
        if IsValid(target) then
            target:SetUserGroup("owner")
            print(target:Nick() .. " has been set to Owner.")
            target:ChatPrint("You have been assigned the Owner rank!")
        else
            print("Player with SteamID " .. steamID .. " not found.")
        end
    end)
end

ix.util.Include("sh_context.lua")
ix.util.Include("cl_scoreboard.lua")
ix.util.Include("sh_commands.lua")