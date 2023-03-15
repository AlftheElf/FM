FM_VERSION = "Version 1.0"

FM_Save = {}

FM_mages = {};


function FM_OnLoad()

	SLASH_FM1 = "/focusmagic";
	SLASH_FM2 = "/fm";
	SLASH_FM3 = "/FM"
	SlashCmdList["FM"] = function(msg)
		FM_SlashCommandHandler(msg);
	end


end

function FM_OnUpdate()
	--Do something on update.
end

function FM_OnEvent(event)
end


function getOrder()
	local numRaidMembers = GetNumRaidMembers();
	if (  GetNumRaidMembers() > 0 ) then
		FM_name = {};
		FM_class = {};
		FM_others = {}

		for i = 1, GetNumRaidMembers(), 1 do
			local unitString = UnitName("raid"..i);
			local _, classString = UnitClass("raid"..i);
			table.insert(FM_name, unitString);
			table.insert(FM_class, classString);
		end

		if (GetNumRaidMembers() == numRaidMembers) then -- If raid members changed during function
			-- Get mages
			FM_mages = {};
			for i = 1, #FM_name, 1 do
				if (FM_class[i] == 'MAGE') then
					table.insert(FM_mages, FM_name[i]);
				else
					table.insert(FM_others, FM_name[i])
				end
			end

			if (#FM_mages < 2) then
				SELECTED_CHAT_FRAME:AddMessage("\124cffFF0000Not enough mages in raid group\124r")
				return nil;
			else
				-- Alphabetise
				table.sort(FM_mages, function (a, b)
	  				return string.upper(a) < string.upper(b)
				end)

				return FM_mages;
			end

		else
			getOrder()
		end
	else
		SELECTED_CHAT_FRAME:AddMessage("\124cffFF0000You are not in a raid group\124r");
		return nil;
	end
end


function get_key_for_value( t, value )
  		for k,v in pairs(t) do
    		if v==value then return k end
  		end
  		return nil
	end

function getOrderString(mages)
	local str = "";
	local strLines = {};
	local numPairs = math.floor(#mages/2);

	-- for i in pairs, pair off, if len(mages) is odd, do last one as a three.

	for i = 1, numPairs, 1 do
		if ( (i == numPairs) and (#mages % 2 == 1) ) then
			--print(mages[#mages-2].." > "..mages[#mages-1].." > "..mages[#mages].." > "..mages[#mages-2])
			table.insert(strLines, mages[#mages-2].." > "..mages[#mages-1].." > "..mages[#mages].." > "..mages[#mages-2])
		else
			--print(mages[i*2-1].." <> "..mages[i*2])
			table.insert(strLines, mages[i*2-1].." <> "..mages[i*2])
		end
	end
	return strLines;
end

function table.table_copy(t)
	local t2 = {}
	for k,v in pairs(t) do
	  t2[k] = v
	end
	return t2
end

function FM_SlashCommandHandler(msg)

	-- Handle all the options
	if( msg ) then
		local command = string.lower(msg);

		if( command == "order" ) then
			--Print full order sequence
			FM_mages2 = getOrder();
			if (FM_mages2 ~= nil) then
				--Print
				local str = getOrderString(FM_mages2);

				local headerMessage = "\124cff00FFFFFM Order: \124r";

				SELECTED_CHAT_FRAME:AddMessage(headerMessage);
				for i = 1, #str, 1 do
					local colourString = "\124cffFF00FF"..str[i].."\124r";
					SELECTED_CHAT_FRAME:AddMessage(colourString);
				end
			end

		-- elseif( command == "who" ) then
		-- 	local _, playerClass =  UnitClass("player");
		-- 	if (playerClass == 'MAGE') then
		-- 		--Print only player you need to FM
		-- 		FM_mages2 = getOrder();
		-- 		if (FM_mages2 ~= nil) then
		-- 			local mageKey = get_key_for_value(FM_mages2, UnitName("player"));
		-- 			local FMtarget = FM_mages2[(mageKey+1) % #FM_mages2];
		-- 			SELECTED_CHAT_FRAME:AddMessage("\124cffFF00FF"..UnitName("player").." > "..FMtarget.."\124r");
		-- 		end
		-- 	else
		-- 		SELECTED_CHAT_FRAME:AddMessage("\124cffFF0000You are not currently playing a mage\124r");
		-- 	end

		elseif( command == "shout" ) then
			FM_mages2 = getOrder();
			if (FM_mages2 ~= nil) then
				local str = getOrderString(FM_mages2);
				SendChatMessage("FM Order: ", "RAID");
				for i = 1, #str, 1 do
					SendChatMessage(str[i], "RAID");
				end
				
			end
		else
			SELECTED_CHAT_FRAME:AddMessage("Help activated");
			FM_Help();
		end
	end
end

function FM_Help()
	SELECTED_CHAT_FRAME:AddMessage(FM_VERSION.." : Usage - /fm <option>");
	SELECTED_CHAT_FRAME:AddMessage(" options:");
	SELECTED_CHAT_FRAME:AddMessage("  order : Displays FM order");
	--SELECTED_CHAT_FRAME:AddMessage("  who   : Displays who you need to FM");
	SELECTED_CHAT_FRAME:AddMessage("  shout : Announces the FM order to raid group");
end