require("UnLuaEx")
local UMG_Battle_Skill_Tips_C = NRCUmgClass:Extend("")

function UMG_Battle_Skill_Tips_C:Construct()
  self._clickClose = false
  self.HotArea:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.HotArea.OnClicked:Add(self, self.OnHotAreaClick)
end

function UMG_Battle_Skill_Tips_C:Destruct()
  self.HotArea.OnClicked:Remove(self, self.OnHotAreaClick)
  NRCUmgClass.Destruct(self)
end

function UMG_Battle_Skill_Tips_C:OnHotAreaClick()
  if self._clickClose then
    self:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_Battle_Skill_Tips_C:SetClickClose(bClickClose)
  self._clickClose = bClickClose
  if bClickClose then
    self.HotArea:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.HotArea:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_Battle_Skill_Tips_C:UpdateInfo(skillData)
  local skillConf = _G.DataConfigManager:GetSkillConf(skillData.skill_id)
  self.SkillIcon:SetPath(skillConf.icon)
  self.TxtSkillName:SetText(skillConf.name)
  self.Desc:SetText(skillConf.desc)
  self.TipsInfo:UpdateInfo(skillData)
  self:PlayAnimation(self.TweenIn, 0, 1)
end

return UMG_Battle_Skill_Tips_C
