local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local NPCActionBehaviorOverwriteContentBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBehaviorOverwriteContent")
local Base = NPCActionBehaviorOverwriteContentBase
local NPCActionFashionChangeDetected = Base:Extend("NPCActionFashionChangeDetected")

function NPCActionFashionChangeDetected:Destroy()
  self:ClearWearingStore()
  Base.Destroy(self)
end

function NPCActionFashionChangeDetected:OnSubmit(rsp)
  local ret_code_ok = 0 == rsp.ret_info.ret_code
  if ret_code_ok then
    self:TriggerAiOverwrite()
  end
  Base.OnSubmit(self, rsp)
  self:Finish(ret_code_ok)
end

function NPCActionFashionChangeDetected:Execute(playerId, needSendReq)
  Base.Execute(self, playerId, needSendReq)
  if self.SkipSubmit then
    self:TriggerAiOverwrite()
    self:Finish(true)
  end
end

function NPCActionFashionChangeDetected:OnDialogueAction()
  self:TriggerAiOverwrite()
  Base.OnDialogueAction(self)
end

function NPCActionFashionChangeDetected:OnNpcAction()
  local bEnterFittingRoom = self:IsEnterFittingRoom()
  local bOptionFireAble = false
  if bEnterFittingRoom then
    self:StoreNowWearing()
  else
    if self:IsAnyWearChanged() then
      bOptionFireAble = true
    end
    self:StoreNowWearing()
  end
  if bOptionFireAble then
    return Base.OnNpcAction(self)
  else
    return false
  end
end

function NPCActionFashionChangeDetected:StoreNowWearing()
  local fashionInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerFashionInfo()
  local table_WithFashionIdAsKey = {}
  local table_WithSalonItemIdAsKey = {}
  local fashionElementCount = 0
  local salonElementCount = 0
  if fashionInfo then
    if 0 == fashionInfo.suit_id and fashionInfo.wardrobe_data and fashionInfo.current_wardrobe_index and fashionInfo.current_wardrobe_index + 1 <= #fashionInfo.wardrobe_data then
      local fashionIds = fashionInfo.wardrobe_data[fashionInfo.current_wardrobe_index + 1].wearing_item or {}
      if fashionIds then
        for idx, fashionId in ipairs(fashionIds) do
          table_WithFashionIdAsKey[fashionId.wearing_item_id] = true
          fashionElementCount = fashionElementCount + 1
        end
      else
        Log.Debug("fashionIds is nil")
      end
      local allSalonItemWearId = fashionInfo.wardrobe_data[fashionInfo.current_wardrobe_index + 1].salon_item_wear_id or {}
      for idx, salonItemWearId in ipairs(allSalonItemWearId) do
        table_WithSalonItemIdAsKey[salonItemWearId] = true
        salonElementCount = salonElementCount + 1
      end
    else
      table_WithFashionIdAsKey.suitId = fashionInfo.suit_id
    end
  end
  table_WithFashionIdAsKey.elementCount = fashionElementCount
  table_WithSalonItemIdAsKey.elementCount = salonElementCount
  self.table_WithSalonItemIdAsKey = table_WithSalonItemIdAsKey
  self.table_WithFashionIdAsKey = table_WithFashionIdAsKey
end

function NPCActionFashionChangeDetected:IsAnyWearChanged()
  if type(self.table_WithFashionIdAsKey) ~= "table" then
    return false
  end
  local fashionInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerFashionInfo()
  if not fashionInfo then
    return false
  end
  if self.table_WithFashionIdAsKey.suitId and fashionInfo.suit_id ~= self.table_WithFashionIdAsKey.suitId then
    return true
  end
  if 0 == fashionInfo.suit_id and fashionInfo.wardrobe_data and fashionInfo.current_wardrobe_index and fashionInfo.current_wardrobe_index + 1 <= #fashionInfo.wardrobe_data then
    local fashionIds = fashionInfo.wardrobe_data[fashionInfo.current_wardrobe_index + 1].wearing_item or {}
    if fashionIds then
      if #fashionIds ~= self.table_WithFashionIdAsKey.elementCount then
        return true
      end
      for idx, fashionId in ipairs(fashionIds) do
        if not self.table_WithFashionIdAsKey[fashionId.wearing_item_id] then
          return true
        end
      end
    else
      Log.Debug("fashionIds is nil")
    end
    if "table" ~= type(self.table_WithSalonItemIdAsKey) then
      return false
    end
    local allSalonItemWearId = fashionInfo.wardrobe_data[fashionInfo.current_wardrobe_index + 1].salon_item_wear_id or {}
    if #allSalonItemWearId ~= self.table_WithSalonItemIdAsKey.elementCount then
      return true
    end
    for idx, salonItemWearId in ipairs(allSalonItemWearId) do
      if not self.table_WithSalonItemIdAsKey[salonItemWearId] then
        return true
      end
    end
  end
  return false
end

function NPCActionFashionChangeDetected:IsEnterFittingRoom()
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local x, y, z, yaw = _G.NRCModuleManager:DoCmd(AppearanceModuleCmd.GetTailorFittingRoomDoorFace)
  if not (x and y and z) or not yaw then
    return
  end
  local CenterPoint = UE4.FVector(x, y, z)
  local VectorCenterToPlayer = localPlayer:GetActorLocation() - CenterPoint
  VectorCenterToPlayer.Z = 0
  local yawValueToInside = yaw
  return UE4.UKismetMathLibrary.Dot_VectorVector(VectorCenterToPlayer, UE4.UKismetMathLibrary.CreateVectorFromYawPitch(yawValueToInside, 0)) < 0
end

function NPCActionFashionChangeDetected:ClearWearingStore()
  self.table_WithSalonItemIdAsKey = nil
  self.table_WithFashionIdAsKey = nil
end

function NPCActionFashionChangeDetected:TriggerAiOverwrite()
  local filterParam = tonumber(self.Config.action_param1) or 0
  local behaviorGroupId = tonumber(self.Config.action_param2) or 0
  if 0 == filterParam then
    local npc = self:GetOwnerNPC()
    if npc and npc.AIComponent then
      npc.AIComponent:OverrideBehavior(behaviorGroupId, _G.Enum.BehaviorOverridePriority.BOP_A)
    end
  else
    local filterTactic = 1
    UE.UDotsStatics.OverrideBehaviorBatchByConfigId(_G.UE4Helper.GetCurrentWorld(), filterParam, behaviorGroupId, filterTactic)
  end
end

return NPCActionFashionChangeDetected
