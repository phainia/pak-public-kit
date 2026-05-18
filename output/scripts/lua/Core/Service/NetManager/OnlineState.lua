local OnlineState = {
  Begin = 0,
  Logouted = 0,
  Logining = 1,
  Logined = 2,
  EnteringCell = 3,
  EnteredCell = 4,
  SwitchingCell = 5,
  End = 7
}
local OnlineStateName = {
  [OnlineState.Logouted] = "OnlineState.Logouted",
  [OnlineState.Logining] = "OnlineState.Logining",
  [OnlineState.Logined] = "OnlineState.Logined",
  [OnlineState.EnteringCell] = "OnlineState.EnteringCell",
  [OnlineState.EnteredCell] = "OnlineState.EnteredCell",
  [OnlineState.SwitchingCell] = "OnlineState.SwitchingCell"
}

function OnlineState.ToString(CurOnlineState)
  return OnlineStateName[CurOnlineState]
end

return OnlineState
