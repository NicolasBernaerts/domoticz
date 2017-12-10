--
-- Script to manage an exhaust FAN according to hygrometer level
--
-- Devices are :
--  * DEVICE_HYGROMETER : humidity meter
--  * DEVICE_SWITCH     : switch to control VMC high speed
--
-- Variables are :
--  * USER_TARGET       : Target humidity level (in %, around 50)
--  * USER_HYSTERESIS   : Hysteresis to switch on/off (in %, usually 2)
--

commandArray = {}

--
-- declarations
--

-- devices
local ROOM_NAME         = 'Bathroom'
local DEVICE_HYGROMETER = 'Bathroom Sensor'
local DEVICE_SWITCH     = 'Bathroom VMC'

-- user variables
local USER_TARGET       = 'Bathroom Humidity level'
local USER_HYSTERESIS   = 'Bathroom Humidity hysteresis'

--
-- acquisition
--

-- hygrometer
hygro_level = otherdevices_humidity[DEVICE_HYGROMETER]

-- vmc
vmc_state = otherdevices[DEVICE_SWITCH]

--
-- action
--

-- check if the sensor is on or has some weird reading
if (hygro_level == 0 or hygro_level == nil) then

	-- error
	print(DEVICE_HYGROMETER .. ' - Skipping reading as level is 0 or nil')

else

	-- read target levels
	hygro_target = tonumber(uservariables[USER_TARGET])
	hygro_hysteresis = tonumber(uservariables[USER_HYSTERESIS])

	-- calculate min and max levels
	hygro_target_on = hygro_target + hygro_hysteresis
	hygro_target_off = hygro_target - hygro_hysteresis

	-- log
	print(ROOM_NAME .. ' - Humidity ' .. hygro_level .. '% and VMC ' .. vmc_state .. ' (target ' .. hygro_target .. '%)')

	-- if VMC should start
	if (vmc_state == 'Off' and hygro_level >= hygro_target_on) then

		-- log
		print(DEVICE_SWITCH .. ' - Switching On [max humidity ' .. hygro_target_on .. '% reached]')

		-- switch on
		commandArray[DEVICE_SWITCH] = 'On'

	-- else, if VMC should stop
	elseif (vmc_state == 'On' and hygro_level <= hygro_target_off) then

		-- log
		print(DEVICE_SWITCH .. ' - Switching Off [min humidity ' .. hygro_target_off .. '% reached]')

		-- switch off
		commandArray[DEVICE_SWITCH] = 'Off'

	end
end

return commandArray
