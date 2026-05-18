local LoginUtils = require("NewRoco.Modules.System.LoginModule.LoginUtils")
local UIUtils = require("NewRoco.Utils.UIUtils")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")
local AppearanceLoginModule = NRCModuleBase:Extend("AppearanceLoginModule")

function AppearanceLoginModule:OnConstruct()
  _G.AppearanceLoginModuleCmd = reload("NewRoco.Modules.System.AppearanceLogin.AppearanceLoginModuleCmd")
  self.data = self:SetData("AppearanceLoginModuleData", "NewRoco.Modules.System.AppearanceLogin.AppearanceLoginModuleData")
  self:RegPanel("BeautyLoginMain", "UMG_BeautyLogin_Main", _G.Enum.UILayerType.UI_LAYER_MAIN)
end

function AppearanceLoginModule:OnActive()
  self.data:BuildUIColorIndexToColorMap()
  self.data:BuildAvatarSalonIdToSalonIds()
  self.data:BuildAvatarInitialSuitMap()
  _G.DataModelMgr.PlayerDataModel:AddEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.OnPlayerDataUpdate)
end

function AppearanceLoginModule:OnRelogin()
end

function AppearanceLoginModule:OnDeactive()
  _G.DataModelMgr.PlayerDataModel:RemoveEventListener(self, ENUM_PLAYER_DATA_EVENT.UPDATE_DATA, self.OnPlayerDataUpdate)
end

function AppearanceLoginModule:OnPlayerDataUpdate()
  self:RefreshInitialSelectedSuitId()
end

function AppearanceLoginModule:OnDestruct()
end

function AppearanceLoginModule:OnCmdOpenBeautyLoginPanel(bOpen, bNeedDelayRotation)
  local isOpening, _ = self:HasPanel("BeautyLoginMain")
  _G.NRCModuleManager:DoCmd(LoginModuleCmd.SetNeedDelayRotation, bNeedDelayRotation)
  if not isOpening then
    if bOpen then
      local resListData = _G.NRCPanelResLoadData()
      resListData.PreLoadResList = {}
      table.insert(resListData.PreLoadResList, "Texture2D'/Game/NewRoco/Modules/System/Appearance/Raw/Textures/T_UI_Closet_Color2.T_UI_Closet_Color2'")
      table.insert(resListData.PreLoadResList, "Texture2D'/Game/NewRoco/Modules/System/Appearance/Raw/Textures/T_UI_Closet_Color1.T_UI_Closet_Color1'")
      table.insert(resListData.PreLoadResList, "Texture2D'/Game/NewRoco/Modules/System/Appearance/Raw/Textures/T_UI_black.T_UI_black'")
      table.insert(resListData.PreLoadResList, "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/Cosplay/G6_CosPlay_YiGui_MeiRong.G6_CosPlay_YiGui_MeiRong_C'")
      table.insert(resListData.PreLoadResList, "SkillBlueprint'/Game/ArtRes/Effects/G6Skill/Cosplay/G6_CosPlay_YiGui_MeiRong_End.G6_CosPlay_YiGui_MeiRong_End_C'")
      self:OpenPanel("BeautyLoginMain", resListData)
    end
  else
    local panel = self:GetPanel("BeautyLoginMain")
    if false == bOpen then
      panel:DoClose()
    end
  end
end

function AppearanceLoginModule:OnCmdSetBeautyTabEnum(enum)
  if self.tabAudio then
    _G.NRCAudioManager:PlaySound2DAuto(41401006, "UMG_Beauty_Item1_C:OnItemSelected")
  else
    self.tabAudio = true
  end
  local bMoveCamera = false
  if self.data.curBeautyChooseType ~= enum then
    if enum == Enum.SalonLabelType.SLT_SUIT then
      bMoveCamera = true
    elseif self.data.curBeautyChooseType == Enum.SalonLabelType.SLT_SUIT then
      bMoveCamera = true
    end
  end
  self.AvatarSalonAudio = false
  self.BeautyColorListAudio = false
  self.data.curBeautyChooseType = enum
  if self:HasPanel("BeautyLoginMain") then
    local panel = self:GetPanel("BeautyLoginMain")
    panel:UpdateBeautyList()
    if bMoveCamera then
      panel:CheckMovePlayerModel()
    end
  end
end

function AppearanceLoginModule:SaveBeautyData(gender)
  local tempBeautyData = self:GetCurSuitBeautyData(gender)
  self.data:SaveCurBeautyData(gender, tempBeautyData)
end

function AppearanceLoginModule:GetCurSuitBeautyData(gender)
  local AvatarPlayer
  if gender == ProtoEnum.ESexValue.SEX_MALE then
    AvatarPlayer = LoginUtils.GetUObjectHolder().Player1
  elseif gender == ProtoEnum.ESexValue.SEX_FEMALE then
    AvatarPlayer = LoginUtils.GetUObjectHolder().Player2
  end
  if AvatarPlayer and UE4.UObject.IsValid(AvatarPlayer) then
    local defaultSuitObj = AvatarPlayer:GetAvatarSuit()
    local TempSalons = defaultSuitObj:GetSalons():ToTable()
    Log.Dump(TempSalons, 4, "AppearanceLoginModule:GetCurSuitBeautyData")
    return self:GetSalonIdAndColorIndexFromTempSalons(TempSalons)
  end
end

function AppearanceLoginModule:GetSalonIdAndColorIndexFromTempSalons(tempSalons)
  local tempSalonDatas = {}
  for k, v in ipairs(tempSalons) do
    local salonId, colorIndex = self:DecodeFullId(v)
    table.insert(tempSalonDatas, {SalonId = salonId, SalonColorIndex = colorIndex})
  end
  return tempSalonDatas
end

function AppearanceLoginModule:DecodeFullId(fullId)
  local SalonColorIndex = 105
  local SalonId = 0
  if fullId < 10000000 then
    return
  end
  if fullId < 1000000000 then
    SalonId = fullId
    SalonColorIndex = 105
  else
    SalonId = math.floor(fullId / 100)
    SalonColorIndex = fullId % 100
  end
  local configEnum = _G.Enum.SalonLabelType.SLT_BEGIN
  configEnum = math.floor(fullId / 1000000 % 10)
  return SalonId, SalonColorIndex
end

function AppearanceLoginModule:OnCmdSetAvatarSalon(salonId, colorIndex)
  if self.AvatarSalonAudio then
  else
    self.AvatarSalonAudio = true
  end
  local ActorHolder = LoginUtils.GetUObjectHolder()
  local gender = _G.NRCModuleManager:DoCmd(LoginModuleCmd.GetCurRegisterGender)
  if gender == ProtoEnum.ESexValue.SEX_MALE then
    ActorHolder.Player1:SetAvatarBeauty(salonId, colorIndex)
  else
    ActorHolder.Player2:SetAvatarBeauty(salonId, colorIndex)
  end
  self:SaveBeautyData(gender)
  self.colorIndex = colorIndex
end

function AppearanceLoginModule:OnCmdSetBeautyColorList(salonItemIds)
  if self.BeautyColorListAudio then
  else
    self.BeautyColorListAudio = true
  end
  self.AvatarSalonAudio = false
  if self:HasPanel("BeautyLoginMain") then
    local panel = self:GetPanel("BeautyLoginMain")
    panel:SetBeautyColorList(salonItemIds, self.colorIndex)
  end
end

function AppearanceLoginModule:OnCmdGetUIColorIndexToColorMap(index)
  return self.data.UIColorIndexToColorIdMap[index]
end

function AppearanceLoginModule:OnCmdGetAvatarSalonIdToSalonIds()
  return self.data.AvatarSalonIdToSalonIds
end

function AppearanceLoginModule:OnCmdGetTempBeautyDataByGender(gender)
  return self.data:GetCurBeautyData(gender)
end

function AppearanceLoginModule:GetTempDataFromAvatar()
end

function AppearanceLoginModule:RegPanel(name, path, layer)
  local registerData = _G.NRCPanelRegisterData()
  registerData.panelName = name
  registerData.panelPath = string.format("/Game/NewRoco/Modules/System/AppearanceLogin/Res/%s", path)
  registerData.panelLayer = layer
  self:RegisterPanel(registerData)
end

function AppearanceLoginModule:OnCmdGetColorBGResByColorType(colorType)
  local hasPanel = self:HasPanel("BeautyLoginMain")
  if hasPanel then
    local panel = self:GetPanel("BeautyLoginMain")
    if panel then
      if colorType == Enum.HairColours.HC_PURE then
        return self:GetRes("Texture2D'/Game/NewRoco/Modules/System/Appearance/Raw/Textures/T_UI_black.T_UI_black'", "BeautyLoginMain")
      elseif colorType == Enum.HairColours.HC_GRADIENT then
        return self:GetRes("Texture2D'/Game/NewRoco/Modules/System/Appearance/Raw/Textures/T_UI_Closet_Color1.T_UI_Closet_Color1'", "BeautyLoginMain")
      elseif colorType == Enum.HairColours.HC_HIGHLIGHT then
        return self:GetRes("Texture2D'/Game/NewRoco/Modules/System/Appearance/Raw/Textures/T_UI_Closet_Color2.T_UI_Closet_Color2'", "BeautyLoginMain")
      end
    end
  end
  return nil
end

function AppearanceLoginModule:OnCmdGetInitialOptionalSuitIds(gender)
  return self.data:GetInitialOptionalSuitIds(gender)
end

function AppearanceLoginModule:OnCmdGetInitialSelectedSuitId(gender)
  gender = gender or _G.DataModelMgr.PlayerDataModel:IsMale() and Enum.ESexValue.SEX_MALE or Enum.ESexValue.SEX_FEMALE
  return self.data:GetInitialSelectedSuitId(gender)
end

function AppearanceLoginModule:RefreshInitialSelectedSuitId()
  local fashionData = _G.DataModelMgr.PlayerDataModel:GetPlayerFashionInfo()
  if fashionData and fashionData.init_role_info and fashionData.init_role_info.fashion_suit_id then
    local gender = _G.DataModelMgr.PlayerDataModel:IsMale() and Enum.ESexValue.SEX_MALE or Enum.ESexValue.SEX_FEMALE
    self.data:SetInitialSelectedSuitId(gender, fashionData.init_role_info.fashion_suit_id)
  end
end

function AppearanceLoginModule:OnCmdSetAvatarSuit(_fashionIds, _suitId)
  local gender = _G.NRCModuleManager:DoCmd(LoginModuleCmd.GetCurRegisterGender)
  local curModelFashions
  local AvatarPlayer = self:GetLoginPlayerActor()
  if AvatarPlayer and UE4.UObject.IsValid(AvatarPlayer) then
    local defaultSuitObj = AvatarPlayer:GetAvatarSuit()
    local bodies = defaultSuitObj:GetBodies()
    curModelFashions = bodies and bodies.ToTable and bodies:ToTable() or {}
  end
  if table.valueEquals(curModelFashions, _fashionIds) then
    return
  end
  local playerActor = self:GetLoginPlayerActor()
  local fashionIds = _fashionIds
  local salonIds = {}
  local curSalonIds = self:OnCmdGetTempBeautyDataByGender(gender)
  if curSalonIds then
    for i, v in ipairs(curSalonIds) do
      table.insert(salonIds, self:GetFullSalonId(v.SalonId, v.SalonColorIndex + 1))
    end
  end
  if playerActor then
    playerActor:SetAvatarSuit(fashionIds, salonIds, gender)
    self:PlayReloadingSkill(playerActor)
    self.data:SetInitialSelectedSuitId(gender, _suitId)
  end
end

function AppearanceLoginModule:GetFullSalonId(salonId, colorIndex)
  if colorIndex > 0 then
    colorIndex = colorIndex - 1
  end
  local fullSalonId = salonId * 100 + colorIndex
  return fullSalonId
end

function AppearanceLoginModule:PlayReloadingSkill(viewObj)
  local skill_path = "/Game/ArtRes/Effects/G6Skill/AvaTar/G6_Avatar_FullBody_Fx01.G6_Avatar_FullBody_Fx01"
  if viewObj and UE4.UObject.IsValid(viewObj) then
    local skillComponent = viewObj.RocoSkill
    if skillComponent then
      local skillProxy = RocoSkillProxy.Create(skill_path, skillComponent)
      skillProxy:SetCaster(viewObj)
      skillProxy:SetPassive(true)
      local target = viewObj
      skillProxy:SetTargets({target})
      skillProxy:PlaySkill()
    end
  end
end

function AppearanceLoginModule:GetLoginPlayerActor()
  local ActorHolder = LoginUtils.GetUObjectHolder()
  local gender = _G.NRCModuleManager:DoCmd(LoginModuleCmd.GetCurRegisterGender)
  if gender == ProtoEnum.ESexValue.SEX_MALE then
    return ActorHolder.Player1
  else
    return ActorHolder.Player2
  end
  return nil
end

return AppearanceLoginModule
