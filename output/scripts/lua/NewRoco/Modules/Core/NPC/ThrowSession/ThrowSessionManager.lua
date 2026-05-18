local ThrowSessionStatusEnum = require("NewRoco.Modules.Core.NPC.ThrowSessionStatusEnum")
local ThrowSessionManager = Class("ThrowSessionManager")

function ThrowSessionManager:Ctor()
  self.localPets = {}
  self.localBalls = {}
  self.localStars = {}
  self.LocalLightBall = {}
  self.SyncPlayerBalls = {}
  self.SyncPlayerStars = {}
  self.SyncPlayerLightBall = {}
end

function ThrowSessionManager:GetLocalPlayerId()
  return _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_UIN)
end

function ThrowSessionManager:GetThrowBagItemCount(BagItemGID)
  if not BagItemGID then
    return 0
  end
  local ItemCount = 0
  for Item, _ in pairs(self.localBalls) do
    local Session = Item.ThrowSession
    if not Session then
    elseif not Session:HasItem() then
    elseif Session:GetGID() ~= BagItemGID then
    elseif Session.Status == ThrowSessionStatusEnum.InAir then
      ItemCount = ItemCount + 1
    end
  end
  return ItemCount
end

function ThrowSessionManager:ClearAll()
  for npc, _ in pairs(self.localPets) do
    if npc.ThrowSession then
      npc.ThrowSession:ClearInReconnect()
    end
    npc:Disappear(true)
  end
  table.clear(self.localPets)
  for npc, _ in pairs(self.localBalls) do
    if npc.ThrowSession then
      npc.ThrowSession:SetStatus(ThrowSessionStatusEnum.Destroyed)
    end
    npc:Disappear(true)
  end
  table.clear(self.localBalls)
end

function ThrowSessionManager:DeleteThrowNPC(npc)
  if not npc.ThrowSession.owner_id or npc.ThrowSession.owner_id == self:GetLocalPlayerId() then
    if self.localBalls[npc] then
      Log.Debug("\230\136\144\229\138\159\229\136\160\233\153\164")
    end
    Log.Debug("ThrowSessionManager:DeleteThrowNPC", npc.ThrowSession.owner_id, self:GetLocalPlayerId())
    self.localBalls[npc] = nil
    self.localPets[npc] = nil
  else
    Log.Debug("ThrowSessionManager:DeleteThrowNPC", npc.ThrowSession.owner_id, self:GetLocalPlayerId())
    local SyncBalls = self.SyncPlayerBalls[npc.ThrowSession.owner_id]
    if SyncBalls then
      if SyncBalls[npc] then
        Log.Debug("\230\136\144\229\138\159\229\136\160\233\153\164")
      end
      SyncBalls[npc] = nil
    end
  end
end

function ThrowSessionManager:DeleteThrowBall(ball, keepSession)
  if not ball then
    Log.Error("\229\146\149\229\153\156\231\144\131\231\155\184\229\133\179\230\151\165\229\191\151: NPCModule:DeleteThrowBall \230\142\165\230\148\182\229\136\176\231\169\186\229\128\188")
    return
  end
  Log.Debug("\229\146\149\229\153\156\231\144\131\231\155\184\229\133\179\230\151\165\229\191\151: DeleteThrowBall", ball.sceneCharacter and ball.sceneCharacter.ThrowSession and ball.sceneCharacter.ThrowSession.SeqID)
  local npc = ball.sceneCharacter
  if not npc and ball.luaObj then
    Log.Error("\229\146\149\229\153\156\231\144\131\231\155\184\229\133\179\230\151\165\229\191\151: ThrowSessionManager:DeleteThrowBall \233\156\128\232\166\129\231\154\132\230\152\175ViewNPCBase\239\188\140\229\136\171\228\188\160SceneNpc\232\191\155\230\157\165")
    npc = ball
  end
  if not npc then
    Log.Error("\229\146\149\229\153\156\231\144\131\231\155\184\229\133\179\230\151\165\229\191\151: NPCModule:DeleteThrowBall \228\188\160\229\133\165\229\128\188\230\178\161\230\156\137\229\175\185\229\186\148\231\154\132NPC")
    return
  end
  if self.localBalls[npc] then
    if not keepSession and npc.ThrowSession then
      npc.ThrowSession:SetStatus(ThrowSessionStatusEnum.Destroyed)
    end
    npc:Disappear(true)
    self:DeleteThrowNPC(npc)
  else
    local SyncBalls = self:GetBallMapByNpc(npc)
    if SyncBalls[npc] then
      npc.ThrowSession:SetStatus(ThrowSessionStatusEnum.Destroyed)
      npc:Disappear(true)
      self:DeleteThrowNPC(npc)
    else
      Log.Error("\229\146\149\229\153\156\231\144\131\231\155\184\229\133\179\230\151\165\229\191\151: NPCModule:DeleteThrowBall \233\135\141\229\164\141\233\148\128\230\175\129")
    end
  end
end

function ThrowSessionManager:DeleteThrowBallById(src_npc_id, throw_id)
  local BallMap = self:GetBallMap(src_npc_id)
  for Ball, _ in pairs(BallMap) do
    local Session = Ball.ThrowSession
    if Session.SeqID == throw_id then
      self:DeleteThrowBall(Ball.viewObj)
    end
  end
end

function ThrowSessionManager:GetBallMapByNpc(Ball)
  if Ball.serverData then
    return self:GetBallMap(Ball.serverData.base.owner_id)
  elseif Ball.ThrowSession and Ball.ThrowSession.owner_id then
    return self:GetBallMap(Ball.ThrowSession.owner_id)
  else
    return self.localBalls
  end
end

function ThrowSessionManager:GetPetMapByNpc(Pet)
  if Pet.serverData then
    return self:GetPetMap(Pet.serverData.base.owner_id)
  elseif Pet.ThrowSession and Pet.ThrowSession.owner_id then
    return self:GetPetMap(Pet.ThrowSession.owner_id)
  else
    return self.localPets
  end
end

function ThrowSessionManager:GetBallMap(owner_id)
  if owner_id == self:GetLocalPlayerId() then
    return self.localBalls
  else
    local SyncBalls = self.SyncPlayerBalls[owner_id]
    if SyncBalls then
      return SyncBalls
    else
      return {}
    end
  end
end

function ThrowSessionManager:GetPetMap(owner_id)
  if owner_id == self:GetLocalPlayerId() then
    return self.localPets
  else
  end
end

function ThrowSessionManager:AssignThrowBagItemSession(throwSession, owner_id)
  if owner_id and owner_id ~= self:GetLocalPlayerId() then
    throwSession:SetOwnerId(owner_id)
    if not self.SyncPlayerBalls[throwSession.owner_id] then
      self.SyncPlayerBalls[throwSession.owner_id] = {}
    end
    self.SyncPlayerBalls[throwSession.owner_id][throwSession.Ball] = true
  else
    throwSession:SetOwnerId(self:GetLocalPlayerId())
    self.localBalls[throwSession.Ball] = true
  end
end

function ThrowSessionManager:AssignThrowPetBallSession(throwSession)
  self.localBalls[throwSession.Ball] = true
  throwSession:SetOwnerId(self:GetLocalPlayerId())
end

function ThrowSessionManager:AssignThrowStarSession(throwSession, owner_id)
  local StarNPC = throwSession.StarNPC
  throwSession:SetOwnerId(owner_id)
  if throwSession.is_local then
    self.localStars[StarNPC] = true
  else
    self.SyncPlayerStars[StarNPC] = true
  end
end

function ThrowSessionManager:AssignThrowLightBallSession(ThrowSession, OwnerID)
  local LightBallNPC = ThrowSession.LightBallNPC
  ThrowSession:SetOwnerId(OwnerID)
  if ThrowSession.is_local then
    self.LocalLightBall[LightBallNPC] = true
  else
    self.SyncPlayerLightBall[LightBallNPC] = true
  end
end

function ThrowSessionManager:AssignLocalPet(throwSession)
  local pet = throwSession.NPC
  for Pet, _ in pairs(self.localPets) do
    if Pet.ThrowSession.petData.gid == throwSession:GetGID() then
      Log.Error("Creating Colliding Sessions", throwSession:GetGID(), pet)
    end
  end
  Log.Debug("[ThrowSessionManager] AssignLocalPet", pet and pet:DebugNPCNameAndID() or "Unknown", throwSession:GetGID(), throwSession:GetThrowID())
  self.localPets[pet] = true
end

function ThrowSessionManager:ThrowBagItemBeginDrop(action)
  for Ball, _ in pairs(self.localBalls) do
    local Session = Ball.ThrowSession
    if Session.Status == ThrowSessionStatusEnum.WaitBeginDrop then
      Session.BeginDrop = action
      Session:SetStatus(ThrowSessionStatusEnum.WaitEnter)
      break
    end
  end
end

function ThrowSessionManager:ThrowPetBeginDrop(action)
  for Pet, _ in pairs(self.localPets) do
    local Session = Pet.ThrowSession
    if Session.Status == ThrowSessionStatusEnum.WaitBeginDrop then
      Session.BeginDrop = action
      Session:SetStatus(ThrowSessionStatusEnum.WaitEnter)
      break
    end
  end
end

function ThrowSessionManager:GetBall(src_npc_id, throw_id)
  local BallMap = self:GetBallMap(src_npc_id)
  for Ball, _ in pairs(BallMap) do
    local Session = Ball.ThrowSession
    if Session.SeqID == throw_id then
      return Ball
    end
  end
end

function ThrowSessionManager:GetPet(src_npc_id, throw_id, gid)
  Log.Debug("ThrowSessionManager:GetPet", src_npc_id, throw_id, gid, self:GetLocalPlayerId())
  if src_npc_id == self:GetLocalPlayerId() then
    for npc, _ in pairs(self.localPets) do
      Log.Debug("ThrowSessionManager:GetPet compare with local Pets:", npc.ThrowSession:GetGID())
      if npc.ThrowSession:GetGID() == gid then
        return npc
      end
    end
  else
  end
  return nil
end

function ThrowSessionManager:GetStar(star)
  if self.localStars[star] then
    return self.localStars[star]
  end
  if self.SyncPlayerStars[star] then
    return self.SyncPlayerStars[star]
  end
end

function ThrowSessionManager:GetLightBall(Ball)
  if self.LocalLightBall[Ball] then
    return self.LocalLightBall[Ball]
  end
  if self.SyncPlayerLightBall[Ball] then
    return self.SyncPlayerLightBall[Ball]
  end
end

function ThrowSessionManager:ForgetBall(Ball)
  local BallMap = self:GetBallMapByNpc(Ball)
  BallMap[Ball] = nil
end

function ThrowSessionManager:ForgetPet(Pet)
  local PetMap = self:GetPetMapByNpc(Pet)
  Log.Debug("[ThrowSessionManager] ForgetPet", Pet and Pet:DebugNPCNameAndID() or "Unknown", Pet and Pet.ThrowSession and Pet.ThrowSession:GetGID())
  PetMap[Pet] = nil
end

function ThrowSessionManager:ForgetStar(star)
  self.localStars[star] = nil
  self.SyncPlayerStars[star] = nil
end

function ThrowSessionManager:ForgetLightBall(Ball)
  self.LocalLightBall[Ball] = nil
  self.SyncPlayerLightBall[Ball] = nil
end

function ThrowSessionManager:EnterBattle(center, radius)
  self:CallLocalEnterBattle(self.localBalls, center, radius)
  self:CallLocalEnterBattle(self.localPets, center, radius)
  for _, Balls in pairs(self.SyncPlayerBalls) do
    if Balls then
      self:CallLocalEnterBattle(Balls, center, radius)
    end
  end
end

function ThrowSessionManager:LeaveBattle()
  self:CallLocalEnterBattle(self.localBalls)
  self:CallLocalEnterBattle(self.localPets)
  for _, Balls in pairs(self.SyncPlayerBalls) do
    if Balls then
      self:CallLocalEnterBattle(Balls)
    end
  end
end

function ThrowSessionManager:CallLocalEnterBattle(localNPCs, center, radius)
  if not localNPCs then
    return
  end
  for npc, _ in pairs(localNPCs) do
    if npc.ThrowSession then
      npc.ThrowSession:SetStatus(ThrowSessionStatusEnum.Destroyed)
    end
    npc:Disappear(true)
  end
  table.clear(localNPCs)
end

function ThrowSessionManager:CallLocalLeaveBattle(localNPCs)
  if not localNPCs then
    return
  end
  for npc, _ in pairs(localNPCs) do
    if npc.viewObj and npc.viewObj.OnLeaveBattle then
      npc.viewObj:OnLeaveBattle()
    end
  end
end

function ThrowSessionManager:RecycleThrowPet(pet)
  if not pet then
    Log.Error("NPCModule:RecycleThrowPet \230\142\165\230\148\182\229\136\176\231\169\186\229\128\188")
    return
  end
  local npc = pet.sceneCharacter
  if not npc then
    Log.Error("NPCModule:RecycleThrowPet \228\188\160\229\133\165\229\128\188\230\178\161\230\156\137\229\175\185\229\186\148\231\154\132NPC")
    return
  end
  if self.localPets[npc] then
    local gid = -1
    if npc.ThrowSession then
      npc.ThrowSession:SetStatus(ThrowSessionStatusEnum.Destroyed)
      npc.ThrowSession:SendRecycleReq()
      gid = npc.ThrowSession:GetGID()
    end
    Log.Debug("ThrowSessionManager:RecycleThrowPet ", gid)
    npc:Disappear(true)
    self.localPets[npc] = nil
  else
    if npc.ThrowSession then
      npc.ThrowSession:SetStatus(ThrowSessionStatusEnum.Destroyed)
      npc.ThrowSession:SendRecycleReq()
    end
    npc:Disappear(true)
  end
end

return ThrowSessionManager
