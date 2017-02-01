--
-- Script to manage an exhaust FAN according to hygrometer level
--

commandArray = {}

-- devices
local DEVICE_HYGRO = 'NameOfHumiditySensor'
local DEVICE_FAN = 'NameOfExhaustFAN'

-- constant
HYGRO_LEVEL_ON = tonumber(uservariables['Hygro SdB Max'])
HYGRO_LEVEL_OFF = tonumber(uservariables['Hygro SdB Min'])

-- read hygrometer
hygro_level = otherdevices_humidity[DEVICE_HYGRO]
print(DEVICE_HYGRO .. ' level is ' .. hygro_level .. '%')

-- check if the sensor is on or has some weird reading
if (hygro_level == 0 or hygro_level == nil) then
  print('Skipping reading as level is 0 or nil')
  return commandArray
end

-- check if VMC should start
if (otherdevices[DEVICE_FAN] == 'Off' and hygro_level >= HYGRO_LEVEL_ON) then
  print('Switching ' .. DEVICE_FAN .. ' ON as humidity level reached ' .. hygro_level .. '%')
  commandArray[DEVICE_FAN] = 'On'
end

-- check if VMC should stop
if (otherdevices[DEVICE_FAN] == 'On' and hygro_level <= HYGRO_LEVEL_OFF) then
  print('Switching ' .. DEVICE_FAN .. ' OFF as humidity level down to ' .. hygro_level .. '%')
  commandArray[DEVICE_FAN] = 'Off'
end

return commandArray
