--[[
%% properties
%% autostart
%% globals
--]]
-- created by Tomasz Majchrowski
local pir = 4509; -- pir id: change this to the id of your motion detector
local light = 3824; -- light id: change this to the id of your light dimmer only
local dimlevel = 100; -- dim-level

while true do
	local movement = tonumber(fibaro:getValue(pir, 'value'));
  	
	if ( movement == 1 ) then
		local current_state = tonumber(fibaro:getValue(light, 'value'));
    	fibaro:debug("current_state:="..current_state)
		if ( current_state == 0 ) then
      		fibaro:debug("Turn on block")
			fibaro:call(light, "setValue", dimlevel);
		else
      		-- in some rear case msgs are lost. loop till 
      		-- really disabled
      		while ( current_state>0 ) do
      			fibaro:debug("Turn off block");
				fibaro:call(light, "turnOff");
      			current_state = tonumber(fibaro:getValue(light, 'value'));
        		fibaro:sleep(500);
      		end
		end
    	fibaro:sleep(500);
    	fibaro:debug("loop end")
	end
  	fibaro:sleep(100);
end
