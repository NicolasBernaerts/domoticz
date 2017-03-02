--
-- script to send telegram notification on smoke detection
--

commandArray = {}

-- devices
local SMOKE_DETECTOR = 'NameOfYourSmokeDetector'

-- constant
TELEGRAM_USER = "YourUserOrGroupID"
TELEGRAM_TITLE = "Fire alarm"
TELEGRAM_MESSAGE = "Smoke detector " .. SMOKE_DETECTOR .. " switched to *Panic* mode"

-- if detector switched to panic mode, send telegram notification
if (devicechanged[SMOKE_DETECTOR] == 'Panic') then

  -- create telegram command parameters
  TELEGRAM_PARAMETERS = "--icon '1F6A8' --user " .. TELEGRAM_USER .. " --title '" .. TELEGRAM_TITLE .. "' --text '" .. TELEGRAM_MESSAGE .. "'"

  -- send message
  os.execute ("/usr/local/sbin/telegram-notify " .. TELEGRAM_PARAMETERS)

end

return commandArray
