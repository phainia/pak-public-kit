local CompassUIData = require("NewRoco.Modules.System.MainUI.Res.compass.CompassUIData")
local Base = CompassUIData
local PetSenseCompassUIData = Base:Extend("PetSenseCompassUIData")

function PetSenseCompassUIData:InitData(Info, IconPath, ViewField, SceneTarget)
  Base.InitData(self, Info, nil, ViewField)
  self.TaskAngleLimit = ViewField
  self.PetSensePath = IconPath
  self.SceneTarget = SceneTarget
  self.PetSenseTime = _G.DataConfigManager:GetGlobalConfig("ganzhi_small_icon_time").num
  self:SetIsBig(true)
  self:OpenPetSense()
end

function PetSenseCompassUIData:UpdateData(Info, IconPath)
  self:SetPos(Info.Position)
  self.PetSensePath = IconPath
  self:SetIcon()
  self.PetSenseTime = _G.DataConfigManager:GetGlobalConfig("ganzhi_small_icon_time").num
  if self.CurState ~= CompassUIData.MapAreaState.PET_SENSE then
    self:OpenPetSense()
  end
end

function PetSenseCompassUIData:SetIcon()
  if self.CompWidget then
    self.CompWidget:SetIcon(self.PetSensePath)
  end
end

function PetSenseCompassUIData:ClosePetSense()
  Base.ClosePetSense(self)
  self.SceneTarget = nil
end

return PetSenseCompassUIData
