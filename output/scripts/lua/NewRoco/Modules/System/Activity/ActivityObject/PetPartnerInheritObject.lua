local Base = require("NewRoco.Modules.System.Activity.ActivityObject.ActivityObjectBase")
local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local ActivityUtils = require("NewRoco.Modules.System.Activity.ActivityUtils")
local ActivityModuleEvent = require("NewRoco.Modules.System.Activity.ActivityModuleEvent")
local PetPartnerInheritObject = Base:Extend("PetPartnerInheritObject")

function PetPartnerInheritObject:OnConstruct(_conf)
  self.petPartnerInheritConf = _G.DataConfigManager:GetActivityPetPartnerConf(self:GetSinglePartId())
  self.petPartnerInheritSvrData = {}
end

function PetPartnerInheritObject:IsActivityLevelOpen()
  local worldLevelCfg = self.petPartnerInheritConf.world_level
  local worldLevel = _G.DataModelMgr.PlayerDataModel:GetPlayerLevel()
  return worldLevelCfg <= worldLevel
end

function PetPartnerInheritObject:GetPartnerPetData()
  local petPartnerData = self.petPartnerInheritSvrData.pet_partner_data
  if petPartnerData then
    return petPartnerData.inherit_pet_data
  end
end

function PetPartnerInheritObject:GetPartnerPetConf()
  local petPartnerData = self.petPartnerInheritSvrData.pet_partner_data
  if petPartnerData and petPartnerData.pet_partner_items then
    return petPartnerData.pet_partner_items
  end
end

function PetPartnerInheritObject:GetChoosedPetBaseIDAndEggID()
  local eggID = 0
  local PetID = 0
  local petPartnerData = self.petPartnerInheritSvrData.pet_partner_data
  if petPartnerData and petPartnerData.select_pet_base_id then
    PetID = petPartnerData.select_pet_base_id
    if petPartnerData.choose_inherit_pet and petPartnerData.inherit_pet_data and petPartnerData.select_pet_base_id == petPartnerData.inherit_pet_data.base_conf_id then
      local cfgData = _G.DataConfigManager:GetPetbaseConf(petPartnerData.select_pet_base_id)
      eggID = cfgData.pet_egg
    else
      for i, v in ipairs(petPartnerData.pet_partner_items) do
        if v.pet_base_id == petPartnerData.select_pet_base_id then
          eggID = v.egg_id
          break
        end
      end
    end
  end
  return PetID, eggID
end

function PetPartnerInheritObject:GetSelectPetName(selectPetBaseID, isPartner)
  local petPartnerData = self.petPartnerInheritSvrData.pet_partner_data
  if isPartner and petPartnerData and petPartnerData.inherit_pet_data and petPartnerData.inherit_pet_data.base_conf_id == selectPetBaseID then
    return petPartnerData.inherit_pet_data.name
  else
    local petConf = _G.DataConfigManager:GetPetbaseConf(selectPetBaseID)
    if petConf then
      return petConf.name
    end
  end
  return nil
end

function PetPartnerInheritObject:HasReceivedPartnerPetEgg()
  local petPartnerData = self.petPartnerInheritSvrData.pet_partner_data
  if petPartnerData then
    return petPartnerData.committed
  end
  return false
end

function PetPartnerInheritObject:IsChooseInheritPet()
  local petPartnerData = self.petPartnerInheritSvrData.pet_partner_data
  if petPartnerData then
    return petPartnerData.choose_inherit_pet
  end
  return false
end

function PetPartnerInheritObject:OnSvrUpdateActivityData(_cmdId, _updateData, _initUpdate)
  if _cmdId == _G.ProtoCMD.ZoneSvrCmd.ZONE_GET_PLAYER_ACTIVITY_DATA_RSP then
    self.petPartnerInheritSvrData = _updateData
    local petPartnerData = self.petPartnerInheritSvrData.pet_partner_data
    if petPartnerData then
      for i, v in ipairs(petPartnerData.pet_partner_items) do
        v.mutation_type = Enum.MutationDiffType.MDT_GLASS
        local glassInfoDetails = {}
        glassInfoDetails.glassType = ProtoEnum.GlassType.GT_COMMON
        glassInfoDetails.colorInfo = {}
        glassInfoDetails.colorInfo.colorId = v.color_random_id
        glassInfoDetails.colorInfo.particle = v.particle_random_id
        v.glass_info = PetMutationUtils.EncodeShineColorInfo(glassInfoDetails)
      end
    end
    self:SendEvent(ActivityModuleEvent.RefreshPetPartnerInheritUI, false)
    Log.Dump(petPartnerData, 6, "PetPartnerInheritObject:OnSvrUpdateActivityData")
  end
end

function PetPartnerInheritObject:SyncActivityDataOnAvailable()
  self:ReqGetPlayerActivityData()
end

function PetPartnerInheritObject:ChoosePartnerPetReq(petBaseID, isInherit, isRemain)
  local req = ProtoMessage.newZoneChoosePetPartnerReq()
  req.pet_base_id = petBaseID
  req.is_inherit = isInherit
  req.miantain_expression = isRemain
  req.activity_id = self:GetActivityId()
  ActivityUtils.SendMsgToSvr(_G.ProtoCMD.ZoneSvrCmd.ZONE_CHOOSE_PET_PARTNER_REQ, req, self, self.OnChoosePartnerPetRsp)
end

function PetPartnerInheritObject:OnChoosePartnerPetRsp(_rspData, reqData)
  if 0 == _rspData.ret_info.ret_code then
    local petPartnerData = self.petPartnerInheritSvrData.pet_partner_data
    if petPartnerData then
      petPartnerData.select_pet_base_id = reqData.pet_base_id
      petPartnerData.choose_inherit_pet = reqData.is_inherit
      self:SendEvent(ActivityModuleEvent.RefreshPetPartnerInheritUI, false)
    end
  end
end

function PetPartnerInheritObject:ReceivePartnerPetEggReq()
  local req = ProtoMessage.newZoneChoosePetPartnerReq()
  req.commit = true
  req.activity_id = self:GetActivityId()
  ActivityUtils.SendMsgToSvr(_G.ProtoCMD.ZoneSvrCmd.ZONE_CHOOSE_PET_PARTNER_REQ, req, self, self.ReceivePartnerPetEggRsp)
end

function PetPartnerInheritObject:ReceivePartnerPetEggRsp(_rspData)
  if 0 == _rspData.ret_info.ret_code then
    local petPartnerData = self.petPartnerInheritSvrData.pet_partner_data
    if petPartnerData then
      petPartnerData.committed = true
      self:SendEvent(ActivityModuleEvent.RefreshPetPartnerInheritUI, true)
    end
    if _rspData.ret_info.goods_reward and _rspData.ret_info.goods_reward.rewards then
      for i, v in ipairs(_rspData.ret_info.goods_reward.rewards) do
        v.AssignQuality = 5
      end
      _G.NRCModuleManager:DoCmd(_G.NPCShopUIModuleCmd.OpenNPCShopItemRewardsPanel, _rspData.ret_info.goods_reward.rewards, "")
    end
  else
    Log.Error("PetPartnerInheritObject:ReceivePartnerPetEggRsp: _rspData.ret_info.ret_code is" .. _rspData.ret_info.ret_code)
  end
end

return PetPartnerInheritObject
