local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_GradePointItem_C = Base:Extend("UMG_GradePointItem_C")

function UMG_GradePointItem_C:OnConstruct()
end

function UMG_GradePointItem_C:OnDestruct()
end

function UMG_GradePointItem_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.index = index
  self:SetInfo()
end

function UMG_GradePointItem_C:SetInfo()
  local _data = self.uiData
  local iconPath = ""
  if _data.itemType == _G.Enum.GoodsType.GT_VITEM then
    local vItemConf = _G.DataConfigManager:GetVisualItemConf(_data.itemId)
    if nil ~= vItemConf then
      self.visualItemId = vItemConf.id
      self:SetQuality(vItemConf.item_quality)
      iconPath = vItemConf.bigIcon
    end
  elseif _data.itemType == _G.Enum.GoodsType.GT_BAGITEM then
    local bagItemConf = _G.DataConfigManager:GetBagItemConf(_data.itemId)
    if nil ~= bagItemConf then
      self:SetQuality(bagItemConf.item_quality)
      if bagItemConf.big_icon then
        iconPath = bagItemConf.big_icon
      else
        iconPath = bagItemConf.icon
      end
    end
  elseif _data.itemType == _G.Enum.GoodsType.GT_PET then
    local petInfo = _G.DataConfigManager:GetPetConf(_data.itemId)
    local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petInfo.base_id)
    if nil ~= petBaseConf then
      local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
      iconPath = modelConf.icon
    end
  elseif _data.itemType == _G.Enum.GoodsType.GT_CARD_SKIN then
    local cardSkinConf = _G.DataConfigManager:GetCardSkinConf(_data.itemId)
    if cardSkinConf then
      self:SetQuality(cardSkinConf.card_quality)
      iconPath = string.format(UEPath.CARD_SKIN_PATH, cardSkinConf.skin_resource_path, cardSkinConf.skin_resource_path)
    end
  end
  if 1 == self.index then
    self.SuitName:SetText("\228\186\140\231\173\137\229\165\150")
  elseif 2 == self.index then
    self.SuitName:SetText("\231\165\158\231\167\152\229\164\167\229\165\150")
  elseif 3 == self.index then
    self.SuitName:SetText("\228\184\137\231\173\137\229\165\150")
  end
  if self.uiData.gpContestState == ProtoEnum.PlayerGPContestInfo.GPContestState.GPCS_REWARD and 2 == self.index then
    self:PlayAnimation(self.ReceiveAward2)
    self.hasRewardCollect = true
  end
  self.Icon:SetPath(iconPath)
  self.Icon:SetBrushSize(UE4.FVector2D(256, 256))
end

function UMG_GradePointItem_C:SetQuality(quality)
  if 0 == quality then
  elseif 1 == quality then
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_1))
  elseif 2 == quality then
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_2))
  elseif 3 == quality then
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_3))
  elseif 4 == quality then
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_4))
  elseif 5 == quality then
    self.Color:SetColorAndOpacity(UE4.UNRCStatics.HexToLinearColor(UEPath.Color_QUALITY_5))
  end
end

function UMG_GradePointItem_C:OnItemSelected(_bSelected)
  if _bSelected and self.hasRewardCollect then
    local req = _G.ProtoMessage:newZoneReceiveGpContestRewardReq()
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_RECEIVE_GP_CONTEST_REWARD_REQ, req, self, self.ReceiveGPContestRewardRsp, false, false)
  end
end

function UMG_GradePointItem_C:ReceiveGPContestRewardRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    self.hasRewardCollect = false
    self.Claimable:SetVisibility(UE4.ESlateVisibility.Collapsed)
    _G.NRCModuleManager:DoCmd(BagModuleCmd.ShowGradePointLabel_1)
  else
    Log.Error("\233\162\134\229\143\150\231\187\169\231\130\185\229\164\167\232\181\155\229\165\150\229\138\177\229\164\177\232\180\165\228\186\134\239\188\129\239\188\129\239\188\129")
  end
end

function UMG_GradePointItem_C:OnDeactive()
end

return UMG_GradePointItem_C
