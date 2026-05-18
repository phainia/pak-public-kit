local MiniGameClockSettings = {}

function MiniGameClockSettings:newMiniGameClockSettings()
  return {
    BlockUpdate = false,
    StartSymbol = 1,
    PlayRate = 1,
    startPos = 0,
    Valid = false,
    DurationPer = 9999,
    Activate = false,
    Reset = false,
    Finish = false,
    timeout = false
  }
end

return MiniGameClockSettings
