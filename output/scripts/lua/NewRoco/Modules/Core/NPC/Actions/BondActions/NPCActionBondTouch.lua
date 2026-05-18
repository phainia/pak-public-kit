local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local NPCModuleEnum = require("NewRoco.Modules.Core.NPC.NPCModuleEnum")
local Base = NPCActionBase
local NPCActionBondTouch = Base:Extend("NPCActionBondTouch")

function NPCActionBondTouch:Ctor(Owner, Config, Info, View)
  Base.Ctor(self, Owner, Config, Info, View)
  self.shouldSync = true
end

function NPCActionBondTouch:ExecuteWithModel()
  local localPlayer = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  local Player = self:GetPlayer()
  if localPlayer == Player then
    NRCModeManager:GetCurMode():DisablePanelByLayer(Enum.UILayerType.UI_LAYER_MAIN)
  end
  Player:RecordPlayerPos()
  self:UnLinkHand()
  local Pet = self:GetOwnerNPC()
  local PetView = self:GetOwnerNPCView()
  local interactionComponent = Pet and Pet.InteractionComponent
  if interactionComponent then
    interactionComponent:SetInteractionEnable(false, NPCModuleEnum.NpcInteractDisableFlag.ROLEPLAY)
  end
  local petHUDComponent = Pet and Pet.PetHUDComponent
  if petHUDComponent then
    petHUDComponent:SetPetBondVisible(false)
  end
  local HeadWidget = PetView and PetView.HeadWidget
  if HeadWidget and HeadWidget.ForceDrawWidgetTORenderTarget then
    HeadWidget:ForceDrawWidgetTORenderTarget()
  end
  local random_actions = string.split(self.Config.action_param1, ";")
  local random_index = math.random(1, #random_actions)
  local random_action = random_actions[random_index]
  Player:FaceTo(self:GetOwnerNPC())
  Pet:FaceTo(Player)
  local PlayerMesh = Player.viewObj:GetComponentByClass(UE4.USkeletalMeshComponent)
  local head_location = PlayerMesh:GetSocketLocation("locator_Head")
  local player_head_z = head_location.Z
  local CapsuleComponent = PetView:GetComponentByClass(UE4.UCapsuleComponent)
  local CapsuleLocation = PetView:Abs_K2_GetActorLocation()
  local CapsuleHalfHeight = CapsuleComponent:GetScaledCapsuleHalfHeight()
  local petHeight = CapsuleLocation.Z + CapsuleHalfHeight * 0.3
  local height_type
  if player_head_z > petHeight then
    height_type = "low"
  else
    height_type = "normal"
  end
  local skillPath = string.format("/Game/ArtRes/Effects/G6Skill/SceneEffect/Pet/touch/World_touch_%s_%s.World_touch_%s_%s", height_type, random_action, height_type, random_action)
  local SkillProxy = RocoSkillProxy.Create(skillPath, Player.viewObj.RocoSkill, PriorityEnum.Active_Player_Action)
  SkillProxy:SetCaster(Player.viewObj)
  SkillProxy:SetTargets({PetView})
  SkillProxy:RegisterEventCallback("End", self, self.OnTouchEnd)
  SkillProxy:SetPassive(false)
  SkillProxy:PlaySkill()
end

function NPCActionBondTouch:OnTouchEnd()
  local player = self:GetPlayer()
  if player and player:IsInTogetherMove() then
    player:RecoverPlayerPos()
  end
  local Pet = self:GetOwnerNPC()
  local interactionComponent = Pet and Pet.InteractionComponent
  if interactionComponent then
    interactionComponent:SetInteractionEnable(true, NPCModuleEnum.NpcInteractDisableFlag.ROLEPLAY)
  end
  self:ReLinkHand()
  self:Finish()
end

return NPCActionBondTouch
