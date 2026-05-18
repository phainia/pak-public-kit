local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local LoginModuleEvent = require("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local Base = DebugTabBase
local DebugTabPerfInstancing = Base:Extend("DebugTabPerfInstancing")

local function GetCSISStatus()
  local value = UE4.UNRCStatics.GetConsoleVarBool("g.GCloseInstanceByEnterQueue")
  local instype = UE4.UNRCStatics.GetConsoleVarInt32("g.DynamicInstanceType")
  if 1 ~= instype then
    return "CSIS(\229\133\179\233\151\173)"
  end
  if value then
    return "CSIS(\229\133\179\233\151\173)"
  else
    return "CSIS"
  end
end

local function GetISMStatus()
  local value = UE4.UNRCStatics.GetConsoleVarBool("g.GCloseISMCSISByEnterQueue")
  if value then
    return "ISM\229\144\136\230\137\185(\229\133\179\233\151\173)"
  else
    return "ISM\229\144\136\230\137\185(\229\188\128\229\144\175)"
  end
end

local function GetHISMCollapseStatus()
  local value = UE4.UNRCStatics.GetConsoleVarBool("g.GHISMCollapse")
  if value then
    return "HISM\229\161\140\233\153\183(\229\188\128\229\144\175)"
  else
    return "HISM\229\161\140\233\153\183(\229\133\179\233\151\173)"
  end
end

function DebugTabPerfInstancing:SetupTabs()
  self:Add(GetCSISStatus(), self.CSIS, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetISMStatus(), self.ToggleISM, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
  self:Add(GetHISMCollapseStatus(), self.HISMCollapse, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "")
end

function DebugTabPerfInstancing:HISMCollapse(name, panel)
  local value = UE4.UNRCStatics.GetConsoleVarBool("g.GHISMCollapse")
  if value then
    UE4.UNRCStatics.ExecConsoleCommand("g.GHISMCollapse 0")
  else
    UE4.UNRCStatics.ExecConsoleCommand("g.GHISMCollapse 1")
  end
end

function DebugTabPerfInstancing:ToggleISM(name, panel)
  local value = UE4.UNRCStatics.GetConsoleVarBool("g.GCloseISMCSISByEnterQueue")
  if value then
    UE4.UNRCStatics.ExecConsoleCommand("g.GCloseISMCSISByEnterQueue 0")
  else
    UE4.UNRCStatics.ExecConsoleCommand("g.GCloseISMCSISByEnterQueue 1")
  end
end

function DebugTabPerfInstancing:CSIS(name, panel)
  local value = UE4.UNRCStatics.GetConsoleVarBool("g.GCloseInstanceByEnterQueue")
  if value then
    UE4.UNRCStatics.ExecConsoleCommand("g.GCloseInstanceByEnterQueue 0")
  else
    UE4.UNRCStatics.ExecConsoleCommand("g.GCloseInstanceByEnterQueue 1")
  end
end

return DebugTabPerfInstancing
