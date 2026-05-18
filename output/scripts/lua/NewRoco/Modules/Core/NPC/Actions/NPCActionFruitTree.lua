local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionModelBase")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local RocoSkillProxy = require("NewRoco.Utils.RocoSkillProxy")
local ResQueue = require("NewRoco.Utils.ResQueue")
local TipsModuleEvent = require("NewRoco.Modules.System.TipsModule.TipsModuleEvent")
local Base = NPCActionBase
local NPCActionFruitTree = Base:Extend("NPCActionFruitTree")

function NPCActionFruitTree:Ctor(Owner, Config, Info, OwnerNpc)
  Base.Ctor(self, Owner, Config, Info, OwnerNpc)
  self.shouldSync = true
  _G.NRCEventCenter:RegisterEvent("NPCActionFruitTree", self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisConnect)
end

function NPCActionFruitTree:ExecuteWithModel()
  if self.npcSyncInfo and self.npcSyncInfo.act_exec_success then
    self:OtherPrePlaySkill()
  elseif self.Info and self.Info.act_exec_success then
    local CurPlayerPos = self:GetPlayer():GetActorLocation()
    local CurTreePos = self.OwnerNpc:GetActorLocation()
    self.PlayerPos = self:GetPointInDirection(CurPlayerPos, CurTreePos, 200)
    self:PrePlaySkill()
  else
    self:Finish(true)
  end
end

function NPCActionFruitTree:OtherPrePlaySkill()
  self.LoadQueue = ResQueue(30, ResQueue.RunMode.Concurrent, _G.PriorityEnum.Passive_3P_Action)
  self.LoadQueue:InsertNPC("Book", 660101)
  self.LoadQueue:StartLoad(self, self.OtherPlayGrowSkill)
end

function NPCActionFruitTree:OtherPlayGrowSkill(Queue, Success)
  if not Success then
    self:Finish(false)
    return
  end
  local Owner = self:GetOwnerNPC()
  local OwnerView = self:GetOwnerNPCView()
  local Player = self:GetPlayer()
  if not (Owner and Player) or not OwnerView then
    self:Finish(false)
    return
  end
  local SkillPath = "/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Tree_Growth_OtherPlayers.G6_Tree_Growth_OtherPlayers"
  self.Skill = RocoSkillProxy.Create(SkillPath, OwnerView.RocoSkill, PriorityEnum.Active_Player_Action)
  if not self.Skill then
    self:Finish(false)
    return
  end
  SceneUtils.LookAt(Player, Owner)
  self.Book = Queue:Get("Book")
  local Characters = {}
  Characters[UE4.EBattleStaticActorType.Pet_2_1] = OwnerView
  self.Skill:SetCaster(Player.viewObj)
  self.Skill:SetTargets({
    self.Book.viewObj
  })
  self.Skill:SetCharacters(Characters)
  self.Skill:RegisterEventCallback("PreStart", self, self.OnSetupBlackboard)
  self.Skill:RegisterEventCallback("ChangeMesh", self, self.OnChangeMesh)
  self.Skill:RegisterEventCallback("End", self, self.OnSkillFinished)
  self.Skill:RegisterEventCallback("Interrupt", self, self.OnSkillInterrupted)
  self.Skill:RegisterEventCallback("RevertTree", self, self.OnRevertTree)
  self.Skill:PlaySkill()
end

function NPCActionFruitTree:PrePlaySkill()
  self.LoadQueue = ResQueue(30, ResQueue.RunMode.Concurrent, _G.PriorityEnum.Active_Player_Action)
  self.LoadQueue:InsertNPC("Book", 660101)
  self.LoadQueue:StartLoad(self, self.PlayGrowSkill)
end

function NPCActionFruitTree:FindClosestPoint(A, B, radius)
  local x1, y1 = A.X, A.Y
  local x2, y2 = B.X, B.Y
  local dx = x2 - x1
  local dy = y2 - y1
  local distance = math.sqrt(dx * dx + dy * dy)
  local unit_dx, unit_dy = 0, 0
  if 0 ~= distance then
    unit_dx = dx / distance
    unit_dy = dy / distance
  end
  local closest_x = x1 + unit_dx * radius
  local closest_y = y1 + unit_dy * radius
  return UE4.FVector(closest_x, closest_y, B.Z)
end

function NPCActionFruitTree:GetPointInDirection(A, B, distance)
  local dx = A.X - B.X
  local dy = A.Y - B.Y
  local length = math.sqrt(dx * dx + dy * dy)
  if 0 == length then
    return B
  end
  local unit_dx = dx / length
  local unit_dy = dy / length
  return UE4.FVector(B.X + unit_dx * distance, B.Y + unit_dy * distance, B.Z)
end

function NPCActionFruitTree:PlayGrowSkill(Queue, Success)
  if not Success then
    self:Finish(false)
    return
  end
  local Owner = self:GetOwnerNPC()
  local OwnerView = self:GetOwnerNPCView()
  local Player = self:GetPlayer()
  if not Owner or not Player then
    self:Finish(false)
    return
  end
  if Player and UE.UObject.IsValid(Player.viewObj) then
    Player:UnLinkHand()
    Player.movementComponent:SetSyncMove(false)
    Player.viewObj.Mesh:SetEnableGravity(false)
    Player:SetCharacterMovementTickEnable(self, false)
    Player.viewObj.CharacterMovement:SetMovementMode(UE.EMovementMode.MOVE_None)
    Player.viewObj.CharacterMovement:DisableMovement()
  end
  local SkillPath = "/Game/ArtRes/Effects/G6Skill/SceneEffect/G6_Tree_Growth_All.G6_Tree_Growth_All"
  self.Skill = RocoSkillProxy.Create(SkillPath, OwnerView.RocoSkill, PriorityEnum.Active_Player_Action)
  if not self.Skill then
    self:Finish(false)
    return
  end
  self.Book = Queue:Get("Book")
  local Characters = {}
  Characters[UE4.EBattleStaticActorType.Pet_2_1] = OwnerView
  self.Skill:SetCaster(Player.viewObj)
  self.Skill:SetTargets({
    self.Book.viewObj
  })
  self.Skill:SetCharacters(Characters)
  self.Skill:RegisterEventCallback("PreStart", self, self.OnSetupBlackboard)
  self.Skill:RegisterEventCallback("ChangeMesh", self, self.OnChangeMesh)
  self.Skill:RegisterEventCallback("ShowTipsUI", self, self.OnShowTipsUI)
  self.Skill:RegisterEventCallback("HideTipsUI", self, self.OnHideTipsUI)
  self.Skill:RegisterEventCallback("RevertPlayer", self, self.OnSkillRevertPlayer)
  self.Skill:RegisterEventCallback("End", self, self.OnSkillFinished)
  self.Skill:RegisterEventCallback("Interrupt", self, self.OnSkillInterrupted)
  self.Skill:PlaySkill()
end

function NPCActionFruitTree:OnSetupBlackboard(Name, Skill)
  local ContentID = self.OwnerNpc.serverData.npc_base.npc_content_cfg_id
  if ContentID and 0 ~= ContentID then
    local Conf = _G.DataConfigManager:GetFruitTreeConf(ContentID)
    if Conf then
      if 1 == Conf.book_id then
        Skill.Blackboard:SetValueAsString("MI_UI_Book01", "MI_UI_Book01")
      elseif 4 == Conf.book_id then
        Skill.Blackboard:SetValueAsString("MI_UI_Book02", "MI_UI_Book02")
      elseif 2 == Conf.book_id then
        Skill.Blackboard:SetValueAsString("MI_UI_Book03", "MI_UI_Book03")
      elseif 3 == Conf.book_id then
        Skill.Blackboard:SetValueAsString("MI_UI_Book04", "MI_UI_Book04")
      end
    end
  end
end

function NPCActionFruitTree:OnSkillFinished()
  self:Finish(true)
end

function NPCActionFruitTree:OnCommit(rsp)
  if 0 == rsp.ret_info.ret_code then
  end
  if self.Book then
    self.Book:Destroy()
    self.Book = nil
  end
  if self.LoadQueue then
    self.LoadQueue:DoRelease()
    self.LoadQueue = nil
  end
  Base.OnCommit(self, rsp)
end

function NPCActionFruitTree:OnSkillRevertPlayer()
  local Player = self:GetPlayer()
  if Player and UE.UObject.IsValid(Player.viewObj) then
    local PlayerController = Player:GetUEController()
    if PlayerController and UE.UObject.IsValid(PlayerController) then
      PlayerController:ReleaseRocoCamera()
    end
    self.PlayerPos = SceneUtils.GetPosInLand(self.PlayerPos, Player:GetHalfHeight(), 300, 1000, {}, {}, nil, true, true)
    Player:SetActorLocation(self.PlayerPos)
    SceneUtils.LookAt(Player, self:GetOwnerNPC())
    Player.viewObj.Mesh:SetEnableGravity(true)
    Player:SetCharacterMovementTickEnable(self, true)
    Player.viewObj.CharacterMovement:SetMovementMode(UE.EMovementMode.MOVE_Walking)
    Player:ReLinkHand()
    Player.movementComponent:SetSyncMove(true)
  end
  self:OnRevertTree()
end

function NPCActionFruitTree:OnRevertTree()
  local OwnerView = self:GetOwnerNPCView()
  if not OwnerView then
    return
  end
  OwnerView:SetVatMesh(false)
  OwnerView:UpdateState(true)
end

function NPCActionFruitTree:OnSkillInterrupted()
  self:OnSkillRevertPlayer()
  self:OnSkillFinished()
end

function NPCActionFruitTree:OnChangeMesh()
  local OwnerView = self:GetOwnerNPCView()
  if not OwnerView then
    return
  end
  OwnerView:SetVatMesh(true)
end

function NPCActionFruitTree:OnShowTipsUI()
  local Params = {}
  local ContentID = self.OwnerNpc.serverData.npc_base.npc_content_cfg_id
  if ContentID and 0 ~= ContentID then
    local Conf = _G.DataConfigManager:GetFruitTreeConf(ContentID)
    if Conf then
      Params.AreaName = string.format("%s%s", Conf.area, LuaText.book_exam)
      Params.TotalCount = Conf.pet_num
    end
  end
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.OpenFruitTreeTips, Params)
end

function NPCActionFruitTree:OnHideTipsUI()
  _G.NRCEventCenter:DispatchEvent(TipsModuleEvent.FinishFruitTreeTips)
end

function NPCActionFruitTree:OnDisConnect()
  if self.Skill then
    self.Skill:CancelSkill(UE.ESkillActionResult.SkillActionResultInterrupted)
  end
end

function NPCActionFruitTree:Destroy()
  NRCEventCenter:UnRegisterEvent(self, _G.NRCGlobalEvent.ON_DISCONNECT, self.OnDisConnect)
  Base.Destroy(self)
end

return NPCActionFruitTree
