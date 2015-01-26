--[[
%% properties
%% autostart
%% globals
--]]
-- created by Tomasz Majchrowski
local pir = 4161; -- pir id: change this to the id of your motion detector
local light = 4147; -- light id: change this to the id of your light dimmer only
local dimlevel = tonumber(fibaro:getGlobalValue('g_pir_dim_lev_pl')); -- dim-level
--local dimlevel = 6 -- comment out line above and uncomment
--						current in case global var missed
local duration = 10; -- seconds to keep on the light after last detected movement
local on_by_pir_event=0
local movement;
local countdown
local click_delay=500;

while true do
	local movement = tonumber(fibaro:getValue(pir, 'value'));
	if ( movement == 1 ) then
    	--fibaro:debug("dim level"..dimlevel)
    	if (dimlevel>0) then
			on_by_pir_event = 1;
      	end
	end
	if ( on_by_pir_event == 1 ) then
    	local current_state = tonumber(fibaro:getValue(light, 'value'));
		if ( current_state == 0 ) then
        	while ( current_state==0 ) do
				fibaro:call(light, "setValue", dimlevel);
        		current_state = tonumber(fibaro:getValue(light, 'value'));
                fibaro:sleep(click_delay);
        	end
		end
		-- sleep
		for countdown = 0, duration*10, 1 do
			fibaro:sleep(100);
		end
	
    	on_by_pir_event=0
	
        while ( current_state>0 ) do
      		--fibaro:debug("Turn off block");
			fibaro:call(light, "turnOff");
      		current_state = tonumber(fibaro:getValue(light, 'value'));
        	fibaro:sleep(click_delay);
      	end

	end
	fibaro:sleep(100);
end
