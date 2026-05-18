local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local PetUIModuleEvent = require("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local UMG_FormIntoColumns_List_C = Base:Extend("UMG_FormIntoColumns_List_C")

function UMG_FormIntoColumns_List_C:Initialize(Initializer)
end

function UMG_FormIntoColumns_List_C:OnConstruct()
end

function UMG_FormIntoColumns_List_C:OnItemUpdate(_data, datalist, index)
  self.index = index
  self.uiData = _data
  self.IsOnClickMainImage = false
  self:UpdateMainTeam()
  self:SetShowInfo()
  self:UpdateButton()
  self:SetRenderOpacity()
  self:SetData()
  self:OnAddEventListener()
end

function UMG_FormIntoColumns_List_C:OnAddEventListener()
  self.Button_1.OnClicked:Add(self, self.OnButton_1)
end

function UMG_FormIntoColumns_List_C:UpdateButton()
  if self.uiData.IsCanExchangePet then
  else
    self.Button_1:SetVisibility(UE4.ESlateVisibility.Visible)
    self.MaskIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_FormIntoColumns_List_C:UpdateMainTeam()
  local petdata = self.uiData
  if petdata.main_team_idx then
    self.Btn_1:SetActiveWidgetIndex(1)
  else
    self.Btn_1:SetActiveWidgetIndex(0)
  end
end

function UMG_FormIntoColumns_List_C:OnButton_1()
  self.isPlayAuto = false
  if self._data[self.index].pet_gid then
    _G.NRCModuleManager:DoCmd(MainUIModuleCmd.OnClickMainTeamBtn, self._index)
    if false == self.IsOnClickMainImage then
      self.IsOnClickMainImage = true
      self:SetMainImage(true)
      self:SetSelect(true)
    else
      self.IsOnClickMainImage = false
      self:SetMainImage(false)
      self:SetSelect(false)
    end
  end
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1223, "UMG_FormIntoColumns_List_C:chuzhan")
end

function UMG_FormIntoColumns_List_C:SetData()
  local petdata = self.uiData
  if petdata then
    local PetInfoList = {}
    if 0 == petdata.PetFormIndex then
      self:PlayAnimation(self.close)
    end
    self.Icon_3:SetPath(petdata.icon)
    self.Icon_1:SetPath(petdata.icon1)
    for i = 1, 6 do
      if petdata then
        if petdata.pet_gid then
          if petdata.pet_gid[i] then
            local petinfo = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(petdata.pet_gid[i])
            local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petinfo.base_conf_id)
            if petBaseConf then
              local modelConf = _G.DataConfigManager:GetModelConf(petBaseConf.model_conf)
              table.insert(PetInfoList, {
                IconListInfo = petinfo.level,
                gid = petinfo.gid,
                energy = petinfo.energy,
                PetIcon = modelConf,
                IsHasPet = true,
                IsOnClick = petdata.IsOnClick,
                EnableChange = self.IsShow
              })
            end
          else
            table.insert(PetInfoList, {
              IsHasPet = false,
              IsOnClick = petdata.IsOnClick,
              EnableChange = self.IsShow
            })
          end
        else
          table.insert(PetInfoList, {
            IsHasPet = false,
            IsOnClick = petdata.IsOnClick,
            EnableChange = self.IsShow
          })
        end
      end
    end
    self.List:InitGridView(PetInfoList)
  end
end

function UMG_FormIntoColumns_List_C:SetRenderOpacity()
  if self.uiData.IsCanExchangePet then
  elseif self.uiData.main_team_idx then
    self:SetRenderOpacityInfo(1)
    self.IsShow = true
  else
    self:SetRenderOpacityInfo(0.5)
    self.IsShow = false
  end
end

function UMG_FormIntoColumns_List_C:SetRenderOpacityInfo(_Data)
  self.Line:SetRenderOpacity(_Data)
  self.CanvasPanel_1:SetRenderOpacity(_Data)
  self.CanvasPanel_123:SetRenderOpacity(_Data)
end

function UMG_FormIntoColumns_List_C:SetShowInfo()
  self.CanvasPanel_1:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.Icon_3:SetVisibility(UE4.ESlateVisibility.Visible)
  self.Icon_1:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.Icon_2:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.Flow_1:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.Image_207:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.MaskIcon:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_FormIntoColumns_List_C:OnDestruct()
end

function UMG_FormIntoColumns_List_C:OnActive()
end

function UMG_FormIntoColumns_List_C:SetMainImage(_flag)
  if _flag then
    self.Btn_1:SetActiveWidgetIndex(1)
  else
    self.Btn_1:SetActiveWidgetIndex(0)
  end
end

function UMG_FormIntoColumns_List_C:SetSelect(_flag)
  if _flag then
    self:PlayAnimation(self.selecte)
    self.Image_207:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Icon_1:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Icon_2:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Flow_1:SetVisibility(UE4.ESlateVisibility.Visible)
  elseif self.uiData.IsCanExchangePet then
  end
end

function UMG_FormIntoColumns_List_C:OnItemSelected(_bSelected)
  local size_Y = self.CanvasPanel_123.Slot:GetPosition().Y + self.CanvasPanel_123.Slot:GetSize().Y
  if _bSelected then
    _G.NRCModuleManager:GetModule("MainUIModule"):DispatchEvent(PetUIModuleEvent.ChangePetMainIndex, self._index, size_Y)
    if self.isPlayAuto ~= false then
      UE4.UNRCAudioManager.Get():PlaySound2DAuto(1224, "UMG_FormIntoColumns_List_C:OnItemSelected")
    end
    self.isPlayAuto = true
  end
  self:SetSelect(_bSelected)
end

return UMG_FormIntoColumns_List_C
