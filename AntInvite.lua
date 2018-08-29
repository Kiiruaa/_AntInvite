invite_player = ""
antinvite_engine = "on"

function PrintAntInvite(msg)
    DEFAULT_CHAT_FRAME:AddMessage("\124cffff0000 AntInvite\124r" .. msg)
end

function AntInvite_OnLoad()
	this:RegisterEvent("ADDON_LOADED")
	this:RegisterEvent("PARTY_INVITE_REQUEST")
	this:RegisterEvent("WHO_LIST_UPDATE")
	FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE");
end

function AntInvite_OnUpdate()
end

function AntInvite_OnEvent(event,arg1)
    if event == "ADDON_LOADED" and arg1 == "_AntInvite" then
		if antinvite_level == nil then
			antinvite_level = 14
		end
		PrintAntInvite(": loaded.")
	elseif event == "PARTY_INVITE_REQUEST" and antinvite_engine == "on" then
		if not IsGuildMate(arg1) then
			invite_player = arg1
			SetWhoToUI(1)
			SendWho("n-\""..arg1.."\"")
		end
	elseif event == "WHO_LIST_UPDATE" and antinvite_engine == "on" then
		numWhos, totalCount = GetNumWhoResults();
		local found = nil
		for i=1, numWhos do
			local name = GetWhoInfo(i)
			if name == invite_player then
				found = i
				break
			end
		end
		if found ~= nil then
			local name, guild, level, race, class, zone = GetWhoInfo(found)
			if level <= antinvite_level then
				StaticPopup_Hide("PARTY_INVITE");
				PrintAntInvite(string.format("\124cffff0000 Declined: \124cffffff00%s Level %s %s %s- %s\124r",name,level,class,guild,zone))
			end
		else
			StaticPopup_Hide("PARTY_INVITE"); -- trigger also DeclineGroup();
			PrintAntInvite("\124cffff0000 Declined: \124cffffff00"..invite_player.."\124r")
		end
	end
end

function IsGuildMate(name)
	if IsInGuild() then
		local ngm=GetNumGuildMembers()
		for i=1, ngm do
			n, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName = GetGuildRosterInfo(i);
			if strlower(n) == strlower(name) then
			  return true
			end
		end
	end
	return nil
end

SlashCmdList.antinvite = function(message)
	local commandlist = { }
	local command
	for command in string.gfind(message, "[^ ]+") do
		table.insert(commandlist, string.lower(command))
	end
	local cmd1 = string.lower(commandlist[1] or antinvite_engine == "off" and "on" or "off")
	local cmd2 = tonumber(commandlist[2])
	if cmd1 == "off" or cmd1 == "on" then
		antinvite_engine = cmd1
		PrintAntInvite(" set to " .. cmd1 .. ".")
	elseif cmd1 == "level" and cmd2 ~= nil then
		antinvite_level = cmd2
		PrintAntInvite(": declined level set to "..cmd2..".")
	else
		PrintAntInvite(": State is " .. antinvite_engine .. ".")
		PrintAntInvite(": declined level is set to "..antinvite_level..".")
		PrintAntInvite(": States are \"off\", \"on\", and \"level <number>\".")
	end
end
SLASH_antinvite1 = "/antinvite"
SLASH_antinvite2 = "/ai"