local ActorComponent = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local Base = ActorComponent
local CatchRecordComponent = Base:Extend("CatchRecordComponent")

function CatchRecordComponent:Ctor()
  self.evoChainRecord = {}
  self.habitatRecord = {}
end

function CatchRecordComponent:Attach(owner)
  Base.Attach(self, owner)
  self:UpdateRecord(owner.serverData.catch_record_info)
end

function CatchRecordComponent:DeAttach()
  self.owner = nil
end

function CatchRecordComponent:UpdateData(ServerData, isReconnect)
  self:UpdateRecord(ServerData.catch_record_info)
end

function CatchRecordComponent:UpdateRecord(info)
  local catch_info = info and info.catch_info
  if not catch_info then
    return
  end
  local context = UE4Helper.GetCurrentWorld()
  if not context then
    return
  end
  self.evoChainRecord = {}
  self.habitatRecord = {}
  if catch_info.evolution_chain_catch_record_datas then
    self:ApplyEvoChainRecord(catch_info.evolution_chain_catch_record_datas, context)
  end
  if catch_info.habitat_catch_record_datas then
    self:ApplyHabitatRecord(catch_info.habitat_catch_record_datas, context)
  end
end

function CatchRecordComponent:OnRecordInfoChange(action)
  if action.del_evolution_chain_ids then
    for _, id in ipairs(action.del_evolution_chain_ids) do
      self.evoChainRecord[id] = nil
    end
  end
  if action.del_habitat_ids then
    for _, id in ipairs(action.del_habitat_ids) do
      self.habitatRecord[id] = nil
    end
  end
  local catch_info = action.catch_record_datas
  if not catch_info then
    return
  end
  local context = UE4Helper.GetCurrentWorld()
  if catch_info.evolution_chain_catch_record_datas then
    self:ApplyEvoChainRecord(catch_info.evolution_chain_catch_record_datas, context)
  end
  if catch_info.habitat_catch_record_datas then
    self:ApplyHabitatRecord(catch_info.habitat_catch_record_datas, context)
  end
end

function CatchRecordComponent:ApplyEvoChainRecord(records, context_hint)
  local context = context_hint or UE4Helper.GetCurrentWorld()
  for _, evo_data in ipairs(records) do
    self.evoChainRecord[evo_data.evolution_chain_id] = evo_data
    UE.UUnitAIHelper.SetBatchBlackboardValueInt(context, _G.AIDefines.DotsBatchFilterType.EVOCHAIN, evo_data.evolution_chain_id, _G.AIDefines.DotsBlackboardKeyBundle.EvoChainCatchRecord, {
      evo_data.acc_try_catch_time,
      evo_data.acc_catch_succ_time,
      evo_data.acc_catch_fail_time
    })
  end
end

function CatchRecordComponent:ApplyHabitatRecord(records, context_hint)
  local context = context_hint or _G.UE4Helper.GetCurrentWorld()
  for _, hab_data in ipairs(records) do
    self.habitatRecord[hab_data.habitat_id] = hab_data
    UE.UUnitAIHelper.SetBatchBlackboardValueInt(context, _G.AIDefines.DotsBatchFilterType.COLLECTION, hab_data.habitat_id, _G.AIDefines.DotsBlackboardKeyBundle.HabitatCatchRecord, {
      hab_data.acc_try_catch_time,
      hab_data.acc_catch_succ_time,
      hab_data.acc_catch_fail_time,
      hab_data.exist_npc_num,
      hab_data.can_refresh_npc_num
    })
  end
end

return CatchRecordComponent
