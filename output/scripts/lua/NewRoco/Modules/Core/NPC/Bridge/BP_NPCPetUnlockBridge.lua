require("UnLuaEx")
local Base = require("NewRoco.Modules.Core.NPC.ViewNPCBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local BP_NPCPetUnlockBridge = Base:Extend("BP_NPCPetUnlockBridge")

function BP_NPCPetUnlockBridge:Initialize(Initializer)
  Base.Initialize(self, Initializer)
end

function BP_NPCPetUnlockBridge:LuaBeginPlay()
  Base.LuaBeginPlay(self)
end

function BP_NPCPetUnlockBridge:OnVisible()
  Base.OnVisible(self)
  self.fakeActive = false
  self.Activated = false
  self:UpdateState(true)
end

function BP_NPCPetUnlockBridge:FakeActivate()
  self.fakeActive = true
  self:UpdateState(false)
end

function BP_NPCPetUnlockBridge:OnInVisible()
end

function BP_NPCPetUnlockBridge:UpdateState(immediate)
  if self.ActiveBox then
    self.ActiveBox:SetCollisionProfileName("NoCollision")
  end
  if self:IsActivated() then
    if immediate then
      self:SetShouldImmediate(immediate)
      self:SetPetShow(true)
      self:SetBridgeShow(true)
      self.Activated = true
      self:CancelActiveSkill()
      if self.ActiveBox then
        self.ActiveBox:SetCollisionProfileName("BlockAll")
      end
    else
      if self.Activated then
        return
      end
      self.Activated = true
      self:SetShouldImmediate(immediate)
      self.SkillProxy = RocoSkillProxy.Create("SkillBlueprint'/Game/ArtRes/Effects/G6Skill/BoundarySouls/G6_BoundarySouls_StoneShake.G6_BoundarySouls_StoneShake'", self.RocoSkill, PriorityEnum.Active_Player_Action)
      self.SkillProxy:RegisterEventCallback("PreEnd", self.OnSkillFinished)
      self.SkillProxy:RegisterEventCallback("End", self.OnSkillFinished)
      self.SkillProxy:RegisterEventCallback("Interrupt", self.OnSkillFinished)
      self.SkillProxy:PlaySkill(self, self.PrePlayActiveShow)
    end
  else
    if not self.Activated then
      return
    end
    self.Activated = false
    self:SetShouldImmediate(true)
    self:SetPetShow(false)
    self:SetBridgeShow(false)
    self:CancelActiveSkill()
  end
end

function BP_NPCPetUnlockBridge:PrePlayActiveShow()
  if self:IsActivated() then
    self:SetPetShow(true)
    self:SetBridgeShow(true)
  end
end

function BP_NPCPetUnlockBridge:OnSkillFinished()
  self.SkillProxy = nil
end

function BP_NPCPetUnlockBridge:CancelActiveSkill()
  if self.SkillProxy then
    self.SkillProxy:CancelSkill(UE.ESkillActionResult.SkillActionResultInterrupted)
    self.SkillProxy = nil
  end
end

function BP_NPCPetUnlockBridge:OnLogicStatusChanged()
  self:UpdateState(false)
end

function BP_NPCPetUnlockBridge:IsActivated()
  return SceneUtils.IsLogicStatusUnlock(self.sceneCharacter) or self.fakeActive
end

function BP_NPCPetUnlockBridge:ReceiveEndPlay()
  Base.ReceiveEndPlay(self)
end

return BP_NPCPetUnlockBridge
