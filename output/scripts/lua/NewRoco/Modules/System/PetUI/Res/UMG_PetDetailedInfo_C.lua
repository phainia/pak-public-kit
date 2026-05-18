local Enum = reload("Data.Config.Enum")
local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local PetUtils = require("NewRoco.Utils.PetUtils")
local UMG_PetDetailedInfo_C = _G.NRCPanelBase:Extend("UMG_PetDetailedInfo_C")

function UMG_PetDetailedInfo_C:Initialize(Initializer)
end

function UMG_PetDetailedInfo_C:OnConstruct()
  Log.Debug("UMG_PetDetailedInfo_C:OnConstruct")
  self.uiData = {}
  self.TipsOpenIndex = 0
  self.TipsOpenType = 0
  self:OnAddEventListener()
  self:SetCommonTitle()
  self:PlayAnimation(self.Appear)
end

function UMG_PetDetailedInfo_C:OnActive(_param, ...)
  Log.Debug("UMG_PetDetailedInfo_C:OnActive")
  if _param then
    self.Title1:SetSubtitle(_param.name)
  end
  self:ShowInfo(_param)
  self:BindInputAction()
end

function UMG_PetDetailedInfo_C:SetCommonTitle()
  self.titleConf = _G.DataConfigManager:GetTitleConf(self:GetPanelName())
  self.Title1:Set_MainTitle(self.titleConf.title)
  self.Title1:SetBg(self.titleConf.head_icon)
  self.Title1:SetSubtitle(self.titleConf.subtitle[1].subtitle)
end

function UMG_PetDetailedInfo_C:SetPanelData(module, panelData)
  self.panelName = panelData.panelName
  self.panelData = panelData
  self.module = module
  self.enableLog = true
  Log.Debug("UMG_PetDetailedInfo_C:SetPanelData")
end

function UMG_PetDetailedInfo_C:OnDestruct()
  self:OnRemoveEventListener()
  self.uiData = nil
end

function UMG_PetDetailedInfo_C:OnEnable()
end

function UMG_PetDetailedInfo_C:OnDisable()
end

function UMG_PetDetailedInfo_C:OnAddEventListener()
  self:AddButtonListener(self.UMG_btnClose.btnClose, self.OnCloseButtonClicked)
  self:AddButtonListener(self.Button_Mask, self.OnCloseMaskClicked)
  self:AddButtonListener(self.MaskBtn, self.OnMaskBtn)
  self.ScrollBox_140.OnUserScrolled:Add(self, self.OnUserScrolledInfo)
  self.module:RegisterEvent(self, PetUIModuleEvent.AttrTipsOpenEvent, self.OnItemAttrTipsOpen)
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.OnPlayerDataUpdate)
end

function UMG_PetDetailedInfo_C:OnUserScrolledInfo(Offset)
end

function UMG_PetDetailedInfo_C:OnRemoveEventListener()
  self.ScrollBox_140.OnUserScrolled:Remove(self, self.OnUserScrolledInfo)
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.OnPlayerDataUpdate)
end

function UMG_PetDetailedInfo_C:OnPlayerDataUpdate()
  local petData = self.module:GetCurrPetData()
  petData = DataModelMgr.PlayerDataModel:GetPetDataByGid(petData.gid)
  self:ShowInfo(petData)
end

function UMG_PetDetailedInfo_C:OnCloseMaskClicked()
  self:SetOtherDetailMaskItemState(false, true)
end

function UMG_PetDetailedInfo_C:OnItemAttrTipsOpen(bOpen, index, _type)
  if bOpen then
    self.TipsOpenIndex = index
    self.TipsOpenType = _type
    if 5 == index or 6 == index then
      self.ScrollBox_140:SetScrollOffset(210)
    end
  else
    self.TipsOpenIndex = 0
    self.TipsOpenType = 0
  end
  self:SetOtherDetailMaskItemState(bOpen, false)
end

function UMG_PetDetailedInfo_C:SetOtherDetailMaskItemState(bOpen, IsFullBtn)
  if self.NRCGridViewBaseInfo then
    local num = self.NRCGridViewBaseInfo:GetItemCount()
    for i = 1, num do
      local item = self.NRCGridViewBaseInfo:GetItemByIndex(i - 1)
      if bOpen then
        if i ~= self.TipsOpenIndex then
          item.Btn_QuestionMark:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
          item.StriveLevelBtn:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        end
      else
        if IsFullBtn then
          item:SetOtherIndexMask(false, self.TipsOpenType, self.TipsOpenIndex)
        elseif i ~= self.TipsOpenIndex then
        end
        item.Btn_QuestionMark:SetVisibility(UE4.ESlateVisibility.Visible)
        item.StriveLevelBtn:SetVisibility(UE4.ESlateVisibility.Visible)
      end
    end
    if bOpen then
      self.NRCGridViewBaseInfo:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Button_Mask:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.Button_Mask:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.NRCGridViewBaseInfo:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  end
end

function UMG_PetDetailedInfo_C:ShowInfo(petdata)
  local datas = self:GetDataEx(petdata)
  if nil == datas then
    Log.Error("\229\174\160\231\137\169\230\149\176\230\141\174\230\156\137\233\151\174\233\162\152,\232\175\183\230\163\128\230\159\165\233\128\187\232\190\145")
  else
    self.NRCGridViewBaseInfo:InitGridView(datas[1])
    self:ShowDataItem(datas[2], self.NRCGridViewJinjie, self.CanvasPanelLineAdv)
    self:ShowDataItem(datas[3], self.NRCGridViewot, self.CanvasPanelLinewot)
  end
end

function UMG_PetDetailedInfo_C:ShowDataItem(listDatas, gridObj, titleObj)
  if 0 == #listDatas then
    titleObj:SetVisibility(UE4.ESlateVisibility.Collapsed)
    gridObj:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    gridObj:InitGridView(listDatas)
    titleObj:SetVisibility(UE4.ESlateVisibility.Visible)
    gridObj:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end

function UMG_PetDetailedInfo_C:GetData(petdata)
  local addi_attr = petdata.attribute_new_info.addi_attr_data
  local baseInfos = {}
  local advaInfos = {}
  local speInfos = {}
  local attritable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.ATTRIBUTE_CONF)
  local attriConfs = attritable:GetAllDatas()
  for i, _conf in pairs(attriConfs) do
    for j, attr in ipairs(addi_attr) do
      if _conf and _conf.attribute == attr.type then
        if _conf.is_ui_show and addi_attr[i] > 0 then
          local infoItem = {
            conf = _conf,
            num = addi_attr[i]
          }
          if _conf.attr_ui_type == Enum.AttrUIType.AUT_BASE then
            table.insert(baseInfos, infoItem)
            break
          end
          if _conf.attr_ui_type == Enum.AttrUIType.AUT_ADVANCE then
            table.insert(advaInfos, infoItem)
            break
          end
          if _conf.attr_ui_type == Enum.AttrUIType.AUT_SPE then
            table.insert(speInfos, infoItem)
          end
        end
        break
      end
    end
  end
  local datas = {
    baseInfos,
    advaInfos,
    speInfos
  }
  return datas
end

function UMG_PetDetailedInfo_C:GetDataEx(petdata)
  local datas
  if petdata then
    local baseInfos = {}
    local advaInfos = {}
    local speInfos = {}
    local advaAttr = {}
    local attritable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.ATTRIBUTE_CONF)
    local attriConfs = attritable:GetAllDatas()
    local PetConf = _G.DataConfigManager:GetPetbaseConf(petdata.base_conf_id)
    local PetBloodConf = _G.DataConfigManager:GetPetBloodConf(petdata.blood_id)
    local AttributeTypeS = PetUtils.GetAttributeTypeSByHabitUnlock(petdata)
    for i, conf in pairs(attriConfs) do
      if conf then
        local _conf = conf
        local _num = PetUtils.GetPetAdditionalByType(petdata, _conf.attribute)
        if _conf and _conf.is_ui_show then
          local attribute = self:Setattribute(_conf)
          local infoItem = {
            conf = _conf,
            num = _num,
            nature = petdata.nature,
            attribute = attribute,
            petdata = petdata
          }
          if _conf.attr_ui_type == Enum.AttrUIType.AUT_BASE then
            table.insert(baseInfos, infoItem)
          elseif i > 34 and i < 53 then
            if 0 ~= PetUtils.GetPetAdditionalByType(petdata, _conf.attribute) then
              infoItem.num = PetUtils.GetPetAdditionalByType(petdata, _conf.attribute)
              infoItem.conf = self:GetAttributeConf(_conf.attribute)
              if 0 ~= infoItem.num then
                if advaInfos and 0 == #advaInfos then
                  table.insert(advaInfos, infoItem)
                else
                  self:PropertyOverlay(advaInfos, infoItem)
                end
              end
            end
          elseif i == Enum.AttributeType.AT_TYPE_SHARPEN or i == Enum.AttributeType.AT_TYPE_BLUNT then
            if 0 ~= PetUtils.GetPetAdditionalByType(petdata, _conf.attribute) then
              infoItem.num = PetUtils.GetPetAdditionalByType(petdata, _conf.attribute)
              infoItem.conf = self:GetAttributeConf(_conf.attribute)
              if 0 ~= infoItem.num then
                infoItem.num = math.modf(infoItem.num / 100)
                if advaInfos and 0 == #advaInfos then
                  table.insert(advaInfos, infoItem)
                else
                  self:PropertyOverlay(advaInfos, infoItem)
                end
              end
            end
          elseif AttributeTypeS and #AttributeTypeS > 0 then
            for j, AttributeType in ipairs(AttributeTypeS) do
              if AttributeType == _conf.attribute then
                infoItem.num = PetUtils.GetPetBaseAttrByType(petdata, AttributeType)
                if 0 ~= infoItem.num then
                  if advaInfos and 0 == #advaInfos then
                    table.insert(advaInfos, infoItem)
                  else
                    self:PropertyOverlay(advaInfos, infoItem)
                  end
                end
              end
            end
          elseif i >= 53 and i < 71 and 0 ~= PetUtils.GetPetAdditionalByType(petdata, _conf.attribute) then
            infoItem.num = PetUtils.GetPetAdditionalByType(petdata, _conf.attribute)
            table.insert(advaInfos, infoItem)
          end
        end
      end
    end
    table.insert(advaInfos, 1, {
      conf = {
        attribute_name = LuaText.umg_petdetailedinfo_1,
        attribute_icon = "PaperSprite'/Game/NewRoco/Modules/System/BattleUI/Raw/Atlas/PetSystem/Frames/AT_STAR_ENERGY_png.AT_STAR_ENERGY_png'"
      },
      num = PetConf.max_energy,
      nature = petdata.nature
    })
    table.insert(baseInfos[1], {
      attrInfo = petdata.attribute_info.hp,
      petConfId = petdata.base_conf_id,
      name = LuaText.umg_petdetailedinfo_2,
      showTipIndex = self.TipsOpenIndex
    })
    table.insert(baseInfos[2], {
      attrInfo = petdata.attribute_info.attack,
      petConfId = petdata.base_conf_id,
      name = LuaText.umg_petdetailedinfo_3,
      showTipIndex = self.TipsOpenIndex
    })
    table.insert(baseInfos[3], {
      attrInfo = petdata.attribute_info.special_attack,
      petConfId = petdata.base_conf_id,
      name = LuaText.umg_petdetailedinfo_4,
      showTipIndex = self.TipsOpenIndex
    })
    table.insert(baseInfos[4], {
      attrInfo = petdata.attribute_info.defense,
      petConfId = petdata.base_conf_id,
      name = LuaText.umg_petdetailedinfo_5,
      showTipIndex = self.TipsOpenIndex
    })
    table.insert(baseInfos[5], {
      attrInfo = petdata.attribute_info.special_defense,
      petConfId = petdata.base_conf_id,
      name = LuaText.umg_petdetailedinfo_6,
      showTipIndex = self.TipsOpenIndex
    })
    table.insert(baseInfos[6], {
      attrInfo = petdata.attribute_info.speed,
      petConfId = petdata.base_conf_id,
      name = LuaText.umg_petdetailedinfo_7,
      showTipIndex = self.TipsOpenIndex
    })
    datas = {
      baseInfos,
      advaInfos,
      speInfos
    }
  end
  return datas
end

function UMG_PetDetailedInfo_C:GetAttributeConf(Index)
  local attritable = _G.DataConfigManager:GetTable(_G.DataConfigManager.ConfigTableId.ATTRIBUTE_CONF)
  local attriConfs = attritable:GetAllDatas()
  for i, conf in pairs(attriConfs) do
    if Index == conf.attribute then
      return conf
    end
  end
  return nil
end

function UMG_PetDetailedInfo_C:PropertyOverlay(advaInfos, infoItem)
  local IsHave = false
  for i, Info in ipairs(advaInfos) do
    if Info and Info.conf.attribute == infoItem.conf.attribute then
      IsHave = true
      Info.num = Info.num + infoItem.num
    end
  end
  if not IsHave then
    table.insert(advaInfos, infoItem)
  end
end

function UMG_PetDetailedInfo_C:Setattribute(_conf)
  local attribute
  if _conf.attribute == _G.Enum.AttributeType.AT_HPMAX then
    attribute = _G.Enum.AttributeType.AT_HPMAX_PERCENT
  elseif _conf.attribute == _G.Enum.AttributeType.AT_PHYATK then
    attribute = _G.Enum.AttributeType.AT_PHYATK_PERCENT
  elseif _conf.attribute == _G.Enum.AttributeType.AT_SPEATK then
    attribute = _G.Enum.AttributeType.AT_SPEATK_PERCENT
  elseif _conf.attribute == _G.Enum.AttributeType.AT_PHYDEF then
    attribute = _G.Enum.AttributeType.AT_PHYDEF_PERCENT
  elseif _conf.attribute == _G.Enum.AttributeType.AT_SPEDEF then
    attribute = _G.Enum.AttributeType.AT_SPEDEF_PERCENT
  elseif _conf.attribute == _G.Enum.AttributeType.AT_SPEED then
    attribute = _G.Enum.AttributeType.AT_SPEED_PERCENT
  end
  return attribute
end

function UMG_PetDetailedInfo_C:OnMaskBtn()
  self.MaskBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local num = self.NRCGridViewBaseInfo:GetItemCount()
  for i = 1, num do
    local item = self.NRCGridViewBaseInfo:GetItemByIndex(i - 1)
    if item then
      item:CloseAllDetailedTips()
    end
  end
end

function UMG_PetDetailedInfo_C:OpenAllDetailedMask(index)
  self.MaskBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  local num = self.NRCGridViewBaseInfo:GetItemCount()
  for i = 1, num do
    if i ~= index then
      local item = self.NRCGridViewBaseInfo:GetItemByIndex(i - 1)
      if item then
        item:OpenAllDetailedMaskBtn()
      end
    end
  end
end

function UMG_PetDetailedInfo_C:CloseAllDetailedTips(Index, IsCloseMaskBtn)
  local num = self.NRCGridViewBaseInfo:GetItemCount()
  for i = 1, num do
    if i ~= Index then
      local item = self.NRCGridViewBaseInfo:GetItemByIndex(i - 1)
      if item then
        item:CloseAllDetailedTips(IsCloseMaskBtn)
      end
    end
  end
end

function UMG_PetDetailedInfo_C:OnCloseButtonClicked()
  _G.NRCModuleManager:GetModule("PetUIModule"):DispatchEvent(PetUIModuleEvent.OpenDetailPanelEvent, false)
  self:StopAllAnimations()
  self:PlayAnimation(self.Disappear)
  _G.NRCAudioManager:PlaySound2DAuto(41401010, "UMG_HavingProp_C:OnItemSelected")
end

function UMG_PetDetailedInfo_C:OnAnimationFinished(Animation)
  if Animation == self.Appear then
    self:PlayAnimation(self.Loop, 0, 99999)
  elseif Animation == self.Disappear then
    self.NRCGridViewBaseInfo:Clear()
    self.NRCGridViewJinjie:Clear()
    self.NRCGridViewot:Clear()
    self.module:ClosePanel(self.panelName)
  end
end

function UMG_PetDetailedInfo_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_PetDetailedInfo")
  if mappingContext then
    mappingContext:BindAction("IA_ClosePetDetailedInfo", self, "OnPcClose2")
  end
end

function UMG_PetDetailedInfo_C:OnPcClose2()
  self:OnCloseButtonClicked()
end

return UMG_PetDetailedInfo_C
