local LevelSelectionModuleEvent = require("NewRoco.Modules.System.LevelSelection.LevelSelectionModuleEvent")
local UMG_LeaderTrait_Tips_C = _G.NRCPanelBase:Extend("UMG_LeaderTrait_Tips_C")

function UMG_LeaderTrait_Tips_C:OnActive(ruleId, petbaseId, titleStr)
  local ruleConf = _G.DataConfigManager:GetBattleRuleConf(ruleId)
  if titleStr then
    self.Text_GoodAndBad:SetText(titleStr)
  end
  if ruleConf then
    if petbaseId then
      local moduleId = _G.DataConfigManager:GetPetbaseConf(petbaseId).model_conf
      local iconPath = _G.DataConfigManager:GetModelConf(moduleId).icon
      self.Pet:SetPath(iconPath)
    end
    self.Title:SetText(ruleConf.title)
    self.textBuffDesc:SetText(ruleConf.desc)
  end
  self:LoadAnimation(0)
end

function UMG_LeaderTrait_Tips_C:OnDeactive()
end

function UMG_LeaderTrait_Tips_C:OnAddEventListener()
  self:AddButtonListener(self.HotArea, self.OnClickHotArea)
end

function UMG_LeaderTrait_Tips_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_LeaderTrait_Tips_C:OnDestruct()
end

function UMG_LeaderTrait_Tips_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DispatchEvent(LevelSelectionModuleEvent.LeaderTraitCloseUpdate)
    self:DoClose()
  end
end

function UMG_LeaderTrait_Tips_C:OnClickHotArea()
  self:LoadAnimation(2)
end

return UMG_LeaderTrait_Tips_C
