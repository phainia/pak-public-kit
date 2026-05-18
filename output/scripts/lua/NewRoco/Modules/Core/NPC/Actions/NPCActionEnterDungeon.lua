local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local Base = NPCActionBase
local NPCActionEnterDungeon = Base:Extend("NPCActionEnterDungeon")

function NPCActionEnterDungeon:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
  self.AutoEnter = false
end

function NPCActionEnterDungeon:Execute()
  local InstanceID = tonumber(self.Config.action_param1)
  local bShouldPlayPerform = tonumber(self.Config.action_param2)
  local Conf = _G.DataConfigManager:GetDungeonConf(InstanceID)
  if not Conf then
    Log.Error("\232\191\153\228\184\170\229\137\175\230\156\172\229\133\165\229\143\163\231\154\132\233\133\141\231\189\174\230\156\137\233\151\174\233\162\152, \230\137\190\228\184\141\229\136\176\229\175\185\229\186\148\231\154\132\229\137\175\230\156\172!")
    return
  end
  local Ban = _G.FunctionBanManager:GetFunctionState(_G.Enum.PlayerFunctionBanType.PFBT_ENTER_DUNGEON, true, true)
  if Ban then
    self.Owner:SetNeedStatusNotify(false)
    return
  end
  if Conf.has_enter_ui then
    self.AutoEnter = false
    if self.SkipSubmit then
      _G.NRCProfilerLog:NRCClickBtn(true, "InstanceModuleEnterPanel")
      _G.NRCModuleManager:DoCmd(_G.InstanceModuleCmd.OpenEnterPanel, self, InstanceID)
    end
  elseif self.SkipSubmit then
    if 1 == bShouldPlayPerform then
      self:PlayEnterPerform()
    else
      self:Finish(true, nil, "0")
    end
  else
    self.AutoEnter = true
  end
  Base.Execute(self)
end

function NPCActionEnterDungeon:OnSubmit(rsp)
  Base.OnSubmit(self, rsp)
  if 0 == rsp.ret_info.ret_code then
    local InstanceID = tonumber(self.Config.action_param1)
    local Conf = _G.DataConfigManager:GetDungeonConf(InstanceID)
    if Conf.has_enter_ui then
      _G.NRCProfilerLog:NRCClickBtn(true, "InstanceModuleEnterPanel")
      _G.NRCModuleManager:DoCmd(_G.InstanceModuleCmd.OpenEnterPanel, self, InstanceID)
    end
  else
    self:Finish(false, nil, "0")
  end
  if not self.AutoEnter then
    return
  end
  self.AutoEnter = false
  self:Finish(true, nil, "0")
end

function NPCActionEnterDungeon:PlayEnterPerform()
  local Player = self:GetPlayer()
  local NPC = self:GetOwnerNPC()
  local SkillComp = Player.viewObj.RocoSkill
  local Skill = RocoSkillProxy.Create("/Game/ArtRes/Effects/G6Skill/SceneEffect/Stele/G6_Scene_Stele_Open_Start", SkillComp, PriorityEnum.Active_Player_Action)
  Skill:SetCaster(Player.viewObj)
  Skill:SetTargets({
    NPC.viewObj
  })
  Skill:RegisterEventCallback("PreStart", self, self.OnSetupBlackboard)
  Skill:RegisterEventCallback("Recycle", self, self.OnPlayWhiteScreen)
  Skill:RegisterEventCallback("End", self, self.OnPrePerformEnd)
  Skill:PlaySkill(self, self.OnSkillCallBack)
end

function NPCActionEnterDungeon:OnSetupBlackboard(Name, Skill)
  if not Skill or not Skill.Blackboard then
    return
  end
  Skill.BattleGenderType = _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.sex
end

function NPCActionEnterDungeon:OnSkillCallBack(skillProxy, result)
  if result ~= UE4.ESkillStartResult.Success then
    Log.Error("NPCActionEnterDungeon failed to play skill!", result, skillProxy)
    self:SkillFailed()
  end
end

function NPCActionEnterDungeon:OnPlayWhiteScreen()
  _G.NRCEventCenter:DispatchEvent(NRCGlobalEvent.OPEN_WHITE_SCREEN)
end

function NPCActionEnterDungeon:OnPrePerformEnd()
  self:Finish(true, nil, "0")
end

function NPCActionEnterDungeon:OnCommit(rsp)
  Base.OnCommit(self, rsp)
  if 0 ~= rsp.ret_info.ret_code then
    _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.RemoveInputBlockMappingContext, "InstanceModule:SwitchDungeonEnd")
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.CloseInputBlocker)
  end
end

return NPCActionEnterDungeon
