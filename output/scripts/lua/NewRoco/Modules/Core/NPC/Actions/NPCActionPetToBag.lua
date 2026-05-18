local ResQueue = require("NewRoco.Utils.ResQueue")
local NPCActionModelBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local BornDieComponent = require("NewRoco.Modules.Core.Scene.Component.BornDie.BornDieComponent")
local Base = NPCActionModelBase
local NPCActionPetToBag = Base:Extend("NPCActionPetToBag")
local MaxPlayTime = 3

function NPCActionPetToBag:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
  self.DelayHandler = -1
  self.ResLoader = false
end

function NPCActionPetToBag:ExecuteWithModel()
  local npc = self:GetOwnerNPC()
  local bornDie = npc:EnsureComponent(BornDieComponent)
  bornDie.BeginDiePlayed = true
  npc:SetNotDestroyFlag(true)
  self:Commit()
end

function NPCActionPetToBag:OnCommit(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    Base.OnCommit(self, rsp)
    return
  end
  local animName = self.Config.action_param2
  if string.IsNilOrEmpty(animName) then
    self:FlyToBag()
  else
    local animLength = self.OwnerNpc:PlayAnim(animName, 1, 0, 0.2, 0.2, 1)
    local executeTime = math.min(animLength, MaxPlayTime)
    if executeTime > 1.0E-5 then
      self.DelayHandler = _G.DelayManager:DelaySeconds(executeTime, self.FlyToBag, self)
      return
    else
      self:FlyToBag()
    end
  end
end

function NPCActionPetToBag:FlyToBag()
  if not self or not self.GetOwnerNPCView then
    self:EndAction()
    return
  end
  local NPCViewObj = self:GetOwnerNPCView()
  if not NPCViewObj then
    self:EndAction()
    return
  end
  if not UE.UObject.IsValid(NPCViewObj) then
    self:EndAction()
    return
  end
  if self.ResLoader then
    self.ResLoader:Release()
  else
    self.ResLoader = ResQueue(30, ResQueue.RunMode.Concurrent, _G.PriorityEnum.Active_Player_Action)
  end
  local PetInfoID = tonumber(self.Config.action_param3)
  local PetInfoConf = PetInfoID and _G.DataConfigManager:GetPetInfoConf(PetInfoID)
  local BallID = PetInfoConf and PetInfoConf.ball_id
  local BallConf = BallID and 0 ~= BallID and _G.DataConfigManager:GetBallConf(BallID)
  local NPCID = BallConf and BallConf.npc_id or 50338
  if NPCID and 0 ~= NPCID then
    self.BallID = BallID
    local Owner = self:GetOwnerNPC()
    self.ResLoader:InsertNPC("Ball", NPCID, Owner and Owner:GetServerPosition() or nil)
  else
    Log.Debug("\230\178\161\230\156\137\231\144\131\231\154\132ID~", self.Config.action_param3)
  end
  self.ResLoader:StartLoad(self, self.DoFly)
end

function NPCActionPetToBag:DoFly(Queue, Success)
  local BallID = self.BallID
  self.BallID = nil
  if not Success then
    self:EndAction()
    return
  end
  if not self or not self.GetOwnerNPCView then
    self:EndAction()
    return
  end
  local NPCViewObj = self:GetOwnerNPCView()
  if not NPCViewObj then
    self:EndAction()
    return
  end
  if not UE.UObject.IsValid(NPCViewObj) then
    self:EndAction()
    return
  end
  local Ball = Queue:Get("Ball")
  if not Ball or not Ball.viewObj then
    self:EndAction()
    return
  end
  Ball.BallID = BallID
  Ball:SetVisible(false)
  NPCViewObj:FlyBackToPlayer(true, Ball, self, self.EndAction)
  self.DelayHandler = _G.DelayManager:DelaySeconds(10, self.EndAction, self)
end

function NPCActionPetToBag:EndAction()
  self:ClearDelayHandler()
  local rsp = _G.ProtoMessage:newZoneSceneNpcNextActRsp()
  rsp.ret_info.ret_code = 0
  Base.OnCommit(self, rsp)
  if self.ResLoader then
    self.ResLoader:Release()
  end
end

function NPCActionPetToBag:ClearDelayHandler()
  if self.DelayHandler > 0 then
    _G.DelayManager:CancelDelayById(self.DelayHandler)
    self.DelayHandler = -1
  end
end

function NPCActionPetToBag:Destroy()
  self:ClearDelayHandler()
  if self.ResLoader then
    self.ResLoader:Release()
  end
  Base.Destroy(self)
end

return NPCActionPetToBag
