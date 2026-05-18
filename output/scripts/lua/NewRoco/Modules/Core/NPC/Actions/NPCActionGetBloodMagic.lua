local NPCActionModelBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local ResQueue = require("NewRoco.Utils.ResQueue")
local Base = NPCActionModelBase
local NPCActionGetBloodMagic = Base:Extend("NPCActionGetBloodMagic")

function NPCActionGetBloodMagic:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
  self.LoadQueue = nil
  self.OpenBloodMagicFlag = false
  _G.NRCEventCenter:RegisterEvent("NPCActionGetBloodMagic", self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisconnect)
  _G.NRCEventCenter:RegisterEvent("NPCActionGetBloodMagic", self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnFinish)
end

function NPCActionGetBloodMagic:Execute()
  Base.Execute(self)
  self.BagItemId = self.Config.action_param2
  if self.LoadQueue then
    self.LoadQueue:Release()
  else
    self.LoadQueue = ResQueue(30, ResQueue.RunMode.Concurrent, _G.PriorityEnum.Active_Player_Action)
  end
  self.LoadQueue:InsertNPC("Compass", 220000)
  self.LoadQueue:StartLoad(self, self.OnShowResReady)
end

function NPCActionGetBloodMagic:OnShowResReady(Queue, Success)
  if not Success then
    self.LoadQueue:Release()
    Log.Error("Load Res Failed!!!!!!")
    return
  end
  local Player = self:GetPlayer()
  local SkillComp = Player.viewObj.RocoSkill
  self.LuoPan = Queue:Get("Compass")
  self.LuoPanView = self.LuoPan.viewObj
  local Skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_GongMing.G6_GongMing", SkillComp, PriorityEnum.Active_Player_Action)
  self.Skill = Skill
  if not Skill then
    Log.Error("NPCActionGetBloodMagic:Execute \230\137\190\228\184\141\229\136\176Skill")
    return
  end
  Skill:SetWithLoadAndPlay(true)
  Skill:SetCaster(Player.viewObj)
  Skill:SetTargets({
    self:GetOwnerNPCView(),
    self.LuoPanView
  })
  Skill:RegisterEventCallback("PauseSkill", self, self.PauseSkill)
  Skill:RegisterEventCallback("Interrupt", self, self.OnInterrupt)
  Skill:RegisterEventCallback("End", self, self.OnFinish)
  Skill:PlaySkill(self, self.OnSkillCallBack)
end

function NPCActionGetBloodMagic:OnDisconnect()
  if self.Skill then
    self.Skill:CancelSkill(UE4.ESkillActionResult.SkillActionResultInterrupted)
  end
end

function NPCActionGetBloodMagic:OnInterrupt()
  if self.OpenBloodMagicFlag then
    _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.CloseBloodMagic)
  end
end

function NPCActionGetBloodMagic:OnSkillCallBack(skillProxy, result)
  if result ~= UE4.ESkillStartResult.Success then
    Log.Error("NPCActionGetBloodMagic failed to play skill!", result, skillProxy)
    self:Finish(false)
  end
end

function NPCActionGetBloodMagic:PauseSkill(name, skill)
  if UE4.UObject.IsValid(skill) then
    skill:SetPlayRate(0)
  end
  _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.OpenBloodMagic, self)
  self.OpenBloodMagicFlag = true
end

function NPCActionGetBloodMagic:CloseMagicUmg()
  local skillObject = self.Skill.SkillObject
  if UE4.UObject.IsValid(skillObject) then
    skillObject:SetPlayRate(1)
  end
end

function NPCActionGetBloodMagic:OnFinish()
  self:Finish(true)
end

function NPCActionGetBloodMagic:Finish(success)
  if self.LoadQueue then
    self.LoadQueue:DoRelease()
    self.LoadQueue = nil
  end
  if self.LuoPan then
    self.LuoPan:Destroy()
    self.LuoPan = nil
  end
  self.OpenBloodMagicFlag = false
  self.Skill = nil
  Base.Finish(self, success)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisconnect)
  _G.NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_RECONNECT_FINISH, self.OnFinish)
end

return NPCActionGetBloodMagic
