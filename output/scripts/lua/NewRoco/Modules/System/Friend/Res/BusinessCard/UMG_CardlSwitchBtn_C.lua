local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local FriendModuleEvent = require("NewRoco.Modules.System.Friend.FriendModuleEvent")
local UMG_CardlSwitchBtn_C = Base:Extend("UMG_CardlSwitchBtn_C")
local AnimStateEnum = {
  None = 0,
  Normal = 1,
  Press = 2
}

function UMG_CardlSwitchBtn_C:OnConstruct()
  self.Button.OnClicked:Add(self, self.OnButtonClicked)
  self.AnimState = AnimStateEnum.None
end

function UMG_CardlSwitchBtn_C:OnDestruct()
end

function UMG_CardlSwitchBtn_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self.module = _G.NRCModuleManager:GetModule("FriendModule")
  self.moduleData = self.module:GetData("FriendModuleData")
  self:InitInfo()
end

function UMG_CardlSwitchBtn_C:InitInfo()
  if not self.data or not self.data.ComponentType then
    return
  end
  if self.data.ComponentType == _G.ProtoEnum.RoleCardModuleType.RCMT_FAVOURITE_PET then
    self.Icon:SetPath("Texture2D'/Game/NewRoco/Modules/System/Friend/Raw/BusinessCard/Frames/img_BtnIcon1_png.img_BtnIcon1_png'")
  elseif self.data.ComponentType == _G.ProtoEnum.RoleCardModuleType.RCMT_BADGE then
    self.Icon:SetPath("Texture2D'/Game/NewRoco/Modules/System/Friend/Raw/BusinessCard/Frames/img_BtnIcon2_png.img_BtnIcon2_png'")
  end
  local curType = self.moduleData:GetCurCardComponentType()
  if curType == self.data.ComponentType then
    if self.AnimState ~= AnimStateEnum.Press then
      self.AnimState = AnimStateEnum.Press
      self:PlayAnimation(self.Press)
    end
  elseif self.AnimState ~= AnimStateEnum.Normal then
    self.AnimState = AnimStateEnum.Normal
    self:PlayAnimation(self.Normal)
  end
end

function UMG_CardlSwitchBtn_C:OnButtonClicked()
  if not self.data or not self.data.ComponentType then
    return
  end
  if self.moduleData:GetCurCardComponentType() == self.data.ComponentType then
    return
  end
  _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_StudentCard_C:SelectCardMenu")
  self.moduleData:SetCurCardComponentType(self.data.ComponentType)
  self.module:DispatchEvent(FriendModuleEvent.UpdateCardComponentEdit)
end

return UMG_CardlSwitchBtn_C
