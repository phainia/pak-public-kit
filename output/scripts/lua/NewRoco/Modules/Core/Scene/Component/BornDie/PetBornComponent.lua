local NPCModuleEvent = require("NewRoco.Modules.Core.NPC.NPCModuleEvent")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local PetBornComponent = Base:Extend("PetBornComponent")

function PetBornComponent:Attach(owner)
  Base.Attach(self, owner)
  self.QuietBornDelegate = nil
end

function PetBornComponent:DeAttach()
  if self.QuietBornDelegate then
    _G.DelayManager:CancelDelayById(self.QuietBornDelegate)
    self.QuietBornDelegate = nil
  end
  Base.DeAttach(self)
end

function PetBornComponent:PetBorn(callback, caller)
  local born_die_info = self.owner.serverData.base.born_die_info
  local ball_id = born_die_info.create_actor_id
  local Path
  local owner = self:GetOwner()
  Path = "/Game/ArtRes/Effects/G6Skill/Yuancheng/CallOut_Suc"
  self.performing = false
  local view = owner.viewObj
  if not view then
    return self.performing
  end
  local WearMedal = owner.serverData.pet_info.medal_conf_id
  self.MedalType = nil
  if WearMedal then
    local medal_conf = _G.DataConfigManager:GetMedalConf(WearMedal, true)
    if medal_conf then
      self.MedalType = medal_conf.fx_res
    end
  end
  local ownerView = owner and owner.viewObj
  local isHidden = ownerView and ownerView.bHidden
  if owner:IsHidden() or isHidden then
    self.performing = true
    self:QuietBorn(caller, callback)
    return self.performing
  end
  owner:SetVisibleForCallOutReason(false)
  local skillComp = view:GetComponentByClass(UE4.URocoSkillComponent)
  skillComp = skillComp or view:AddComponentByClass(UE4.URocoSkillComponent, false, UE4.FTransform(), false)
  if not skillComp then
    return self.performing
  end
  local Skill = RocoSkillProxy.Create(Path, skillComp, PriorityEnum.Passive_3P_Action)
  if not Skill then
    return
  end
  Skill:SetCaster(view)
  Skill:SetAdditions("BallID", ball_id)
  Skill:RegisterEventCallback("End", caller, callback)
  Skill:RegisterEventCallback("Interrupt", caller, callback)
  Skill:RegisterEventCallback("PreEnd", caller, callback)
  Skill:RegisterEventCallback("PreEndAnim", caller, callback)
  Skill:RegisterEventCallback("HideBall", self, self.Hide)
  Skill:RegisterEventCallback("ShowPet", self, self.ShowPet)
  Skill:RegisterEventCallback("PreStart", self, self.OnPerformPreStart)
  Skill:PlaySkill()
  self.performing = true
  self.owner.distanceOptLodTime = 3
  local ball = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetThrowBallById, self:GetOwnerID(), self:GetThrowID())
  if ball then
    ball.ThrowSession:SetBallRecycling()
  end
  return self.performing
end

function PetBornComponent:GetThrowID()
  local Owner = self.owner
  local ServerData = Owner and Owner.serverData
  local MiscInfo = ServerData and ServerData.misc_info
  if not MiscInfo then
    Log.Error(Owner:DebugNPCNameAndID(), "Misc Info is nil")
    return 0
  end
  return MiscInfo.throw_id or 0
end

function PetBornComponent:GetOwnerID()
  local Owner = self.owner
  local ServerData = Owner and Owner.serverData
  local BaseInfo = ServerData and ServerData.base
  local OwnerID = BaseInfo and BaseInfo.owner_id or 0
  return OwnerID or 0
end

function PetBornComponent:QuietBorn(caller, callback)
  self.caller = caller
  self.callback = callback
  self.owner.distanceOptLodTime = 0.1
  local throw_id = self:GetThrowID()
  if throw_id then
    _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.DeleteThrowBallById, self:GetOwnerID(), throw_id)
  else
    Log.Error("\229\144\142\229\143\176\228\184\139\229\143\145\231\154\132\231\178\190\231\129\181\231\148\159\230\136\144\230\178\161\230\156\137\229\184\166ball id!!!\228\188\154\229\175\188\232\135\180\229\146\149\229\153\156\231\144\131\230\174\139\231\149\153")
  end
  self.QuietBornDelegate = _G.DelayManager:DelaySeconds(0.1, self.DoCallBack, self)
end

function PetBornComponent:DoCallBack()
  local caller = self.caller
  local callback = self.callback
  self.caller = nil
  self.callback = nil
  if caller and callback then
    callback(caller)
  end
  self.QuietBornDelegate = nil
end

function PetBornComponent:OnPerformPreStart(Name, Skill)
  local BallID = Skill:GetAddition("BallID")
  local ball = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetThrowBallById, self:GetOwnerID(), self:GetThrowID())
  if ball and ball.viewObj then
    Skill.Blackboard:SetValueAsObject("_ID_AUTOGENERATE_BALL0", ball.viewObj)
  else
    Log.Error("\231\178\190\231\129\181\229\135\186\231\148\159\231\154\132\230\151\182\229\128\153\230\137\190\228\184\141\229\136\176\229\174\131\231\154\132\231\144\131\228\186\134\239\188\129\239\188\129\239\188\129\239\188\129\231\178\190\231\129\181\229\190\136\228\188\164\229\191\131\239\188\140\229\190\136\230\130\178\228\188\164\239\188\140\229\164\167\229\147\173\239\188\140\231\151\155\229\147\173\230\181\129\230\182\149", BallID)
  end
  self.owner.distanceOptLodTime = 0.5 + Skill:GetLength()
  local Blackboard = Skill.Blackboard
  if self.MedalType then
    Blackboard:SetValueAsString(self.MedalType, self.MedalType)
  end
end

function PetBornComponent:Hide(Name, SkillObject)
  local owner_id = self:GetOwnerID()
  local throw_id = self:GetThrowID()
  local ball = _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.GetThrowBallById, owner_id, throw_id)
  if ball then
    SkillObject.Blackboard:RemoveObjectValue("_ID_AUTOGENERATE_BALL0")
    _G.NRCModuleManager:DoCmd(_G.NPCModuleCmd.DeleteThrowBallById, owner_id, throw_id)
  else
    Log.Error("\229\144\142\229\143\176\228\184\139\229\143\145\231\154\132\231\178\190\231\129\181\231\148\159\230\136\144\230\178\161\230\156\137\229\184\166ball id!!!\228\188\154\229\175\188\232\135\180\229\146\149\229\153\156\231\144\131\230\174\139\231\149\153")
  end
end

function PetBornComponent:ShowPet()
  local owner = self:GetOwner()
  if owner then
    owner:SetVisibleForCallOutReason(true)
  end
end

return PetBornComponent
