local Base = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local PetStatusComponent = require("NewRoco.Modules.Core.Scene.Component.Status.PetStatusComponent")
local PetStatusType = require("NewRoco.Modules.Core.Scene.Component.Status.PetStatusType")
local NPCActionHomeIndoorPetFeed = Base:Extend("NPCActionHomeIndoorPetFeed")

function NPCActionHomeIndoorPetFeed:Ctor(owner, config, info)
  Base.Ctor(self, owner, config, info)
  _G.NRCEventCenter:RegisterEvent("NPCActionHomeIndoorPetFeed", self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnectFinish)
end

function NPCActionHomeIndoorPetFeed:OnReconnectFinish()
  Log.Warning("NPCActionHomeIndoorPetFeed:OnReconnectFinish")
  _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.RemoveCondition, Enum.PlayerConditionType.PCT_HOME_PET_FEED)
  local player = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if player and player.inputComponent then
    player.inputComponent:SetInputEnable(self, true, "NPCActionHomeIndoorPetFeed")
  end
  local pet = self:GetOwnerNPC()
  if pet then
    pet:EnsureComponent(PetStatusComponent):SetStatus(PetStatusType.None)
    pet:LockAIForReason(false, true, _G.AIDefines.LockReason.ACTION_PROCESS)
    pet:SendEvent(NPCModuleEvent.HOME_FEED_SKILL_END)
  end
  if self.skill then
    self.skill:UnregisterEventCallback("End", self, self.OnPlaySkillEnd)
    self.skill:UnregisterEventCallback("ActivateFailed", self, self.OnPlaySkillEnd)
    self.skill:UnregisterEventCallback("Interrupt", self, self.OnPlaySkillEnd)
    self.skill:ReleaseRequest()
    self.Skill = nil
  end
  self:Finish()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnectFinish)
end

function NPCActionHomeIndoorPetFeed:OnQueryEquipRsp(rsp)
  _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.OnCmdOpenPanel, "HomePetFoodPocket", true, rsp)
  self:Finish(true)
end

function NPCActionHomeIndoorPetFeed:Execute()
  Base.Execute(self)
  local _, equipFoodNum = _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.OnCmdGetEquipFoodIdAndNum)
  if not equipFoodNum or equipFoodNum <= 0 then
    local req = ProtoMessage:newZoneGetBagReq()
    req.type = _G.Enum.BagItemType.BI_HOME_PET_FEED
    _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_GET_BAG_REQ, req, self, self.OnQueryEquipRsp)
    return
  end
  _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.AddCondition, Enum.PlayerConditionType.PCT_HOME_PET_FEED)
  self.OwnerNpc:EnsureComponent(PetStatusComponent):SetStatus(PetStatusType.Wait)
  local serverData = self.Owner.owner.serverData
  if not (serverData and serverData.base) or not serverData.home_pet then
    Log.Dump(serverData, 3, "invalid serverData")
    self:Finish(false)
    return
  end
  local currentEquipFoodId, _ = _G.NRCModuleManager:DoCmd(_G.HomeModuleCmd.OnCmdGetEquipFoodIdAndNum)
  local bagItemData = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetBagItemByID, currentEquipFoodId)
  local req = ProtoMessage:newZoneHomePetFeedReq()
  req.npc_obj_id = serverData.base.actor_id
  req.pet_gid = serverData.home_pet.home_pet_info.pet_gid
  req.bag_item_conf_id = currentEquipFoodId
  if bagItemData then
    req.bag_item_gid = bagItemData.gid
  end
  req.food_info = ProtoMessage:newHomePetFoodInfo()
  req.food_info.num = 1
  req.food_info.bag_item_id = currentEquipFoodId
  Log.Dump(req, 3, "ZONE_HOME_PET_FEED_REQ req")
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_HOME_PET_FEED_REQ, req, self, self.OnFeedRsp)
end

function NPCActionHomeIndoorPetFeed:OnFeedRsp(rsp)
  Log.Dump(rsp, 3, "ZoneHomePetFeedRsp")
  local pet = self:GetOwnerNPC()
  pet:EnsureComponent(PetStatusComponent)
  if 0 == rsp.ret_info.ret_code then
    local skillPath = ""
    local player = self:GetPlayer()
    local petView = self:GetOwnerNPCView()
    if not pet or not petView then
      self:Finish(false)
    end
    player:FaceTo(pet)
    pet:FaceTo(player)
    local playerMesh = player.viewObj:GetComponentByClass(UE4.USkeletalMeshComponent)
    local headLocation = playerMesh:GetSocketLocation("locator_Head")
    local playerHeadZ = headLocation.Z
    local capsuleComp = petView:GetComponentByClass(UE4.UCapsuleComponent)
    local capsuleLocation = petView:Abs_K2_GetActorLocation()
    local capsuleHalfHeight = capsuleComp:GetScaledCapsuleHalfHeight()
    local petHeight = capsuleLocation.Z + capsuleHalfHeight * 0.3
    local heightType = playerHeadZ > petHeight and "low" or "normal"
    local skillComp = player.viewObj.RocoSkill
    local petFeedSkillRandomPath = _G.DataConfigManager:GetHomeGlobalConfig("home_feed_resource_path").str
    local pathTable = {}
    if not string.IsNilOrEmpty(petFeedSkillRandomPath) then
      for word in string.gmatch(petFeedSkillRandomPath, "([^;]+)") do
        table.insert(pathTable, word)
      end
      local randomIdx = math.random(1, #pathTable)
      local randomAction = pathTable[randomIdx]
      skillPath = string.format("/Game/ArtRes/Effects/G6Skill/SceneEffect/Pet/touch/World_touch_%s_%s.World_touch_%s_%s", heightType, randomAction, heightType, randomAction)
    else
      self:Finish(false)
    end
    self.skill = RocoSkillProxy.Create(skillPath, skillComp)
    if not self.skill then
      self:Finish(false)
      return
    end
    pet:LockAIForReason(true, true, _G.AIDefines.LockReason.ACTION_PROCESS)
    self.skill:SetCaster(player.viewObj)
    self.skill:SetTargets({petView})
    self.skill:RegisterEventCallback("End", self, self.OnPlaySkillEnd)
    self.skill:RegisterEventCallback("ActivateFailed", self, self.OnPlaySkillEnd)
    self.skill:RegisterEventCallback("Interrupt", self, self.OnPlaySkillEnd)
    self.skill:SetPassive(false)
    self.skill:PlaySkill()
  else
    self:OnErrTips(rsp.ret_info.ret_code)
    if pet then
      pet:EnsureComponent(PetStatusComponent):SetStatus(PetStatusType.None)
    end
    self:Finish(false)
  end
end

function NPCActionHomeIndoorPetFeed:Finish(success, data, param)
  _G.NRCModuleManager:DoCmd(_G.FunctionBanModuleCmd.RemoveCondition, Enum.PlayerConditionType.PCT_HOME_PET_FEED)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnReconnectFinish)
  Base.Finish(self, success, data, param)
end

function NPCActionHomeIndoorPetFeed:OnErrTips(errorCode)
  local tipsKey = string.format("Error_Code_%d", errorCode)
  local tips = LuaText[tipsKey]
  if not tips then
    return
  end
  local TipsModuleCmd = require("NewRoco.Modules.System.TipsModule.TipsModuleCmd")
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, tips)
end

function NPCActionHomeIndoorPetFeed:OnPlaySkillEnd()
  local pet = self:GetOwnerNPC()
  if pet then
    pet:EnsureComponent(PetStatusComponent):SetStatus(PetStatusType.None)
    pet:LockAIForReason(false, true, _G.AIDefines.LockReason.ACTION_PROCESS)
    pet:SendEvent(NPCModuleEvent.HOME_FEED_SKILL_END)
  end
  self:Finish(true)
end

return NPCActionHomeIndoorPetFeed
