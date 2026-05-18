local PetMutationUtils = require("NewRoco.Utils.PetMutationUtils")
local Base = require("NewRoco.AI.BehaviorTree.LuaDecoratorBase")
local LuaDecoratorReactionDecision = Base:Extend("LuaActionExternalDecision")

function LuaDecoratorReactionDecision:OnStart(owner, ...)
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local ridingPet = localPlayer.viewObj.BP_RideComponent.ScenePet
  local pet_gid
  if ridingPet then
    pet_gid = ridingPet
  else
    pet_gid = owner.Npc.module.SceneAIManager._cachedLastThrowPetGid
  end
  local PetData = _G.DataModelMgr.PlayerDataModel:GetPetDataByGid(pet_gid)
  if not PetData then
    Log.PrintScreenMsg("[NPCReaction] decision: cant find valid pet")
    return self:Finish(false)
  end
  local npcGroup = tonumber(owner.Npc.config.npc_group_id)
  local is_awesome = PetData.talent_rank == _G.Enum.PetTalentRate.PTR_PERFECT
  local is_alterchromo = PetMutationUtils.GetMutationValue(PetData.mutation_type, _G.Enum.MutationDiffType.MDT_SHINING)
  local is_rainbow = PetMutationUtils.GetMutationValue(PetData.mutation_type, _G.Enum.MutationDiffType.MDT_GLASS)
  Log.PrintScreenMsg("[NPCReaction] decision: fetching with pet gid=%d, is_awesome=%s, is_alterchromo=%s, is_rainbow=%s by npc_group=%d", pet_gid, tostring(is_awesome), tostring(is_alterchromo), tostring(is_rainbow), npcGroup)
end

return LuaDecoratorReactionDecision
