require("UnLua")
local LoginModuleEvent = require("NewRoco.Modules.System.LoginModule.LoginModuleEvent")
local BP_LoginAvatarPlayer_C = NRCClass()

function BP_LoginAvatarPlayer_C:NotifyGender()
  local CurLevelName = LevelHelper:GetLevelName()
  if self.bIsMale then
    if "Login" == CurLevelName then
      NRCEventCenter:DispatchEvent(LoginModuleEvent.CharacterSelected, LoginModuleEvent.MaleCharacterSelected)
      NRCEventCenter:DispatchEvent(LoginModuleEvent.EndPostSelectionIdle, LoginModuleEvent.MaleCharacterSelected)
    else
      NRCModuleManager:DoCmd(CreatePlayerModuleCmd.OnMaleBtnClick)
    end
  elseif "Login" == CurLevelName then
    NRCEventCenter:DispatchEvent(LoginModuleEvent.CharacterSelected, LoginModuleEvent.FemaleCharacterSelected)
    NRCEventCenter:DispatchEvent(LoginModuleEvent.EndPostSelectionIdle, LoginModuleEvent.FemaleCharacterSelected)
  else
    NRCModuleManager:DoCmd(CreatePlayerModuleCmd.OnFemaleBtnClick)
  end
end

function BP_LoginAvatarPlayer_C:SetAvatarBeauty(salonId, colorIndex)
  if colorIndex > 0 then
    colorIndex = colorIndex - 1
  end
  local fullSalonId = salonId * 100 + colorIndex
  if colorIndex > 9 then
    fullSalonId = salonId * 100 + colorIndex
  end
  self:SetAvatarMaterialID(fullSalonId)
end

function BP_LoginAvatarPlayer_C:SetDefaultSuit(gender, callback)
  local defaultSuitClass
  if 2 == gender then
    if NRCEnv:IsLocalMode() then
      defaultSuitClass = UEPath.DEFAULT_AVATAR_SUIT_FEMALE_EDITOR
    else
      defaultSuitClass = UEPath.DEFAULT_AVATAR_SUIT_FEMALE
    end
  elseif NRCEnv:IsLocalMode() then
    defaultSuitClass = UEPath.DEFAULT_AVATAR_SUIT_MALE_EDITOR
  else
    defaultSuitClass = UEPath.DEFAULT_AVATAR_SUIT_MALE
  end
  local request = NRCResourceManager:LoadResAsync(self, defaultSuitClass, 255, -1, function(caller, resRequest, asset)
    self:OnDefaultSuitLoadSucc(asset, gender, callback)
  end, nil, nil)
end

function BP_LoginAvatarPlayer_C:OnDefaultSuitLoadSucc(defaultSuitClass, gender, callback)
  local defaultSuitObj = NewObject(defaultSuitClass, _G.UE4Helper.GetCurrentWorld())
  defaultSuitObj.Gender = gender
  local fashionIds, salonIds = self:GetDefaultIds(gender)
  local fullSalonIds = {}
  for k, v in ipairs(salonIds) do
    table.insert(fullSalonIds, self:GetFullSalonId(v, 0))
  end
  defaultSuitObj:SetSalons(fullSalonIds)
  for k, v in ipairs(fashionIds) do
    defaultSuitObj:SetBody(v, 0)
  end
  self:SwitchAvatarSuit(defaultSuitObj)
end

function BP_LoginAvatarPlayer_C:SetAvatarSuit(fashionIds, salonIds, gender)
  local defaultSuitClass
  if 2 == gender then
    if NRCEnv:IsLocalMode() then
      defaultSuitClass = UEPath.DEFAULT_AVATAR_SUIT_FEMALE_EDITOR
    else
      defaultSuitClass = UEPath.DEFAULT_AVATAR_SUIT_FEMALE
    end
  elseif NRCEnv:IsLocalMode() then
    defaultSuitClass = UEPath.DEFAULT_AVATAR_SUIT_MALE_EDITOR
  else
    defaultSuitClass = UEPath.DEFAULT_AVATAR_SUIT_MALE
  end
  local request = NRCResourceManager:LoadResAsync(self, defaultSuitClass, 255, -1, function(caller, resRequest, asset)
    self:OnAvatarSuitLoadSucc(asset, fashionIds, salonIds, gender)
  end, nil, nil)
end

function BP_LoginAvatarPlayer_C:OnAvatarSuitLoadSucc(avatarSuitClass, fashionIds, salonIds, gender)
  local avatarSuitObj = NewObject(avatarSuitClass, _G.UE4Helper.GetCurrentWorld())
  avatarSuitObj.Gender = gender
  avatarSuitObj:SetSalons(salonIds)
  for k, v in ipairs(fashionIds) do
    avatarSuitObj:SetBody(v, 0)
  end
  self:SwitchAvatarSuit(avatarSuitObj)
end

function BP_LoginAvatarPlayer_C:GetFullSalonId(salonId, colorIndex)
  local fullSalonId = salonId * 100 + colorIndex
  return fullSalonId
end

function BP_LoginAvatarPlayer_C:GetDefaultIds(gender)
  local fashionIds = {}
  local salonIds = {}
  if gender == ProtoEnum.ESexValue.SEX_MALE then
    local fashionList = _G.DataConfigManager:GetRoleGlobalConfig("fashion_free_item_pc1").numList
    local salonList = _G.DataConfigManager:GetRoleGlobalConfig("salon_free_item_pc1").numList
    for k, v in pairs(fashionList) do
      if v > 100 then
        local fashionItemConf = _G.DataConfigManager:GetFashionItemConf(v)
        if fashionItemConf and fashionItemConf.type ~= Enum.FashionLabelType.FLT_WAND then
          table.insert(fashionIds, v)
        end
      end
    end
    for k, v in pairs(salonList) do
      if 0 == k % 2 then
        local salonItemConf = _G.DataConfigManager:GetSalonItemConf(v)
        table.insert(salonIds, salonItemConf.avatar_id)
      end
    end
  elseif gender == ProtoEnum.ESexValue.SEX_FEMALE then
    local fashionList = _G.DataConfigManager:GetRoleGlobalConfig("fashion_free_item_pc2").numList
    local salonList = _G.DataConfigManager:GetRoleGlobalConfig("salon_free_item_pc2").numList
    for k, v in pairs(fashionList) do
      if v > 100 then
        local fashionItemConf = _G.DataConfigManager:GetFashionItemConf(v)
        if fashionItemConf and fashionItemConf.type ~= Enum.FashionLabelType.FLT_WAND then
          table.insert(fashionIds, v)
        end
      end
    end
    for k, v in pairs(salonList) do
      if 0 == k % 2 then
        local salonItemConf = _G.DataConfigManager:GetSalonItemConf(v)
        table.insert(salonIds, salonItemConf.avatar_id)
      end
    end
  end
  return fashionIds, salonIds
end

function BP_LoginAvatarPlayer_C:SetOpenEye(bOpen)
  local AnimInstance = self.AnimComponent:GetAnimInstance()
  if nil ~= AnimInstance then
    AnimInstance.bOpenEye = bOpen
  end
end

return BP_LoginAvatarPlayer_C
