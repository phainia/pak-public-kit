local UMG_BattleBuff_Tips_C = _G.NRCPanelBase:Extend("UMG_BattleBuff_Tips_C")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")

function UMG_BattleBuff_Tips_C:OnConstruct()
  self:AddButtonListener(self.HotArea, self.OnClose)
end

function UMG_BattleBuff_Tips_C:OnDestruct()
end

function UMG_BattleBuff_Tips_C:OnActive(buffId, battlePet)
  local buffConf = _G.DataConfigManager:GetBattleRuleConf(buffId)
  self.SkillIcon:SetPath(buffConf.icon)
  self.Title:SetText(buffConf.title)
  self.textBuffDesc:SetText(buffConf.desc)
  local petImgPath = ""
  if battlePet then
    if battlePet.teamEnm == BattleEnum.Team.ENUM_ENEMY then
      self.Text_GoodAndBad:SetText(_G.LuaText.challenge_text_22)
    else
      self.Text_GoodAndBad:SetText(_G.LuaText.challenge_text_23)
    end
    local petBaseConf = battlePet.card and battlePet.card.petBaseConf
    if petBaseConf then
      local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
      petImgPath = modelConf and modelConf.icon
    end
  end
  self.Pet:SetPath(petImgPath or "")
end

return UMG_BattleBuff_Tips_C
