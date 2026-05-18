local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local BP_ChestLikeNPCBase_C = require("NewRoco.Modules.Core.NPC.Lottery.BP_ChestLikeNPCBase")
local Base = BP_ChestLikeNPCBase_C
local BP_NPCLotteryChest_C = Base:Extend("BP_NPCLotteryChest_C")

function BP_NPCLotteryChest_C:Ctor()
  Base.Ctor(self)
  self.Option = false
end

function BP_NPCLotteryChest_C:Show()
  self:OnShootInAnim()
end

function BP_NPCLotteryChest_C:OnVisible()
  Base.OnVisible(self)
  Base.SetActorNeedTick(self, false)
end

function BP_NPCLotteryChest_C:SetBoxOpen()
  Base.SetActorNeedTick(self, true)
  _G.NRCAudioManager:PlaySound3DWithActorAuto(41512901, self)
  self.bOpened = true
  local skillObjOpen = RocoSkillProxy.Create(tostring(self.FadeSkill), self.RocoSkill, PriorityEnum.Active_Player_Action)
  self.SkeletalMesh:SetCollisionEnabled(UE4.ECollisionEnabled.NoCollision)
  if not skillObjOpen then
    return
  end
  skillObjOpen:SetCaster(self)
  skillObjOpen:RegisterEventCallback("PlayingFx", self, self.PrepareEmit)
  skillObjOpen:RegisterEventCallback("EndFx", self, self.HideSelf)
  skillObjOpen:RegisterEventCallback("EndSkill", self, self.DestroySelf)
  skillObjOpen:PlaySkill()
end

function BP_NPCLotteryChest_C:OnOpenEnd()
  self.DestroyOnInvisible = true
end

function BP_NPCLotteryChest_C:OnShootInAnim()
  self.ActorEmitter.startPos = self:Abs_K2_GetActorLocation() + UE4.FVector(0, 0, 30)
  self.ActorEmitter.angle = 60
  Base.OnShootInAnim(self)
  self.SkeletalMesh:SetSimulatePhysics(false)
end

function BP_NPCLotteryChest_C:OnOpenedInAnim()
  self.Opened = true
end

function BP_NPCLotteryChest_C:DestroySelf()
  local serverId = self.sceneCharacter.serverData.base.actor_id
  _G.NRCModeManager:DoCmd(_G.NPCModuleCmd.RemoveNPC, serverId)
  self.sceneCharacter:Destroy()
end

function BP_NPCLotteryChest_C:HideSelf()
  self.SkeletalMesh:SetVisibility(false)
end

function BP_NPCLotteryChest_C:Show()
  local items = self.sceneCharacter.luaObj.createdNPC
  if self.CreatedNPCs then
    table.clear(self.CreatedNPCs)
  else
    self.CreatedNPCs = {}
  end
  for _, Item in ipairs(items) do
    table.insert(self.CreatedNPCs, Item)
  end
  self.childrenLoaded = true
  if not self.playedFx then
    return
  end
  self:OnShootInAnim()
end

function BP_NPCLotteryChest_C:PrepareEmit()
  self.playedFx = true
  if not self.childrenLoaded then
    return
  end
  self:OnShootInAnim()
end

return BP_NPCLotteryChest_C
