--
-- Script to manage an exhaust FAN according to hygrometer level
--

commandArray = {}

-- devices
local DEVICE_HYGROMETER = 'NameOfHumiditySensor'
local DEVICE_SWITCH = 'NameOfExhaustFANSwitch'

-- constant
HYGRO_LEVEL_ON = tonumber(uservariables['Bathroom Humidity Max'])
HYGRO_LEVEL_OFF = tonumber(uservariables['Bathroom Humidity Min'])

-- read hygrometer
hygro_level = otherdevices_humidity[DEVICE_HYGROMETER]
print(DEVICE_HYGROMETER .. ' level is ' .. hygro_level .. '%')

-- check if the sensor is on or has some weird reading
if (hygro_level == 0 or hygro_level == nil) then
  print('Skipping reading as level is 0 or nil')
  return commandArray
end

-- check if VMC should start
if (otherdevices[DEVICE_SWITCH] == 'Off' and hygro_level >= HYGRO_LEVEL_ON) then
  print('Switching ' .. DEVICE_SWITCH .. ' ON as humidity level reached ' .. hygro_level .. '% [max set to ' .. HYGRO_LEVEL_ON .. '%]')
  commandArray[DEVICE_SWITCH] = 'On'
end

-- check if VMC should stop
if (otherdevices[DEVICE_SWITCH] == 'On' and hygro_level <= HYGRO_LEVEL_OFF) then
  print('Switching ' .. DEVICE_SWITCH .. ' OFF as humidity level down to ' .. hygro_level .. '% [min set to ' .. HYGRO_LEVEL_OFF .. '%]')
  commandArray[DEVICE_SWITCH] = 'Off'
end

return commandArray
