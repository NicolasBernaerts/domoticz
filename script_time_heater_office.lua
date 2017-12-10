--
-- Script to manage an electrical heater with a fil pilote (french tech.)
-- Heater is switched to comfort mode according to holiday period, selector switch and target temperature
--
-- Devices are :
--  * HOLIDAY_PERIOD    : Virtual switch to declare holidays (everything is off)
--  * HEATER_CONTROL    : Virtual selector switch to control heating (off, managed or forced on)
--  * HEATER_PILOT      : Switch to control the heater fil pilote
--  * HEATER_SENSOR     : Temperature sensor
--  * HEATER_TARGET     : Virtual temperature set point to specifiy target temperature
--
-- Variables are :
--  * USER_HYSTERESIS   : Temperature hysteresis to switch heater on/off (in °, usually 0.2)
--

commandArray = {}

--
-- declarations
--

-- devices
local ROOM_NAME       = 'Office'
local HOLIDAY_PERIOD  = 'Office Holidays'
local HEATER_CONTROL  = 'Office Heater'
local HEATER_PILOT    = 'Office Heater fil pilote'
local HEATER_SENSOR   = 'Office Sensor'
local HEATER_TARGET   = 'Office Temperature'

-- user variables
local USER_HYSTERESIS = 'Temperature hysteresis'

-- status
local STATUS_OFF     = '0'
local STATUS_MANAGED = '10'
local STATUS_FORCED  = '20'

--
-- acquisition
--

-- heater selector status
heater_control = otherdevices_svalues[HEATER_CONTROL]

-- actual temperature
temperature_actual = tonumber(otherdevices_temperature[HEATER_SENSOR])

-- fil pilote state
filpilote_state = otherdevices[HEATER_PILOT]

-- holidays state
holiday_period = otherdevices[HOLIDAY_PERIOD]

--
-- action
--

-- calculate heater state
if (filpilote_state == 'On') then heater_state = 'Off' else heater_state = 'On' end

-- if temperature is unreadable, switch off heater as security
if (temperature_actual == nil)  then

	-- log status
	print(ROOM_NAME .. ' - Temperature unreadable and Heater ' .. heater_state)

	-- if heater is on, switch off (state reversed as command is thru fil pilote)
	if (heater_state == 'On') then
		-- log
		print(ROOM_NAME .. ' - Switching Heater Off as security measure')

		-- switch off
		commandArray[HEATER_PILOT] = 'On'
	end

-- if holidays, switch off heater
elseif (holiday_period == 'On')  then

	-- log status
	print(ROOM_NAME .. ' - Temperature ' .. temperature_actual .. '° and Holidays period with Heater Off')

	-- if heater is on, switch off (state reversed as command is thru fil pilote)
	if (heater_state == 'On') then
		-- log
		print(ROOM_NAME .. ' - Switching Heater Off')

		-- switch off
		commandArray[HEATER_PILOT] = 'On'
	end

-- if selector is forced OFF, switch off heater
elseif (heater_control == STATUS_OFF)  then

	-- log status
	print(ROOM_NAME .. ' - Temperature ' .. temperature_actual .. '° and Heater forced Off')

	-- if heater is on, switch off (state reversed as command is thru fil pilote)
	if (heater_state == 'On') then
		-- log
		print(ROOM_NAME .. ' - Switching Heater Off')

		-- switch off
		commandArray[HEATER_PILOT] = 'On'
	end

-- else, if selector is forced ON, switch on heater
elseif (heater_control == STATUS_FORCED) then

	-- log status
	print(ROOM_NAME .. ' - Temperature ' .. temperature_actual .. '° and Heater forced On')

	-- if heater is off, switch on (state reversed as command is thru fil pilote)
	if (heater_state == 'Off') then
		-- log
		print(ROOM_NAME .. ' - Switching Heater On')

		-- switch on
		commandArray[HEATER_PILOT] = 'Off'
	end

-- else, selecter is in managed state
elseif (heater_control == STATUS_MANAGED) then

	-- read target temperature
	temperature_target = tonumber(otherdevices_svalues[HEATER_TARGET])
	temperature_hysteresis = tonumber(uservariables[USER_HYSTERESIS])

	-- calculate min and max temperature
	temperature_target_min = temperature_target - temperature_hysteresis
	temperature_target_max = temperature_target + temperature_hysteresis

	-- log
	print(ROOM_NAME .. ' - Temperature ' .. temperature_actual .. '° and Heater ' .. heater_state .. ' (target ' .. temperature_target .. '°)')

	-- if heater should start
	if (heater_state == 'Off' and temperature_actual <= temperature_target_min) then

		-- log
		print(ROOM_NAME .. ' - Switching Heater On [temperature under ' .. temperature_target_min .. '°]')

		-- switch on
		commandArray[HEATER_PILOT] = 'Off'

	-- else, if heater should stop
	elseif (heater_state == 'On' and temperature_actual >= temperature_target_max) then

		-- log
		print(ROOM_NAME .. ' - Switching Heater Off [temperature over ' .. temperature_target_max .. '°]')

		-- switch off
		commandArray[HEATER_PILOT] = 'On'

	end

end

return commandArray
