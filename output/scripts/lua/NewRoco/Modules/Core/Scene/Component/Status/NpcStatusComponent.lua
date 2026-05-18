local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local NpcStatusComponent = ActorComponent:Extend("NpcStatusComponent")

function NpcStatusComponent:Ctor()
  self.taskTracked = false
end

function NpcStatusComponent:UpdateSignificanceStatus()
  local owner = self.owner
  local viewObj = owner and owner.viewObj
  if not UE4.UObject.IsValid(viewObj) or not viewObj.SetSignCharacterType then
    return
  end
  local isThrowPet = self:IsThrowPet()
  local throwPetSign = isThrowPet and self:GetThrowPetSign()
  if isThrowPet and throwPetSign == UE4.ESignCharacterType.Owner then
    viewObj:SetSignCharacterType(UE.ESignCharacterType.OwnerPet)
    return
  end
  local isImportantNpc = self:IsImportantNpc()
  if isImportantNpc then
    viewObj:SetSignCharacterType(UE.ESignCharacterType.ImpotNPC)
    return
  end
  if self.taskTracked then
    viewObj:SetSignCharacterType(UE.ESignCharacterType.NPC_PEO_Task)
    return
  end
  local serverData = owner and owner.serverData
  local npc_base = serverData and serverData.npc_base
  local refresh_src = npc_base and npc_base.refresh_src
  if refresh_src and refresh_src == _G.ProtoEnum.SpaceEnum_NpcRefreshSource.ENUM.ThrowMagic then
    viewObj:SetSignCharacterType(UE.ESignCharacterType.InteractiveActor)
    return
  end
  if isThrowPet then
    viewObj:SetSignCharacterType(throwPetSign)
    return
  end
  if self:IsWildPet() then
    viewObj:SetSignCharacterType(UE.ESignCharacterType.Pet)
    return
  end
  viewObj:SetSignCharacterType(UE.ESignCharacterType.NPC_PEO)
end

function NpcStatusComponent:SetTaskTrack(isTaskTracked)
  if self.taskTracked ~= isTaskTracked then
    self.taskTracked = isTaskTracked
    self:UpdateSignificanceStatus()
  end
end

function NpcStatusComponent:IsThrowPet()
  local owner = self.owner
  local serverData = owner and owner.serverData
  local pet_info = serverData and serverData.pet_info
  local gid = pet_info and pet_info.gid
  if gid and 0 ~= gid then
    return true
  end
  return false
end

function NpcStatusComponent:GetOwnerPlayer()
  local owner = self.owner
  local viewObj = owner and owner.viewObj
  if not UE.UObject.IsValid(viewObj) then
    return nil
  end
  local serverData = owner and owner.serverData
  local npc_base = serverData and serverData.npc_base
  local create_avatar_id = npc_base and npc_base.create_avatar_id
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GetPlayerByServerID, create_avatar_id)
  if not player and owner.ThrowSession then
    player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  end
  return player and player.viewObj
end

function NpcStatusComponent:GetThrowPetSign()
  local owner = self.owner
  local ownerPlayer = self:GetOwnerPlayer()
  local ownerPlayerType
  if UE.UObject.IsValid(ownerPlayer) then
    ownerPlayerType = ownerPlayer:GetSignCharacterType()
  else
    Log.Error("SignificanceTagManager:GetThrowPetSign InValid npc Owner", owner and owner:DebugNPCNameAndID())
    return UE.ESignCharacterType.PlayerPet
  end
  if nil == ownerPlayerType then
    Log.Error("SignificanceTagManager:OnThrowPetCreated owner player type is None", owner and owner:DebugNPCNameAndID())
    return UE.ESignCharacterType.PlayerPet
  end
  if ownerPlayerType == UE4.ESignCharacterType.Owner then
    return UE.ESignCharacterType.OwnerPet
  end
  if ownerPlayerType == UE4.ESignCharacterType.Friend then
    return UE.ESignCharacterType.FriendPet
  end
  if ownerPlayerType == UE4.ESignCharacterType.InVisitPlayer then
    return UE.ESignCharacterType.InVisitPlayerPet
  end
  if ownerPlayerType == UE4.ESignCharacterType.Player then
    return UE.ESignCharacterType.PlayerPet
  end
end

function NpcStatusComponent:IsImportantNpc()
  local owner = self.owner
  local npc_conf = owner and owner.config
  local npc_tag = npc_conf and npc_conf.npc_tag
  if not npc_tag then
    return false
  end
  for tag in ipairs(npc_tag or {}) do
    if tag > 0 then
      return true
    end
  end
  return false
end

function NpcStatusComponent:IsWildPet()
  local owner = self.owner
  local npc_conf = owner and owner.config
  local throwing_interact_type = npc_conf and npc_conf.throwing_interact_type
  if throwing_interact_type and throwing_interact_type == _G.Enum.THROWING_INTERACT_TYPE.TIT_WILD_PET then
    return true
  end
end

return NpcStatusComponent
