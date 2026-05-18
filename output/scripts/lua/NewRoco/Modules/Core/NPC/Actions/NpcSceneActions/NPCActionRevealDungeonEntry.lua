local Base = require("NewRoco.Modules.Core.NPC.Actions.NPCActionAsyncBase")
local NPCActionRevealDungeonEntry = Base:Extend("NPCActionRevealDungeonEntry")

function NPCActionRevealDungeonEntry:Ctor(Owner, Config, Info, OwnerNpc)
  Base.Ctor(self, Owner, Config, Info, OwnerNpc)
  self.shouldSync = true
end

function NPCActionRevealDungeonEntry:Execute(playerId, needSendReq)
  Base.Execute(self, playerId, needSendReq)
  local Portal = self:GetOwnerNPCView()
  if Portal then
    Portal.opened = true
  end
  if self:IsLocalAction() then
    local Player = self:GetPlayer()
    if Player then
      Player:FaceTo(self:GetOwnerNPC())
      if Player.inputComponent then
        Player.inputComponent:SetInputEnable(self, false)
      end
    end
    _G.NRCModeManager:GetCurMode():DisablePanelByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
  end
end

local ResList = {
  Skill = "/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Open_Dong.G6_Open_Dong_C",
  OpenNiagara = "NiagaraSystem'/Game/ArtRes/Effects/Particle/Res/NS_Scene_Door_Open_show02.NS_Scene_Door_Open_show02'"
}

function NPCActionRevealDungeonEntry:GetPerformResourceList()
  if self:IsLocalAction() then
    return ResList
  else
    return nil
  end
end

function NPCActionRevealDungeonEntry:OnPerformReady(LoadedAssets, _)
  if self:IsLocalAction() then
    local skillComponent = self:GetOwnerNPCView().RocoSkill
    local SkillObj = skillComponent:FindOrAddSkillObj(LoadedAssets.Skill)
    SkillObj:SetCaster(self:GetOwnerNPCView())
    SkillObj:SetTargets({})
    SkillObj:RegisterEventCallback("ActivateFailed", self, self.OnSkillComplete)
    SkillObj:RegisterEventCallback("Interrupt", self, self.OnSkillComplete)
    SkillObj:RegisterEventCallback("End", self, self.OnSkillComplete)
    SkillObj:RegisterEventCallback("Unlock", self, self.UnlockDungeonEntry)
    skillComponent:StopCurrentSkill()
    local Result = skillComponent:LoadAndPlaySkill(SkillObj)
    if Result ~= UE.ESkillStartResult.Success then
      self:UnlockDungeonEntry()
      self:Finish(true)
    end
  else
    self:UnlockDungeonEntry()
    self:Finish(false)
  end
end

function NPCActionRevealDungeonEntry:OnPerformFailed(Reason)
  if self:IsNotServerFailed(Reason) then
    self:UnlockDungeonEntry()
    self:Finish(true)
  else
    local Portal = self:GetOwnerNPCView()
    if Portal then
      Portal.opened = false
    end
    self.SkipCommit = true
    self:Finish(false)
    self.SkipCommit = false
  end
end

function NPCActionRevealDungeonEntry:UnlockDungeonEntry()
  local Portal = self:GetOwnerNPCView()
  if Portal then
    Portal:Opening()
  end
end

function NPCActionRevealDungeonEntry:OnSkillComplete()
  self:Finish(true)
end

function NPCActionRevealDungeonEntry:Finish(success, data, param)
  if self:IsLocalAction() then
    local Player = self:GetPlayer()
    if Player and Player.inputComponent then
      Player.inputComponent:SetInputEnable(self, true)
    end
    _G.NRCModeManager:GetCurMode():RevertPanelEnableStateByLayer(_G.Enum.UILayerType.UI_LAYER_MAIN)
  end
  if success then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.LuaText.Dungeon_Unlock)
  end
  Base.Finish(self, success, data, param)
end

return NPCActionRevealDungeonEntry
