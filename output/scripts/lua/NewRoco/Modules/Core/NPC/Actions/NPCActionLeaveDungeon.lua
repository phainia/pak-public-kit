local Base = require("NewRoco.Modules.Core.NPC.Actions.NPCActionAsyncBase")
local NPCActionLeaveDungeon = Base:Extend("NPCActionLeaveDungeon")

function NPCActionLeaveDungeon:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
  self.TeleportID = tonumber(self.Config.action_param1) or 0
  self.bWithConfirm = string.IsNilOrEmpty(self.Config.action_param2)
  self.bShouldPlayPerform = tonumber(self.Config.action_param3)
end

local ResList = {
  Skill = "/Game/ArtRes/Effects/G6Skill/SceneEffect/Stele/G6_Scene_Stele_Leave_Start.G6_Scene_Stele_Leave_Start_C"
}

function NPCActionLeaveDungeon:GetPerformResourceList()
  if 1 ~= self.bShouldPlayPerform and self.bWithConfirm then
    return nil
  else
    return ResList
  end
end

function NPCActionLeaveDungeon:OnPerformReady(LoadedAssets, Rsp)
  local NPCView = self:GetOwnerNPCView()
  if 1 ~= self.bShouldPlayPerform and self.bWithConfirm then
    if NPCView and NPCView.PlayUseEffect then
      NPCView:PlayUseEffect(self)
    else
      _G.NRCModuleManager:DoCmd(_G.InstanceModuleCmd.OpenLeavePanel, self)
    end
  else
    local Player = self:GetPlayer()
    local SkillComp = Player.viewObj.RocoSkill
    local Skill = SkillComp:FindOrAddSkillObj(LoadedAssets.Skill)
    Skill:SetCaster(Player.viewObj)
    Skill:SetTargets({NPCView})
    Skill.BattleGenderType = _G.DataModelMgr.PlayerDataModel.playerInfo.brief_info.sex
    Skill:RegisterEventCallback("Recycle", self, self.OnPlayWhiteScreen)
    Skill:RegisterEventCallback("End", self, self.OnPrePerformEnd)
    Skill:PlaySkill(self, self.OnSkillCallBack)
  end
end

function NPCActionLeaveDungeon:OnPerformFailed(Reason)
end

function NPCActionLeaveDungeon:OnSkillCallBack(skillProxy, result)
  if result ~= UE4.ESkillStartResult.Success then
    Log.Error("NPCActionLeaveDungeon failed to play skill!", result, skillProxy)
    self:SkillFailed()
  end
end

function NPCActionLeaveDungeon:OnPlayWhiteScreen()
  self:Finish()
  _G.NRCEventCenter:DispatchEvent(NRCGlobalEvent.OPEN_WHITE_SCREEN)
end

function NPCActionLeaveDungeon:OnPrePerformEnd()
  local Request = _G.ProtoMessage:newZoneExitDungeonReq()
  Request.teleport_id = self.TeleportID
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_EXIT_DUNGEON_REQ, Request, self, self.OnLeaveDungeonRsp)
end

function NPCActionLeaveDungeon:OnLeaveDungeonRsp(rsp)
  local InstanceModule = _G.NRCModuleManager:GetModule("InstanceModule")
  if InstanceModule then
    InstanceModule:OnLeaveDungeonRsp(rsp)
  end
end

function NPCActionLeaveDungeon:Finish(success, data, param)
  if self.bWithConfirm then
    local NPCView = self:GetOwnerNPCView()
    if NPCView and NPCView.OnActionFinish then
      NPCView:OnActionFinish(self)
    end
  end
  Base.Finish(self, success, data, param)
end

return NPCActionLeaveDungeon
