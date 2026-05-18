local Base = require("NewRoco.Modules.Core.Scene.Component.Ability.AbilityBase")
local StartSpecialMoveAbility = Base:Extend("StartSpecialMoveAbility")

function StartSpecialMoveAbility:Init(abilityConf)
  Base.Init(self, abilityConf)
  self.swimmingMaxSpeedLimitRadio = 0.7
end

function StartSpecialMoveAbility:Start(onFinished, taskId)
  local player = self.caster
  if player.isLocal then
    Base.Start(self, onFinished)
    local taskStateConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.TASK_STATE_CONF):GetAllDatas()
    local showTime = _G.DataConfigManager:GetGlobalConfigByKeyType("task_state_tips_time", _G.DataConfigManager.ConfigTableId.GLOBAL_CONFIG).num
    if taskId and taskStateConf[taskId] and taskStateConf[taskId].begin_tips and taskStateConf[taskId].begin_tips ~= "" then
      _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, taskStateConf[taskId].begin_tips, nil, nil, showTime)
    end
    local moveComponent = player.viewObj:GetMovementComponent()
    moveComponent:SetEnableClimb(true)
    moveComponent:SetSwimmingMaxSpeedLimitRadio(self.swimmingMaxSpeedLimitRadio)
    player.viewObj:SetWalkRun(true)
  end
end

function StartSpecialMoveAbility:Recover(owner)
end

return StartSpecialMoveAbility
