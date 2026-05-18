local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local ResQueue = require("NewRoco.Utils.ResQueue")
local Base = NPCActionBase
local NPCActionTokenDraw = Base:Extend("NPCActionTokenDraw")

function NPCActionTokenDraw:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
  self.bDelaySendReq = true
  self.DelayIdOne = nil
  self.DelayIdTwo = nil
  self.DelayIdThree = nil
end

function NPCActionTokenDraw:Execute()
  Log.Debug("NPCActionTokenDraw:Execute")
  self.localPlayer = NRCModeManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  self.machine = self.Owner.owner.viewObj
  if not self.machine then
  else
    self:LoadResPre()
  end
end

function NPCActionTokenDraw:LoadResPre()
  local LoadQueue = ResQueue()
  LoadQueue:InsertObject("Wand", self.localPlayer:GetCurWandPath(), _G.PriorityEnum.Active_Player_Action)
  LoadQueue:InsertObject("MoZhang", "Blueprint'/Game/NewRoco/Modules/Core/NPC/MagicStar/BP_MoZhang.BP_MoZhang_C'", _G.PriorityEnum.Active_Player_Action)
  LoadQueue:InsertClass("Skill", "/Game/ArtRes/Effects/G6Skill/SceneEffect/791244_PlayerStarOpen.791244_PlayerStarOpen", _G.PriorityEnum.Active_Player_Action)
  LoadQueue:StartLoad(self, self.PlayOperatingAnimations)
end

function NPCActionTokenDraw:PlayOperatingAnimations(Queue, Success)
  local machine = self.machine
  local player = self.localPlayer
  self.Owner:OnPlayerLeaveActionArea()
  player:FaceTo(machine.sceneCharacter)
  local SkillComp
  if player.viewObj and player.viewObj.RocoSkill then
    SkillComp = player.viewObj.RocoSkill
  end
  if SkillComp then
    local Skill = SkillComp:FindOrAddSkillObj(Queue:Get("Skill"))
    if not Skill then
      Log.Error("NPCActionTokenDraw:PlayOperatingAnimations \230\137\190\228\184\141\229\136\176Skill")
      return
    end
    Skill:SetCaster(player.viewObj)
    Skill:SetTargets({machine})
    local World = _G.UE4Helper.GetCurrentWorld()
    local fTransform = UE4.FTransform(UE4.FQuat(), UE4.FVector(-10000, -10000, -10000))
    local MoZhangActor = World:Abs_SpawnActor(Queue:Get("MoZhang"), fTransform, UE4.ESpawnActorCollisionHandlingMethod.AdjustIfPossibleButAlwaysSpawn, nil, nil, nil, {})
    MoZhangActor.SkeletalMesh:SetSkeletalMesh(Queue:Get("Wand"))
    Skill.Blackboard:SetValueAsObject("mozhang", MoZhangActor)
    SkillComp:PlaySkill(Skill)
    Queue:Release()
  end
  if self.DelayIdOne then
    _G.DelayManager:CancelDelayById(self.DelayIdOne)
    self.DelayIdOne = nil
  end
  self.DelayIdOne = _G.DelayManager:DelaySeconds(0.9, function(self)
    machine:Pull(self.DialogueConf.id)
  end, self)
  if self.DelayIdTwo then
    _G.DelayManager:CancelDelayById(self.DelayIdTwo)
    self.DelayIdTwo = nil
  end
  self.DelayIdTwo = _G.DelayManager:DelaySeconds(2.1, function(self)
    self.OnOperatingDone(self)
  end, self)
  if self.DelayIdThree then
    _G.DelayManager:CancelDelayById(self.DelayIdThree)
    self.DelayIdThree = nil
  end
  self.DelayIdThree = _G.DelayManager:DelaySeconds(5.2, function(this)
    this.Owner:OnPlayerEnterActionArea()
    this:DoExecute()
  end, self)
end

function NPCActionTokenDraw:OnOperatingDone()
  self.OperatingAnimationDone = true
  self:StartRewardingPerform()
end

function NPCActionTokenDraw:DoExecute()
  Log.Debug("NPCActionTokenDraw:DoExecute")
  self.Owner:SetNeedStatusNotify(false)
  Base.Execute(self)
  self:OnFinish()
end

function NPCActionTokenDraw:StartRewardingPerform()
  local machine = self.Owner.owner.viewObj
  if not machine then
  else
    machine:Open()
  end
end

function NPCActionTokenDraw:OnFinish()
  if self.DelayIdOne then
    _G.DelayManager:CancelDelayById(self.DelayIdOne)
    self.DelayIdOne = nil
  end
  if self.DelayIdTwo then
    _G.DelayManager:CancelDelayById(self.DelayIdTwo)
    self.DelayIdTwo = nil
  end
  if self.DelayIdThree then
    _G.DelayManager:CancelDelayById(self.DelayIdThree)
    self.DelayIdThree = nil
  end
  self:Finish()
end

return NPCActionTokenDraw
