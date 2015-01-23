--[[
%% properties
%% autostart
%% globals
--]]
-- created by Tomasz Majchrowski 
local pir = 4161; --      pir id: change this to the id of your motion detector
local light = 4147; --    light id: change this to the id of your light dimmer only
local dimlevel = 100; --  dim-level
local duration = 20; --   seconds to keep on the light after last detected movement

local on_by_pir_event=0
local movement;
local countdown

while true do
	local movement = tonumber(fibaro:getValue(pir, 'value'));
	if ( movement == 1 ) then
		on_by_pir_event = 1;
	end
	if ( on_by_pir_event == 1  ) then
 		if ( tonumber(fibaro:getValue(light, 'value')) == 0 ) then
			fibaro:call(light, "setValue", dimlevel);
 		end
    	-- sleep
    	for countdown = 0, duration*10, 1 do
           fibaro:sleep(100);    	
    	end
 	    on_by_pir_event=0
        fibaro:call(light, "turnOff");
	end

	fibaro:sleep(100);
end
