local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local HandbookModuleEvent = reload("NewRoco.Modules.System.Handbook.HandbookModuleEvent")
local UMG_Cover_Item_C = Base:Extend("UMG_Cover_Item_C")

function UMG_Cover_Item_C:OnConstruct()
end

function UMG_Cover_Item_C:OnDestruct()
end

function UMG_Cover_Item_C:GetIconPath(petId)
  local IconName = string.format("%s.%s", petId, petId)
  return string.format("Texture2D'/Game/NewRoco/Modules/System/Common/Icon/HeadIcon/%s'", IconName)
end

function UMG_Cover_Item_C:InitRedData()
  local redId = _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.OnCmdGetCurAreaHandBookRedId, 1, 1)
  self.Dot:SetupKey(redId, {
    self.data.HandbookId
  })
end

function UMG_Cover_Item_C:ShowCoverItem(info, angle, parent)
  self.data = info
  self.parent = parent
  self:InitRedData()
  self.ElfIcon:SetVisibility(UE4.ESlateVisibility.Visible)
  local path = NRCUtils:FormatConfIconPath(info.IconPath, _G.UIIconPath.HeadIconPath)
  self.ElfIcon:SetPathWithCallBack(path, {
    self,
    self.IconLoaded
  })
  if UE4.UKismetSystemLibrary.IsValid(self.Button) then
    self.Button.OnClicked:Add(self, self.OnClickBtn)
  end
  local formattedNumber = string.format("%03d", info.HandbookId)
  self.SerialNumber:SetText(formattedNumber)
  self.Lihe:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.CanvasPanel_1:SetRenderTransformAngle(angle)
end

function UMG_Cover_Item_C:IconLoaded()
  if UE4.UObject.IsValid(self.Bg_1) then
    self.Bg_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_Cover_Item_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  if self.data.State == _G.ProtoEnum.PetHandbookStatus.PHS_COLLECTED then
    self.BlackMask:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.ElfIcon:SetVisibility(UE4.ESlateVisibility.Visible)
  elseif self.data.State == _G.ProtoEnum.PetHandbookStatus.PHS_FOUND then
    self.BlackMask:SetVisibility(UE4.ESlateVisibility.Visible)
    self.ElfIcon:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.BlackMask:SetVisibility(UE4.ESlateVisibility.Visible)
    self.ElfIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
  self.ElfIcon:SetVisibility(UE4.ESlateVisibility.Visible)
  self.ElfIcon:SetPathWithCallBack(NRCUtils:FormatConfIconPath(self.data.IconPath, _G.UIIconPath.HeadIconPath), {
    self,
    self.IconLoaded
  })
  if UE4.UKismetSystemLibrary.IsValid(self.Button) then
    self.Button.OnClicked:Add(self, self.OnClickBtn)
  end
  self.SerialNumber:SetText(self.data.HandbookId)
end

function UMG_Cover_Item_C:OnClickBtn()
  if UE4.UObject.IsValid(self.parent) and self.parent:IsAnimationPlaying(self.parent.Book_Open) then
    return
  end
  _G.NRCModuleManager:DoCmd(HandbookModuleCmd.OnOpenContentView, self.data.HandbookId, self.data.PetBaseId, true)
end

function UMG_Cover_Item_C:OnItemSelected(_bSelected)
end

return UMG_Cover_Item_C
