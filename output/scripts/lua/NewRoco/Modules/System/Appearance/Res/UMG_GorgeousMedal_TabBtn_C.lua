local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_GorgeousMedal_TabBtn_C = Base:Extend("UMG_GorgeousMedal_TabBtn_C")

function UMG_GorgeousMedal_TabBtn_C:OnConstruct()
end

function UMG_GorgeousMedal_TabBtn_C:OnDestruct()
end

function UMG_GorgeousMedal_TabBtn_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.bSelected = false
  local conf = _G.DataConfigManager:GetBondTabConf(_data)
  if conf then
    self.Suit_Selected:SetPath(conf.icon)
    local str = conf.icon
    local newStr, count = string.gsub(str, "normal", "selected")
    self.Suit_Ordinary:SetPath(newStr)
  end
  self.RedDot:SetupKey(410, _data)
end

function UMG_GorgeousMedal_TabBtn_C:OnTouchEnded(MyGeometry, InTouchEvent)
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_GorgeousMedal_TabBtn_C:OnTouchEnded")
  Base.OnTouchEnded(self, MyGeometry, InTouchEvent)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end

function UMG_GorgeousMedal_TabBtn_C:OnItemSelected(_bSelected)
  self.bSelected = _bSelected
  self:StopAllAnimations()
  if _bSelected then
    self:PlayAnimation(self.Btn_Suit_A)
    _G.NRCModuleManager:DoCmd(AppearanceModuleCmd.OnBondTabSelected, self.uiData)
    _G.NRCModuleManager:DoCmd(AppearanceModuleCmd.OnCmdZoneSetFashionBondLastTabReq, self.uiData)
  else
    self:PlayAnimation(self.Btn_Suit_A_Out)
  end
end

function UMG_GorgeousMedal_TabBtn_C:OnDeactive()
end

function UMG_GorgeousMedal_TabBtn_C:OnAnimationFinished(Anim)
  if self.bSelected and (Anim == self.Btn_loop or Anim == self.Btn_Suit_A) then
    self:PlayAnimation(self.Btn_loop)
  end
end

return UMG_GorgeousMedal_TabBtn_C
