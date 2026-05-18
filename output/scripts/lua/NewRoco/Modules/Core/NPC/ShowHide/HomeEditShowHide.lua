local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local Super = require("NewRoco.Modules.Core.NPC.ShowHide.ShowHideBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local HomeEditShowHide = Super:Extend("HomeEditShowHide")

function HomeEditShowHide:GetReason()
  return NPCModuleEnum.NpcReasonFlags.HOME_EDIT_FLAG
end

function HomeEditShowHide:StartHide()
  local Sandbox = _G.HomeIndoorSandbox
  self.LastEditRoomId = Sandbox and Sandbox.HomeEditServ.EditRoomId or 0
  return true
end

function HomeEditShowHide:CheckIfNeedIgnoreNpc(npc)
  local Module = _G.HomeIndoorSandbox and _G.HomeIndoorSandbox.Module
  if Module and Module.data and npc and npc.config then
    local Data = Module.data
    return Data:IfNeedIgnoreNpcDuringEditingHome(npc.config.id)
  end
end

function HomeEditShowHide:CheckShouldHide(npc)
  if not npc then
    return false
  end
  if npc.FurnitureID then
    return false
  end
  if npc.AIComponent then
    npc.AIComponent:ForceLockForReason(true, false, AIDefines.LockReason.HOME_EDIT)
  end
  if self:CheckIfNeedIgnoreNpc(npc) then
    npc:SetCollisionDisable(true, NPCModuleEnum.NpcReasonFlags.HOME_EDIT_FLAG)
    return false
  end
  return true
end

function HomeEditShowHide:CheckShouldShow(npc)
  if npc then
    if self:CheckIfNeedIgnoreNpc(npc) then
      npc:SetCollisionDisable(false, NPCModuleEnum.NpcReasonFlags.HOME_EDIT_FLAG)
      return false
    end
    local isHomeNpc = npc.config.npc_role_type == Enum.PetRoleTypeInNPCConf.PRTINC_HOME
    local isFollowNpc = npc.config.npc_role_type == Enum.PetRoleTypeInNPCConf.PRTINC_FOLLOW
    if isHomeNpc or isFollowNpc then
      local Room = _G.HomeIndoorSandbox.World:GetRoomById(self.LastEditRoomId)
      local cellType = 2
      local NpcAbsPos = npc:GetActorLocation()
      for _, Plane in pairs(Room.HomePlanes) do
        if not Plane:IsWall() then
          local type = Plane:IndicatePosToCell(NpcAbsPos)
          if 1 == type then
            cellType = type
            break
          end
        end
      end
      if 1 == cellType then
        if isHomeNpc then
          Log.Debug("\229\174\182\229\133\183\230\140\161\228\189\143\228\186\134\229\174\182\229\155\173\231\178\190\231\129\181\239\188\140\233\135\141\231\189\174\228\189\141\231\189\174", npc.config.name)
          local hh = npc:GetScaledHalfHeight()
          local eggOnNest = npc:IsLogicStatus(Enum.SpaceActorLogicStatus.SALS_HOME_PET_HOLD_EGG)
          local teleportPos
          if eggOnNest then
            teleportPos = self:GetRandomPosBesideNest(npc) or npc.landPos
          else
            teleportPos = npc.landPos
          end
          local land_pt = SceneUtils.GetPosInLand(teleportPos, hh + 0.1, hh * 2, hh * 10)
          if land_pt then
            npc:TeleportToPos(land_pt)
          end
          self:MakeNpcMovementFalling(npc)
        else
          Log.Debug("\229\174\182\229\133\183\230\140\161\228\189\143\228\186\134\230\138\149\230\142\183\231\178\190\231\129\181\239\188\140\229\155\158\230\148\182", npc.config.name)
          if npc.ThrowSession then
            npc.ThrowSession:ForceRecycle(ProtoEnum.RecycleThrowPetReason.RTPR_None)
          end
        end
      else
        self:MakeNpcMovementFalling(npc)
      end
    end
    if npc.AIComponent then
      npc.AIComponent:ForceLockForReason(false, false, AIDefines.LockReason.HOME_EDIT)
    end
  end
  return true
end

function HomeEditShowHide:MakeNpcMovementFalling(npc)
  local moveComp = npc.viewObj and npc.viewObj.CharacterMovement
  if moveComp and moveComp:IsMovingOnGround() then
    moveComp:SetMovementMode(UE4.EMovementMode.MOVE_Falling)
  end
end

function HomeEditShowHide:GetRandomPosBesideNest(npc)
  local nest_guid = npc.serverData.home_pet.home_pet_info.furniture_guid
  local nest_data = _G.HomeIndoorSandbox.Utils.GetPropDataById(nest_guid)
  if not nest_data then
    return nil
  end
  local ground_plane = nest_data.RealtimePlane
  if not ground_plane then
    local located_room = _G.HomeIndoorSandbox.World:GetRoomById(nest_data.RoomId)
    if not located_room then
      return nil
    end
    ground_plane = located_room:GetPlaneByActorId(nest_data.PlaneMasterId)
  end
  if not ground_plane then
    return nil
  end
  if not ground_plane.QueryRandomReachableCell then
    return nil
  end
  local pt = ground_plane:QueryPropsEdgeValidCell(nest_data)
  if pt then
    return pt
  end
  return nil
end

return HomeEditShowHide
