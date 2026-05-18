local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local UMG_Difficulty_C = _G.NRCPanelBase:Extend("UMG_Difficulty_C")

function UMG_Difficulty_C:OnConstruct()
end

function UMG_Difficulty_C:OnDestruct()
end

function UMG_Difficulty_C:OnActive()
end

function UMG_Difficulty_C:OnDeactive()
end

function UMG_Difficulty_C:SetCatchHardLv(session, targetNPC)
  if session.itemData then
    local catchRate, petBaseID = SceneUtils.GetCatchRate(session, targetNPC)
    self:ShowCatchHardLv(catchRate)
  end
end

function UMG_Difficulty_C:ShowCatchHardLv(catchRate)
  Log.Debug("UMG_Hud_Pet_C:ShowCatchHardLv", catchRate)
  local catchLow = _G.DataConfigManager:GetBattleGlobalConfig("catch_pr_low").numList
  local catchMiddle = _G.DataConfigManager:GetBattleGlobalConfig("catch_pr_middle").numList
  local catchHigh = _G.DataConfigManager:GetBattleGlobalConfig("catch_pr_high").numList
  local catchFull = _G.DataConfigManager:GetBattleGlobalConfig("catch_pr_full").numList
  local hardLevel = {
    0,
    0,
    0
  }
  if catchRate < catchLow[2] / 10000.0 and catchRate >= catchLow[1] / 10000.0 then
    hardLevel = {
      0,
      0,
      0
    }
  elseif catchRate < catchMiddle[2] / 10000.0 and catchRate > catchMiddle[1] / 10000.0 then
    hardLevel = {
      0,
      0,
      1
    }
  elseif catchRate < catchHigh[2] / 10000.0 and catchRate > catchHigh[1] / 10000.0 then
    hardLevel = {
      0,
      1,
      1
    }
  elseif catchRate <= catchFull[2] / 10000.0 and catchRate >= catchFull[1] / 10000.0 then
    hardLevel = {
      1,
      1,
      1
    }
  else
    hardLevel = {
      0,
      0,
      0
    }
  end
  self.CatchHardLv:InitGridView(hardLevel)
end

function UMG_Difficulty_C:PlayOpenAnim()
  _G.NRCProfilerLog:NRCPanelOpenAnimation(true, self.panelName)
  self:PlayAnimation(self.open)
end

function UMG_Difficulty_C:OnAnimationFinished(anim)
  if anim == self.open then
    _G.NRCProfilerLog:NRCPanelOpenAnimation(false, self.panelName)
    self:PlayAnimation(self.loop_lv2, 0.0, 0)
  end
end

return UMG_Difficulty_C
