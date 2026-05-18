local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local OwlStarStorageComponent = Base:Extend("OwlStarStorageComponent")

function OwlStarStorageComponent:Ctor()
  Base.Ctor(self)
  self._owlStarInfos = nil
end

function OwlStarStorageComponent:AddOwlStarInfo(owlStarInfo)
  if self._owlStarInfos == nil then
    self._owlStarInfos = {}
  end
  if nil == owlStarInfo then
    return
  end
  for _, info in ipairs(self._owlStarInfos) do
    if info.npc_obj_id == owlStarInfo.npc_obj_id and info.npc_cfg_id == owlStarInfo.npc_cfg_id then
      Log.WarningFormat("npc_obj_id: %d npc_content_id: %d already exist", owlStarInfo.npc_obj_id, owlStarInfo.npc_cfg_id)
      return
    end
  end
  table.insert(self._owlStarInfos, owlStarInfo)
end

function OwlStarStorageComponent:RemoveOwlStarInfo(npc_obj_id, npc_cfg_id)
  if self._owlStarInfos == nil then
    return
  end
  local indexToRemove = -1
  for index, info in ipairs(self._owlStarInfos) do
    if info.npc_obj_id == npc_obj_id and info.npc_cfg_id == npc_cfg_id then
      indexToRemove = index
      break
    end
  end
  if indexToRemove > 0 and indexToRemove <= table.len(self._owlStarInfos) then
    table.remove(self._owlStarInfos, indexToRemove)
  end
end

function OwlStarStorageComponent:UpdateOwlStarDistanceState(npc_obj_id, npc_cfg_id, in_distance_range)
  if self._owlStarInfos == nil then
    return nil
  end
  for _, info in ipairs(self._owlStarInfos) do
    if info.npc_obj_id == npc_obj_id and info.npc_cfg_id == npc_cfg_id then
      info.in_distance_range = in_distance_range
      return info
    end
  end
  return nil
end

function OwlStarStorageComponent:GetOwlStarInfos()
  return self._owlStarInfos
end

return OwlStarStorageComponent
