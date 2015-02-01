--[[
%% properties

%% globals
--]]
--[[
created by Tomasz Majchrowski
TODO: Provide thread safe implementation
--]]
local shutter_ids = { 4307, 4303, 4305 }; -- light id: change this to the id of your light dimmer only
local open_delay=20 -- in seconds
local l_shutter_mutex = tonumber(fibaro:getGlobalValue('shutter_mutex'));

--[[ 
==============================================================
reserve shutters if possible
==============================================================
--]]
fibaro:debug("reserv"..l_shutter_mutex)
if ( l_shutter_mutex==0) then
  fibaro:setGlobal('shutter_mutex', 1)
  fibaro:debug('shitter reserved')
else
  fibaro:debug('shitter need reservation')
  local l_shutter_req_mutex = tonumber(fibaro:getGlobalValue('shutter_req_mutex'));
  
  if ( l_shutter_req_mutex==0) then
  	fibaro:setGlobal('shutter_req_mutex', 1)
    fibaro:debug('send reservation request')
  else
       fibaro:debug('waiting for request to be released')
       while ( l_shutter_req_mutex~=0 ) do
       		fibaro:sleep(100)
  			l_shutter_req_mutex = tonumber(fibaro:getGlobalValue('shutter_req_mutex'));
  		end
  end
  fibaro:debug('waiting for reservation')
  while ( l_shutter_mutex~=0 ) do
    fibaro:sleep(100)
  	l_shutter_mutex = tonumber(fibaro:getGlobalValue('shutter_mutex'));
    
  end
  fibaro:debug('got reservation')
end

-- allow requests
fibaro:setGlobal('shutter_req_mutex', 0)

--[[ 
==============================================================
Run workflow
==============================================================
--]]

fibaro:debug('Start of the program')
fibaro:debug("Im turning on the devices")

for nameCount = 1, #shutter_ids do
  local shutter_id=shutter_ids[nameCount]
  fibaro:debug("ID"..shutter_id)
  fibaro:call(shutter_id, 'turnOn')
end

--[[
---------------------------------------------------------------
Sleep till time over or request even came
---------------------------------------------------------------
--]]
fibaro:debug('I am waiting'..open_delay..'sec')
for i=1,open_delay*10 do 
	fibaro:sleep(100)
    l_shutter_req_mutex = tonumber(fibaro:getGlobalValue('shutter_req_mutex'));
  	if (l_shutter_req_mutex==1) then
       fibaro:debug('break by external request')
       break
    end
end
--[[
---------------------------------------------------------------
Turn off
---------------------------------------------------------------
--]]
for nameCount = 1, #shutter_ids do
  local shutter_id=shutter_ids[nameCount]
  fibaro:debug("ID"..shutter_id)
  fibaro:call(shutter_id, 'turnOff')
end


-- released reservation
fibaro:setGlobal('shutter_mutex', 0)
