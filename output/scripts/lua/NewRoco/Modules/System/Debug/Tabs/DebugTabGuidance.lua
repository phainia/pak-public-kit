local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local Base = DebugTabBase
local DebugTabGuidance = Base:Extend("DebugTabGuidance")

function DebugTabGuidance:Ctor()
  Base.Ctor(self)
end

function DebugTabGuidance:SwitchDebug()
  local state = _G.NRCModuleManager:DoCmd(_G.GuidanceModuleCmd.GetDebugEnabled)
  state = not state
  _G.NRCModuleManager:DoCmd(_G.GuidanceModuleCmd.SetDebugEnabled, state)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, string.format("\229\188\149\229\175\188\230\152\175\229\144\166\229\188\128\229\144\175\232\176\131\232\175\149\239\188\154%s", tostring(state)), 1, nil, 5)
end

function DebugTabGuidance:OpenGuideSet()
  _G.NRCModuleManager:DoCmd(_G.GuidanceModuleCmd.ResetAllGuide)
end

function DebugTabGuidance:CloseGuideSet()
  _G.NRCModuleManager:DoCmd(_G.GuidanceModuleCmd.CompleteAllGuide)
end

function DebugTabGuidance:OpenGuideGP()
  local group_id = self:GetInputNumber(-1)
  _G.NRCModuleManager:DoCmd(_G.GuidanceModuleCmd.StartGuideGroup, group_id)
end

function DebugTabGuidance:OpenGuide()
  local inputText = self:GetInputString()
  if not inputText then
    return
  end
  local inputNumbers = string.split(inputText, ",")
  if not inputNumbers or #inputNumbers < 2 then
    return
  end
  local group_id = tonumber(inputNumbers[1])
  local sub_id = tonumber(inputNumbers[2])
  if not group_id or not sub_id then
    return
  end
  _G.NRCModuleManager:DoCmd(_G.GuidanceModuleCmd.StartSubGuide, group_id, sub_id)
end

function DebugTabGuidance:FinCurGuideGP()
  _G.NRCModuleManager:DoCmd(_G.GuidanceModuleCmd.FinishCurrentGuideGroup)
end

function DebugTabGuidance:FinCurGuide()
  _G.NRCModuleManager:DoCmd(_G.GuidanceModuleCmd.FinishCurrentSubGuide)
end

function DebugTabGuidance:ClearGuideGP()
  local group_id = self:GetInputNumber(-1)
  _G.NRCModuleManager:DoCmd(_G.GuidanceModuleCmd.ClearGuideGroup, group_id)
end

function DebugTabGuidance:ClearGuide()
  local inputText = self:GetInputString()
  if not inputText then
    return
  end
  local inputNumbers = string.split(inputText, ",")
  if not inputNumbers or #inputNumbers < 2 then
    return
  end
  local group_id = tonumber(inputNumbers[1])
  local sub_id = tonumber(inputNumbers[2])
  if not group_id or not sub_id then
    return
  end
  _G.NRCModuleManager:DoCmd(_G.GuidanceModuleCmd.ClearSubGuide, group_id, sub_id)
end

function DebugTabGuidance:OpenServerCheck()
  _G.NRCModuleManager:DoCmd(_G.GuidanceModuleCmd.SetShouldSkipServer, false)
end

function DebugTabGuidance:CloseServerCheck()
  _G.NRCModuleManager:DoCmd(_G.GuidanceModuleCmd.SetShouldSkipServer, true)
end

return DebugTabGuidance
