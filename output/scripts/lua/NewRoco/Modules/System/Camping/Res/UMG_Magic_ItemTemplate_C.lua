local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Magic_ItemTemplate_C = Base:Extend("UMG_Magic_ItemTemplate_C")

function UMG_Magic_ItemTemplate_C:OnConstruct()
end

function UMG_Magic_ItemTemplate_C:OnDestruct()
end

function UMG_Magic_ItemTemplate_C:OnItemUpdate(_data, datalist, _index)
  self.index = _index
  self.uiData = _data
  self:SetData()
end

function UMG_Magic_ItemTemplate_C:OnDeactive()
end

function UMG_Magic_ItemTemplate_C:SetData()
  local PropIcon, Quality = self:GetPet3DIconPath(self.uiData.cfg.id)
  self.ItemIcon:SetPath(PropIcon)
  self:SetQuality(Quality)
  self.Chain:SetVisibility(self.uiData.hasLink == false and UE4.ESlateVisibility.Hidden or UE4.ESlateVisibility.Visible)
end

function UMG_Magic_ItemTemplate_C:GetPet3DIconPath(id)
  local itemConf
  local propIconPath = ""
  local quality = 0
  itemConf = _G.DataConfigManager:GetPetbaseConf(id, true)
  if not itemConf then
    local PetConf = _G.DataConfigManager:GetPetConf(id, true)
    if not PetConf then
      Log.Error("PET_CONF\229\146\140PETBASE_CONF\228\184\173\233\131\189\230\137\190\228\184\141\229\136\176\232\191\153\228\184\170ID", id)
    end
    itemConf = _G.DataConfigManager:GetPetbaseConf(PetConf and PetConf.base_id or 0, true)
  end
  if itemConf then
    local model = _G.DataConfigManager:GetModelConf(itemConf.model_conf)
    propIconPath = model.icon
    if itemConf.quality == Enum.PetQuality.PQ_PURPLE then
      quality = 4
    elseif itemConf.quality == Enum.PetQuality.PQ_ORANGE then
      quality = 5
    else
      quality = 3
    end
  end
  return propIconPath, quality
end

function UMG_Magic_ItemTemplate_C:SetQuality(quality)
  self.BGColor:SetVisibility(0 == quality and UE4.ESlateVisibility.Hidden or UE4.ESlateVisibility.Visible)
  if 0 == quality then
    self.BGColor:SetVisibility(UE4.ESlateVisibility.Hidden)
  elseif 1 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_1)
  elseif 2 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_2)
  elseif 3 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_3)
  elseif 4 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_4)
  elseif 5 == quality then
    self.BGColor:SetPath(UEPath.PROP_QUALITY_5)
  end
end

function UMG_Magic_ItemTemplate_C:OnItemSelected(_bSelected)
  if _bSelected then
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(1003, "UMG_Magic_ItemTemplate_C:OnItemSelected")
    local bAcquired = self:PetHasAcquired(self.uiData.cfg.id)
    local param = {
      petbaseId = self.uiData.cfg.id,
      needBlur = true,
      notAcquired = not bAcquired,
      isSketch = false,
      insufficientLv = false
    }
    _G.NRCModeManager:DoCmd(TipsModuleCmd.Tips_OpenMagicDetailTips, param)
  end
end

function UMG_Magic_ItemTemplate_C:PetHasAcquired(petbaseId)
  local PlayerPetInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo()
  local handBookInfo = PlayerPetInfo.handbook.record_collection
  for i = 1, #handBookInfo do
    if not handBookInfo[i].record or 0 == #handBookInfo[i].record then
    else
      local record = handBookInfo[i].record[1]
      if record.pet_base_id == petbaseId and record.status and record.status > 1 then
        return true
      end
    end
  end
  return false
end

return UMG_Magic_ItemTemplate_C
