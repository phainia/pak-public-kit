local NpcStatusComponent = require("NewRoco.Modules.Core.Scene.Component.Status.NpcStatusComponent")
local Base = require("Common.Singleton.Singleton")
local FriendModuleEvent = require("NewRoco.Modules.System.Friend.FriendModuleEvent")
local SignificanceTagManager = Base:Extend("SignificanceTagManager")

function SignificanceTagManager:Ctor(name)
  Base.Ctor(self, name)
  _G.NRCEventCenter:RegisterEvent(name, self, _G.NRCGlobalEvent.ON_THROW_PET_CREATED, self.OnThrowPetCreated)
  _G.NRCEventCenter:RegisterEvent(name, self, _G.NRCGlobalEvent.ON_RIDE_PET_CREATED, self.OnRidePet)
  _G.NRCEventCenter:RegisterEvent(name, self, _G.NRCGlobalEvent.UPDATE_PLAYER_TAG, self.OnPlayerCreated)
  _G.NRCEventCenter:RegisterEvent(name, self, _G.NRCGlobalEvent.ON_FETCH_PLAYER_FRIEND, self.OnFetchFriend)
  _G.NRCEventCenter:RegisterEvent(name, self, FriendModuleEvent.OnVisitorChanged, self.OnFetchFriend)
end

function SignificanceTagManager:Free()
  if _G.NRCEventCenter then
    _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_THROW_PET_CREATED, self.OnThrowPetCreated)
    _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RIDE_PET_CREATED, self.OnRidePet)
    _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.UPDATE_PLAYER_TAG, self.OnPlayerCreated)
    _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_FETCH_PLAYER_FRIEND, self.OnFetchFriend)
    _G.NRCEventCenter:UnRegisterEvent(self, FriendModuleEvent.OnVisitorChanged, self.OnFetchFriend)
  end
  Base.Free(self)
end

function SignificanceTagManager:OnThrowPetCreated(npcViewObj)
  if npcViewObj.SetSignCharacterType then
    local npc = npcViewObj and npcViewObj.sceneCharacter
    local npcStatusComponent = npc and npc:EnsureComponent(NpcStatusComponent)
    if npcStatusComponent then
      npcStatusComponent:UpdateSignificanceStatus()
    end
  else
    Log.Error("SignificanceTagManager:OnThrowPetCreated npc is not a SignificanceActor")
  end
end

function SignificanceTagManager:OnRidePet(player, petViewObj)
  local ownerActorType = player:GetSignCharacterType()
  if ownerActorType == UE.ESignCharacterType.Owner then
    petViewObj:SetSignCharacterType(UE.ESignCharacterType.Owner)
  elseif ownerActorType == UE.ESignCharacterType.Friend then
    petViewObj:SetSignCharacterType(UE.ESignCharacterType.Friend)
  elseif ownerActorType == UE.ESignCharacterType.InVisitPlayer then
    petViewObj:SetSignCharacterType(UE.ESignCharacterType.InVisitPlayerRidePet)
  elseif ownerActorType == UE.ESignCharacterType.Player then
    petViewObj:SetSignCharacterType(UE.ESignCharacterType.Player)
  end
end

function SignificanceTagManager:OnPlayerCreated(player)
  if UE.UObject.IsValid(player) then
    local scenePlayer = player.sceneCharacter
    if scenePlayer.isLocal then
      player:SetSignCharacterType(UE.ESignCharacterType.Owner)
      self:UpdatePlayerPet(scenePlayer)
      return
    end
    local isFriend = _G.DataModelMgr.PlayerDataModel:IsFriend(scenePlayer.serverData.base.logic_id)
    if isFriend then
      player:SetSignCharacterType(UE.ESignCharacterType.Friend)
      self:UpdatePlayerPet(scenePlayer)
      return
    end
    local isVisitMe = self:IsPlayerVisitMe(scenePlayer.serverData.base.logic_id)
    if isVisitMe then
      player:SetSignCharacterType(UE.ESignCharacterType.InVisitPlayer)
      self:UpdatePlayerPet(scenePlayer)
      return
    end
    player:SetSignCharacterType(UE.ESignCharacterType.Player)
    self:UpdatePlayerPet(scenePlayer)
  end
end

function SignificanceTagManager:OnFetchFriend()
  local playerList = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_ALL_PLAYER)
  for _, player in pairs(playerList) do
    if player then
      self:OnPlayerCreated(player.viewObj)
    end
  end
end

function SignificanceTagManager:IsPlayerVisitMe(playerUin)
  if _G.FriendModuleCmd then
    local visitorList = _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.GetOnlineVisitorList) or _G.DataModelMgr.PlayerDataModel.visitList
    for k, v in pairs(visitorList) do
      local visitorInfo = v
      if visitorInfo.uin == playerUin then
        return true
      end
    end
  end
  return false
end

function SignificanceTagManager:UpdatePlayerPet(scenePlayer)
  local serverId = scenePlayer and scenePlayer:GetServerId()
  local pets = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetPetByPlayer, serverId)
  for _, pet_actor_id in ipairs(pets or {}) do
    local pet = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetNpcByServerID, pet_actor_id)
    if pet then
      local npcStatusComponent = pet:EnsureComponent(NpcStatusComponent)
      npcStatusComponent:UpdateSignificanceStatus()
    end
  end
end

return SignificanceTagManager
