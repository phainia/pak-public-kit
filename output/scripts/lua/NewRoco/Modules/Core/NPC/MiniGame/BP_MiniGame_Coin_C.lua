local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local BP_MiniGame_Coin_C = Base:Extend("BP_MiniGame_Coin_C")

function BP_MiniGame_Coin_C:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_MiniGame_Coin_C:OnVisible()
  local SceneCharacter = self.sceneCharacter
  if SceneCharacter then
    SceneCharacter.bDisappearPerform = true
    SceneCharacter:LockVisibility(true)
  end
  Base.OnVisible(self)
end

function BP_MiniGame_Coin_C:ReceiveDestroyed()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnPickedReconnect)
  Base.ReceiveDestroyed(self)
end

function BP_MiniGame_Coin_C:PlayDisappearPerform(bPicked)
  if not bPicked then
    Base.PlayDisappearPerform(self)
    return
  end
  self.Niagara:SetVisibility(false)
  self.Niagara1:SetVisibility(true)
  self.Niagara1:Activate(true)
  self.Mesh:SetVisibility(false)
end

function BP_MiniGame_Coin_C:PlayPickUpByPlayer(Player, Caller, Callback)
  _G.NRCEventCenter:RegisterEvent(self.name, self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnPickedReconnect)
  Base.PlayPickUpByPlayer(self, Player, Caller, Callback)
  self:PlayDisappearPerform(true)
  UE4.UNRCAudioManager.Get():PlaySound3DWithActorAuto(232105, self, "BP_MiniGame_Coin_C:PlayPickUpByPlayer")
end

function BP_MiniGame_Coin_C:OnPickedReconnect()
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnPickedReconnect)
  if not UE.UObject.IsValid(self) or not self.sceneCharacter then
    return
  end
  if not self.sceneCharacter.InteractionComponent:GetMainAction():IsOptionEnable() then
    return
  end
  self:SetActorHiddenInGame(false)
  self:SetActorTickEnabled(true)
  local MeshComp = self:GetComponentByClass(UE.UMeshComponent)
  MeshComp:SetVisibility(true, true)
end

return BP_MiniGame_Coin_C
