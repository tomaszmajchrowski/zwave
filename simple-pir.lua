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
local duration = 180; -- seconds to keep on the light after last detected movement
local on_by_pir_event=0
local movement;
local countdown
local click_delay=500;

while true do
	local movement = tonumber(fibaro:getValue(pir, 'value'));
  	--[[
  	======================================================================
  	in case movement detected check all condition 
  	======================================================================
    ]]--
	if ( movement == 1 ) then
    	dimlevel = tonumber(fibaro:getGlobalValue('g_pir_dim_lev_pl'));
    	--fibaro:debug("dim level"..dimlevel)
    	if (dimlevel>0) then
			on_by_pir_event = 1;
      	end
	end
    --[[
  	======================================================================
  	switch on light in case all conditions fill
  	======================================================================
    ]]--
	if ( on_by_pir_event == 1 ) then
    	local current_state = tonumber(fibaro:getValue(light, 'value'));
        
    	while ( current_state==0 ) do
			fibaro:call(light, "setValue", dimlevel);
        	current_state = tonumber(fibaro:getValue(light, 'value'));
            fibaro:sleep(click_delay);
        end
		
    	-- sleep
    	-- not equals ~= operator
    	countdown=duration*10
    	while (countdown ~= 0) do
			fibaro:sleep(100);
      		countdown=countdown-1
      		movement = tonumber(fibaro:getValue(pir, 'value'));
      		-- reset counter in case movement detected
      		if ( movement == 1 ) then
        		countdown=duration*10
        	end
      		
		end
	
    	on_by_pir_event=0
    	-- first of all disable light to avoid click delay
		fibaro:call(light, "turnOff");
    	current_state = tonumber(fibaro:getValue(light, 'value'));
    
        while ( current_state>0 ) do
      		-- if still not disabled sleep for a while and try again..
      		fibaro:sleep(click_delay);
      		--fibaro:debug("Turn off block");
			fibaro:call(light, "turnOff");
      		current_state = tonumber(fibaro:getValue(light, 'value'));
      	end

	end
	fibaro:sleep(100);
end
