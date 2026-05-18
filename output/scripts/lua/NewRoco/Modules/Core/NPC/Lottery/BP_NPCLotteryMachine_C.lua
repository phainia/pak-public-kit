local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local ViewNPCBase = require("NewRoco.Modules.Core.NPC.Lottery.BP_ChestLikeNPCBase")
local ResObject = require("NewRoco.Utils.ResObject")
local Base = ViewNPCBase
local BP_NPCLotteryMachine_C = Base:Extend("BP_NPCLotteryMachine_C")

function BP_NPCLotteryMachine_C:Ctor()
  Base.Ctor(self)
  self.NeedsValidation = true
  self.LightInited = false
  self.NpcCreationReady = false
  self.OnOpenAnimationDone = false
  self:InitResources()
  self.DieRes = false
end

function BP_NPCLotteryMachine_C:InitResources()
  self.LightsOn = {}
  for i = 1, 4 do
    table.insert(self.LightsOn, false)
  end
  if not self.DieRes then
    self.DieRes = ResObject.MakeUClass("/Game/ArtRes/Effects/G6Skill/SceneEffect/791244_PlayerStarOpen", 100)
    if self.DieRes and self.DieRes.StartLoad then
      self.DieRes:StartLoad()
    else
      self.DieRes = nil
      Log.Debug("Failed to create DieRes object")
    end
  end
end

function BP_NPCLotteryMachine_C:PreNavInter()
  Log.Debug("BP_NPCLotteryMachine_C:PreNavInter", self:GetDebugInfo())
  self.SkeletalMesh.bForceSetNavRelevancyTrue = true
  self.SkeletalMesh:SetCollisionProfileName("CreatingNPC")
end

function BP_NPCLotteryMachine_C:OnNavInterFinish(Success)
  Log.Debug("BP_NPCLotteryMachine_C:OnNavInterFinish", Success, self:GetDebugInfo())
  if self.SkeletalMesh and UE4.UObject.IsValid(self.SkeletalMesh) then
    self.SkeletalMesh:SetCollisionProfileName("BlockAllDynamic")
  end
end

function BP_NPCLotteryMachine_C:OnShootInAnim()
  _G.NRCAudioManager:PlaySound3DWithActorAuto(1201512703, self, "lottery machine show gift")
  local forward = self:GetActorForwardVector()
  self.ActorEmitter.startPos = self:Abs_K2_GetActorLocation() + UE4.FVector(0, 0, 50) + forward * 70
  self.ActorEmitter.angle = 60
  local thirtyDegreeRotater = UE4.FRotator(0, 0, 30)
  local explodeAxis = thirtyDegreeRotater:RotateVector(forward)
  self.ActorEmitter.explodeAxis = explodeAxis
  self.ActorEmitter.force = 6000
  Base.OnShootInAnim(self)
end

function BP_NPCLotteryMachine_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
end

function BP_NPCLotteryMachine_C:Pull(SelectedId)
  _G.NRCAudioManager:PlaySound3DWithActorAuto(1201512701, self, "lottery machine start")
  _G.DelayManager:DelaySeconds(0.5, function(this)
    _G.NRCAudioManager:PlaySound3DWithActorAuto(1201512702, this, "lottery machine running")
  end, self)
  self.bActive = true
  self.SelectedId = SelectedId - 2
end

function BP_NPCLotteryMachine_C:TurnOnAllLights()
  self:TurnLightOnOnOpen(1, true)
  self:TurnLightOnOnOpen(2, true)
  self:TurnLightOnOnOpen(3, true)
  self:TurnLightOnOnOpen(4, true)
end

function BP_NPCLotteryMachine_C:GetLightIndex(name)
  if not name then
    return nil
  end
  local Start, End, Result
  for i = 1, 4 do
    Start, End, Result = string.find(name, tostring(i) .. LuaText.bp_npclotterymachine_1, 1)
    if Start then
      return i
    end
  end
  return nil
end

function BP_NPCLotteryMachine_C:UpdateLights(optionInfo, callReset)
  if not optionInfo then
    return
  end
  if not optionInfo.select_infos then
    self:TurnOnAllLights()
    return
  end
  for i, dialogueInfo in pairs(optionInfo.select_infos) do
    local SelectConf = DataConfigManager:GetSelectConf(dialogueInfo.select_id, true)
    local idx = self:GetLightIndex(SelectConf.text)
    if idx then
      if dialogueInfo.remaining_times <= 0 then
        self:TurnLightOnOnOpen(5 - idx, false)
      else
        self:TurnLightOnOnOpen(5 - idx, true)
      end
    end
  end
  self:TurnLightOn(0, false)
  if not self.LightInited then
    self.LightInited = true
    self:ApplyLightsSwitch()
  end
end

function BP_NPCLotteryMachine_C:TurnLightOnOnOpen(idx, on)
  if not self.LightsOn then
    self:InitResources()
  end
  self.LightsOn[idx] = on
end

function BP_NPCLotteryMachine_C:ApplyLightsSwitch()
  for i = 1, 4 do
    self:TurnLightOn(i, self.LightsOn[i])
  end
  if not self.LightsOn[1] and not self.LightsOn[2] and not self.LightsOn[3] and not self.LightsOn[4] then
    self.SetSoldOutOnNextReset = true
  end
end

function BP_NPCLotteryMachine_C:OnFirstVisible()
  Base.OnFirstVisible(self)
  self:SetupLights()
end

function BP_NPCLotteryMachine_C:OnVisible()
  Base.OnVisible(self)
  self:ApplyLightsSwitch()
end

function BP_NPCLotteryMachine_C:OnInVisible()
  Base.OnInVisible(self)
  self.SelectedId = nil
end

function BP_NPCLotteryMachine_C:Open()
  self.bOpened = true
end

function BP_NPCLotteryMachine_C:OnOpened()
  self.OnOpenAnimationDone = true
  self:ApplyLightsSwitch()
  self:CheckShouldShoot()
end

function BP_NPCLotteryMachine_C:Reset()
  self.bOpened = false
  self.bActive = false
  _G.NRCAudioManager:PlaySound3DWithActorAuto(1201512704, self, "lottery machine running done")
  self.sceneCharacter.InteractionComponent:TryEnableInteraction()
  if self.SetSoldOutOnNextReset then
    _G.DelayManager:DelaySeconds(0.5, function(this)
      _G.NRCAudioManager:PlaySound3DWithActorAuto(1201512705, this, "lottery machine soldout")
    end, self)
    self.bSoldOut = true
    self.SetSoldOutOnNextReset = false
  end
end

function BP_NPCLotteryMachine_C:CheckSoldOut()
  return false
end

function BP_NPCLotteryMachine_C:OnOpenEnd()
  self:Reset()
end

function BP_NPCLotteryMachine_C:Show()
  self.NpcCreationReady = true
  self:CheckShouldShoot()
end

function BP_NPCLotteryMachine_C:CheckShouldShoot()
  if self.OpenAnimationDone and self.NpcCreationReady then
    self:OnShootInAnim()
  end
end

function BP_NPCLotteryMachine_C:SetChildNPC(npcs)
  if not npcs then
    return
  end
  for _, npc in ipairs(npcs) do
    local landPos = self:GetNearLandLocation() + self:GetActorForwardVector() * 100
    landPos = landPos + UE4.FVector(math.random(-1, 1), math.random(-1, 1), 0) * 50
    if landPos then
      local serverPos = npc.serverData.base.pt.pos
      serverPos.x = landPos.X
      serverPos.y = landPos.Y
      serverPos.z = landPos.Z
      npc:ChangeNeedPosAdjust(false, true)
      npc.serverPos = UE4.FVector(serverPos.x, serverPos.y, serverPos.z)
      npc:SetActorLocation(landPos)
      npc.viewObj:PlayBeamEffect()
      SceneUtils.CorrectActorPos(npc.viewObj, false)
    else
      Log.Warning("landPos\228\184\141\229\173\152\229\156\168")
    end
  end
end

function BP_NPCLotteryMachine_C:ReceiveDestroyed()
  if self.DieRes then
    self.DieRes:Release()
    self.DieRes = nil
  end
  Base.ReceiveDestroyed(self)
end

return BP_NPCLotteryMachine_C
