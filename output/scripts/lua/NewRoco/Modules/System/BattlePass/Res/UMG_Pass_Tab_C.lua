local BattlePassModuleEvent = reload("NewRoco.Modules.System.BattlePass.BattlePassModuleEvent")
local UMG_Pass_Tab_C = _G.NRCViewBase:Extend("UMG_Pass_Tab_C")

function UMG_Pass_Tab_C:OnConstruct()
  _G.NRCEventCenter:RegisterEvent("BattlePassModule", self, BattlePassModuleEvent.UpdatePetTableView, self.UpdateTable)
end

function UMG_Pass_Tab_C:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, BattlePassModuleEvent.UpdatePetTableView, self.UpdateTable)
end

function UMG_Pass_Tab_C:OnActive(index)
  self.FirstSelect = true
  local propertyIconDefaultPath = "PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_icon_Attributes_png.img_icon_Attributes_png'"
  local propertyIconSelectPath = "PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_icon_Attributes_png.img_icon_Attributes_png'"
  local skillIconDefaultPath = "PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_icon_Skill_png.img_icon_Skill_png'"
  local skillIconSelectPath = "PaperSprite'/Game/NewRoco/Modules/System/CommonBtn/Raw/Frames/img_icon_Skill_png.img_icon_Skill_png'"
  self.tabIndex = index
  self.bChoose = false
  if 0 == index then
    self.Select:SetPath(propertyIconSelectPath)
    self.Default:SetPath(propertyIconDefaultPath)
  elseif 1 == index then
    self.Select:SetPath(skillIconSelectPath)
    self.Default:SetPath(skillIconDefaultPath)
  end
  self:OnAddEventListener()
end

function UMG_Pass_Tab_C:OnAddEventListener()
  self:AddButtonListener(self.Button, self.OnClickButton)
end

function UMG_Pass_Tab_C:UpdateTable(index)
  if not self.FirstSelect then
    _G.NRCAudioManager:PlaySound2DAuto(40002003, "UMG_Pass_Tab_C:UpdateTable")
  else
    self.FirstSelect = false
  end
  self:StopAllAnimations()
  if index == self.tabIndex then
    self:PlayAnimation(self.In)
    self.Select:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Default:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.bChoose = true
  else
    self:PlayAnimation(self.Out)
    self.Select:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Default:SetVisibility(UE4.ESlateVisibility.Visible)
    self.bChoose = false
  end
end

function UMG_Pass_Tab_C:OnClickButton()
  if self.bChoose then
    return
  end
  _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.SetPetSelectTabIndex, self.tabIndex)
  _G.NRCEventCenter:DispatchEvent(BattlePassModuleEvent.UpdatePetTableView, self.tabIndex)
end

return UMG_Pass_Tab_C
