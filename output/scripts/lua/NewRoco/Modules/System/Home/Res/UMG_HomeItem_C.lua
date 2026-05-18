local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local HomeEnum = require("NewRoco.Modules.System.Home.HomeEnum")
local UMG_HomeItem_C = Base:Extend("UMG_HomeItem_C")
local FurnitureView = require("NewRoco/Modules/System/Home/Res/Helpers/FurnitureView")

function UMG_HomeItem_C:OnConstruct()
end

function UMG_HomeItem_C:OnDestruct()
end

function UMG_HomeItem_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.dataList = datalist
  self.FurnitureView = FurnitureView()
  self.FurnitureView:BindComfortValueView(self.ItemNum_1 or self.ItemNum_3)
  self.FurnitureView:BindIconView(self.ItemImage or self.ItemImage_1)
  self.FurnitureView:BindXNumView(self.ItemNum)
  self.FurnitureView:BindQualityColorView(self.QualityColor)
  self.FurnitureView:BindQualityColorBgIcon(self.SelectBGColor)
  self.FurnitureView:SetFurnitureData(_data)
  local bUsing = false
  if _data.InteriorFinishConf then
    local Room = HomeIndoorSandbox.Server.WorldData:GetRoomData(HomeIndoorSandbox.HomeEditServ.EditRoomId)
    if Room then
      local DecoData = Room:GetDecoDataById(_data.InteriorFinishConf.id)
      if DecoData then
        bUsing = true
      end
    end
  end
  if self.Current then
    if bUsing then
      self.Current:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Current:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
end

function UMG_HomeItem_C:OnItemSelected(_bSelected)
  if _bSelected then
    HomeIndoorSandbox.Module:ApplyFurnitureData(self.data)
  end
end

function UMG_HomeItem_C:SelectAnimation()
  self:StopAllAnimations()
  self:PlayAnimationForward(self.Select)
end

function UMG_HomeItem_C:UnSelectAnimation()
  self:StopAllAnimations()
  self:PlayAnimationForward(self.Normal)
end

return UMG_HomeItem_C
