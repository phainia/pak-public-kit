local MiracleExchangeModule = NRCModuleBase:Extend("MiracleExchangeModule")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")

function MiracleExchangeModule:OnConstruct()
  _G.MiracleExchangeModuleCmd = require("NewRoco.Modules.System.MiracleExchange.MiracleExchangeModuleCmd")
  self.data = self:SetData("MiracleExchangeModuleData", "NewRoco.Modules.System.MiracleExchange.MiracleExchangeModuleData")
end

function MiracleExchangeModule:OnActive()
  self:RegisterCmd(_G.MiracleExchangeModuleCmd.GetBallRandomPostionsInRadius, self.GetBallRandomPostionsInRadius)
  self:RegisterCmd(_G.MiracleExchangeModuleCmd.OpenMiracleExchange, self.OnCmdOpenMiracleExchange)
  self:RegisterCmd(_G.MiracleExchangeModuleCmd.SendMiracleExchange, self.OnCmdSendMiracleExchange)
  self:RegisterCmd(_G.MiracleExchangeModuleCmd.OpenMiracleExchangeMain, self.OnCmdOpenMiracleExchangeMain)
  self:RegisterCmd(_G.MiracleExchangeModuleCmd.SendSceneFinishMiracleChangeReq, self.OnCmdSendZoneSceneFinishMiracleChangeReq)
  self:RegisterCmd(_G.MiracleExchangeModuleCmd.OnMiracleMainPetSelectChange, self.OnCmdMiracleMainPetSelectChange)
  self:RegisterCmd(_G.MiracleExchangeModuleCmd.OnMiracleMainReversedSort, self.OnCmdMiracleMainReversedSort)
  self:RegisterCmd(_G.MiracleExchangeModuleCmd.OnMiracleMainSortTypeChanged, self.OnCmdOnMiracleMainSortTypeChanged)
  self:RegisterCmd(_G.MiracleExchangeModuleCmd.OnTypeChooseChanged, self.OnCmdTypeChooseChanged)
  self:RegisterCmd(_G.MiracleExchangeModuleCmd.OnTypeChooseBtnClicked, self.OnCmdTypeChooseBtnClicked)
  self:RegisterCmd(_G.MiracleExchangeModuleCmd.GetTypeChooseNum, self.OnCmdGetTypeChooseNum)
  self:RegisterCmd(_G.MiracleExchangeModuleCmd.HideMiraclesInRange, self.OnCmdHideMiraclesInRange)
  self:RegisterCmd(_G.MiracleExchangeModuleCmd.ReShowMiraclesInRange, self.OnCmdReShowMiraclesInRange)
  self:RegisterCmd(_G.MiracleExchangeModuleCmd.SetPetNewStateInfo, self.OnCmdSetPetNewStateInfo)
  self:RegisterCmd(_G.MiracleExchangeModuleCmd.PlayFinishSkill, self.PlayExchangeFinishSkill)
  self:RegPanel("MiracleExchange", "UMG_MiracleExchange", _G.Enum.UILayerType.UI_LAYER_POPUP)
  self:RegPanel("MiracleExchangeMain", "UMG_MiracleExchange_Main", _G.Enum.UILayerType.UI_LAYER_FULLSCREEN)
  _G.NRCEventCenter:RegisterEvent("MiracleExchangeModule", self, SceneEvent.OnRelogin, self.CloseBeginOpenPanel)
end

function MiracleExchangeModule:OnRelogin()
  self:CloseAllPanel()
end

function MiracleExchangeModule:OnDeactive()
end

function MiracleExchangeModule:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnRelogin, self.CloseBeginOpenPanel)
  self.d_InternalPlaySkill = _G.DelayManager:CancelDelayByIdEx(self.d_InternalPlaySkill)
end

function MiracleExchangeModule:OnCmdOpenMiracleExchange(_param)
  self:OpenPanel("MiracleExchange", _param)
end

function MiracleExchangeModule:OnCmdOpenMiracleExchangeMain(param)
  local isOpening, _ = self:HasPanel("MiracleExchangeMain")
  if not isOpening then
    self:OpenPanel("MiracleExchangeMain", param)
  else
    local panel = self:GetPanel("MiracleExchangeMain")
  end
end

function MiracleExchangeModule:RegPanel(name, path, layer)
  local registerData = _G.NRCPanelRegisterData()
  registerData.panelName = name
  registerData.panelPath = string.format("/Game/NewRoco/Modules/System/MiracleExchange/Res/%s", path)
  registerData.panelLayer = layer
  self:RegisterPanel(registerData)
end

function MiracleExchangeModule:OnCmdSendMiracleExchange(_petgid)
  local req = _G.ProtoMessage:newZoneSceneMiracleChangeReq()
  local randomPos, bAllSucc = self:GetBallRandomPostionsInRadius(#_petgid)
  if not bAllSucc then
    Log.Error("\229\165\135\232\191\185\228\186\164\230\141\162  \229\175\187\230\137\190\228\186\164\230\141\162\229\156\176\231\130\185\229\164\177\232\180\165\239\188\129\239\188\129\239\188\129\239\188\129 ", #_petgid, #randomPos)
    return
  end
  for i, petinfo in ipairs(_petgid) do
    local data = _G.ProtoMessage:newMiracleChangePetData()
    data.pet_gid = petinfo
    data.pt.pos.x = math.round(randomPos[i].X)
    data.pt.pos.y = math.round(randomPos[i].Y)
    data.pt.pos.z = math.round(randomPos[i].Z)
    data.pt.dir.z = 0
    data.pt.dir.y = 0
    data.pt.dir.x = 0
    table.insert(req.miracle_change_pets, data)
  end
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_MIRACLE_CHANGE_REQ, req, self, self.SendMiracleExchangeCallBack, true, true)
end

function MiracleExchangeModule:SendMiracleExchangeCallBack(rsp)
  if 0 ~= rsp.ret_info.ret_code then
    Log.Error("\229\165\135\232\191\185\228\186\164\230\141\162\233\148\153\232\175\175\231\160\129\239\188\154" .. tostring(rsp.ret_info.ret_code))
    local Key = string.format("Error_Code_%d", rsp.ret_info.ret_code)
    local ErrorText
    if RocoEnv.IS_SHIPPING or not RocoEnv.IS_EDITOR then
      ErrorText = LuaText[Key]
    else
      local ErrorCodeDesc = require("Data.PB.ErrorCodeDesc")
      ErrorText = ErrorCodeDesc[rsp.ret_info.ret_code] or LuaText[Key]
    end
    _G.ZoneServer:OpenDialog(LuaText.TIPS, ErrorText, LuaText.OK, nil, DialogContext.Mode.OK, nil, "ZoneSceneMiracleChangeRsp error : " .. rsp.ret_info.ret_code)
    return
  end
  if self:HasPanel("PetWarehousePanelMain") then
    local panel = self:GetPanel("PetWarehousePanelMain")
    panel:OnPetFreeSuccess()
  end
end

function MiracleExchangeModule:OnCmdSendZoneSceneFinishMiracleChangeReq(_petgid, _npcid, _petBallIds, _ballId, _npcAction)
  local req = _G.ProtoMessage:newZoneSceneFinishMiracleChangeReq()
  req.pet_gid = _petgid[1]
  req.npc_id = _npcid
  self.FormBallId = _petBallIds[1]
  self.ToBallId = _ballId
  self.NpcAction = _npcAction
  self.CacheMiracleInfo = nil
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_SCENE_FINISH_MIRACLE_CHANGE_REQ, req, self, self.ZoneSceneFinishMiracleChangeRsp, true, false)
end

function MiracleExchangeModule:ZoneSceneFinishMiracleChangeRsp(_rsp)
  if 0 == _rsp.ret_info.ret_code then
    local panel = self:GetPanel("MiracleExchangeMain")
    if panel then
      panel:OnCloseBtnClicked(true)
    end
    if _rsp.exchange_avatar_name and _rsp.obtained_pet_name then
      self.CacheMiracleInfo = {}
      self.CacheMiracleInfo.playerName = _rsp.exchange_avatar_name
      self.CacheMiracleInfo.petName = _rsp.obtained_pet_name
    end
  else
    self.CacheMiracleInfo = nil
    local Key = string.format("Error_Code_%d", _rsp.ret_info.ret_code)
    local ErrorText
    if RocoEnv.IS_SHIPPING or not RocoEnv.IS_EDITOR then
      ErrorText = LuaText[Key]
    else
      local ErrorCodeDesc = require("Data.PB.ErrorCodeDesc")
      ErrorText = ErrorCodeDesc[_rsp.ret_info.ret_code] or LuaText[Key]
    end
    _G.ZoneServer:OpenDialog(LuaText.TIPS, ErrorText, LuaText.OK, nil, DialogContext.Mode.OK, nil, "ZoneSceneFinishMiracleChangeRsp error : " .. _rsp.ret_info.ret_code)
  end
end

function MiracleExchangeModule:OnCmdMiracleMainPetSelectChange(_petgid, _PetData, _index)
  self.data.MiracleExchangeMainSelectPetGid = _petgid
  local panel = self:GetPanel("MiracleExchangeMain")
  if panel then
    panel:SelectItem(_petgid, _PetData, _index)
  end
end

function MiracleExchangeModule:GetBallRandomPostionsInRadius(num)
  local player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not player then
    return nil
  end
  local owner = player.viewObj
  local ownerPos = player.viewObj:ABS_K2_GetActorLocation()
  local radius = _G.DataConfigManager:GetGlobalConfigNumByKey("magic_change_range", 200)
  local hightRange = _G.DataConfigManager:GetGlobalConfigByKey("magic_change_position_high_random").numList
  math.randomseed(os.time())
  local postions = {}
  local validNum = 0
  local failedNum = 0
  while num > validNum and failedNum < 100 do
    local randomPos, bSucc = UE4.UNavigationSystemV1.Abs_K2_GetRandomReachablePointInRadius(owner, ownerPos, nil, radius, nil, UE4.UNRCNavFilter)
    if bSucc then
      local ranHight = math.random(hightRange[1], hightRange[2])
      randomPos.Z = randomPos.Z + ranHight
      table.insert(postions, randomPos)
      validNum = validNum + 1
    else
      failedNum = failedNum + 1
    end
  end
  local bAllSucc = true
  if num > validNum then
    bAllSucc = false
  end
  return postions, bAllSucc
end

function MiracleExchangeModule:OnCmdMiracleMainReversedSort(bool)
  local panel = self:GetPanel("MiracleExchangeMain")
  if panel then
    panel:OnReversedSort(bool)
  end
end

function MiracleExchangeModule:OnCmdOnMiracleMainSortTypeChanged(index)
  local panel = self:GetPanel("MiracleExchangeMain")
  if panel then
    panel:SortItemInfo(index)
  end
end

function MiracleExchangeModule:OnCmdTypeChooseChanged(TypeChooseList, bChoosed)
  local ChooseTypeListTemporary = self:CopyChooseTypeListTemporary()
  local hasTypePos = 0
  if 0 == #ChooseTypeListTemporary then
  else
    for i = 1, #ChooseTypeListTemporary do
      if ChooseTypeListTemporary[i] == TypeChooseList.typeId then
        hasTypePos = i
      end
    end
  end
  if true == bChoosed then
    if #ChooseTypeListTemporary > 0 then
      if 0 == hasTypePos then
        table.clear(ChooseTypeListTemporary)
        table.insert(ChooseTypeListTemporary, TypeChooseList.typeId)
      end
    else
      table.insert(ChooseTypeListTemporary, TypeChooseList.typeId)
    end
  elseif 0 ~= hasTypePos then
    table.remove(ChooseTypeListTemporary, hasTypePos)
  end
  self.data.chooseTypeListTemporary = ChooseTypeListTemporary
end

function MiracleExchangeModule:CopyChooseTypeListTemporary()
  local chooseTypeListTemporary = {}
  for i, Type in ipairs(self.data.chooseTypeListTemporary) do
    table.insert(chooseTypeListTemporary, Type)
  end
  return chooseTypeListTemporary
end

function MiracleExchangeModule:OnCmdTypeChooseBtnClicked()
  self.data.chooseTypeList = self.data.chooseTypeListTemporary
  self:DispatchEvent(PetUIModuleEvent.TypeChooseChanged, self.data.chooseTypeList)
  if not self:HasPanel("MiracleExchangeMain") then
    return
  end
  local panel = self:GetPanel("MiracleExchangeMain")
  panel:OnClickTypeBtn(self.data.chooseTypeList)
end

function MiracleExchangeModule:OnCmdGetTypeChooseNum()
  return self.data.chooseTypeList
end

local _cachedResults = {}

function MiracleExchangeModule:OnCmdHideMiraclesInRange(inActor)
  if not inActor then
    return
  end
  table.clear(_cachedResults)
  local inRange = _G.DataConfigManager:GetGlobalConfigNumByKey("magic_change_ban_npcrange", 1000)
  local ownerLocation = inActor:ABS_K2_GetActorLocation()
  local outActors, result = UE4.UKismetSystemLibrary.Abs_SphereOverlapActors(inActor:GetWorld(), ownerLocation, inRange, nil, nil, nil)
  if result then
    result = false
    for i = 1, outActors:Length() do
      local curActor = outActors:Get(i)
      if curActor.sceneCharacter and curActor.sceneCharacter.config and curActor.sceneCharacter.config.id == 65326 then
        curActor:SetActorHiddenInGame(true)
        table.insert(_cachedResults, curActor)
      end
    end
  end
  return _cachedResults
end

function MiracleExchangeModule:OnCmdReShowMiraclesInRange()
  for _, curActor in ipairs(_cachedResults) do
    curActor:SetActorHiddenInGame(false)
  end
  table.clear(_cachedResults)
end

function MiracleExchangeModule:OnCmdSetPetNewStateInfo(_PetData)
  if not self:HasPanel("MiracleExchangeMain") then
    return
  end
  self:OnCmdOpenPetBag(_PetData.PetData)
  local panel = self:GetPanel("MiracleExchangeMain")
  panel:OnRemovePetNew(_PetData)
end

function MiracleExchangeModule:OnCmdOpenPetBag(_PetData)
  local req = _G.ProtoMessage:newZoneOpenPetBagReq()
  local gidList = {}
  if _PetData then
    table.insert(gidList, _PetData.gid)
  else
    gidList = nil
  end
  req.pet_gid = gidList
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrCmd.ZONE_OPEN_PET_BAG_REQ, req, self, self.GetPetTeamInfo)
end

function MiracleExchangeModule:GetPetTeamInfo()
end

function MiracleExchangeModule:CloseBeginOpenPanel()
  if self:HasPanel("MiracleExchange") then
    self:ClosePanel("MiracleExchange")
  end
end

local PET_BALL_KEY_0 = "_ID_AUTOGENERATE_BALL0"
local PET_BALL_KEY_1 = "_ID_AUTOGENERATE_BALL1"

function MiracleExchangeModule:PlayExchangeFinishSkill(action)
  self.FinishAction = action
  local fromBallId = self.FormBallId or 100002
  local toBallId = self.ToBallId or 100002
  self:CodeCtrlBlackScreen()
  _G.NRCResourceManager:LoadResAsync(self, "/Game/ArtRes/Effects/G6Skill/MagicExchange/EnterSwap.EnterSwap_C", 0, 0, function(Request, Res)
    _G.DelayManager:CancelDelayByIdEx(self.d_InternalPlaySkill)
    self.d_InternalPlaySkill = _G.DelayManager:DelaySeconds(1, self.InternalPlaySkill, self, fromBallId, toBallId, Res)
  end, function(Request, Message)
    _G.DelayManager:CancelDelayByIdEx(self.d_InternalPlaySkill)
    self.d_InternalPlaySkill = _G.DelayManager:DelaySeconds(1, self.InternalPlaySkill, self, fromBallId, toBallId)
  end)
end

function MiracleExchangeModule:InternalPlaySkill(fromBallId, toBallId, skillClass)
  self:CloseBlackScreen()
  if self.FinishAction then
    local npcViewObj = self.FinishAction:GetOwnerNPCView()
    npcViewObj:SetActorHiddenInGame(true)
  end
  if not skillClass then
    Log.Error("EnterSwap Load Fail")
    return
  end
  local player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local skillObj = player.viewObj.RocoSkill:FindOrAddSkillObj(skillClass)
  skillObj:SetCaster(player.viewObj)
  self.NpcBall = self:LoadBall(toBallId)
  self.NpcBallRef = UnLua.Ref(self.NpcBall)
  skillObj:SetTargets({
    self.NpcBall
  })
  skillObj:RegisterEventCallback("End", self, self.FinishSkillCallback)
  skillObj:RegisterEventCallback("PreEnd", self, self.FinishSkillCallback)
  skillObj:RegisterEventCallback("PreEndAnim", self, self.FinishSkillCallback)
  local blackboard = skillObj:GetBlackboard()
  if blackboard then
    local ball1 = self:LoadBall(fromBallId)
    blackboard:SetValueAsObject(PET_BALL_KEY_1, ball1)
  end
  player.viewObj.RocoSkill:PlaySkill(skillObj)
  UE4.UNRCAudioManager.Get():PlaySound2DAuto(1392, "MiracleExchangeModule:InternalPlaySkill")
  self.FormBallId = nil
  self.ToBallId = nil
end

function MiracleExchangeModule:LoadBall(ballId)
  if 0 == ballId then
    ballId = 100002
  end
  local ballCfg = _G.DataConfigManager:GetBallConf(ballId)
  if not ballCfg then
    Log.ErrorFormat("\229\146\149\229\153\156\231\144\131\233\133\141\231\189\174\228\184\186\231\169\186 %d", ballId)
    return
  end
  local npcConfig = _G.DataConfigManager:GetNpcConf(ballCfg.npc_id)
  if not npcConfig then
    Log.ErrorFormat("\229\146\149\229\153\156\231\144\131\233\133\141\231\189\174\229\175\185\229\186\148\231\154\132NPC\233\133\141\231\189\174\228\184\186\231\169\186 %d", ballId)
    return
  end
  local model_Cfg_id = npcConfig.model_conf
  local modelConf = _G.DataConfigManager:GetModelConf(model_Cfg_id)
  if not modelConf then
    Log.ErrorFormat("\229\146\149\229\153\156\231\144\131\233\133\141\231\189\174\229\175\185\229\186\148\231\154\132NPC\233\133\141\231\189\174\231\154\132ModelCfg\228\184\186\231\169\186 %d", ballId)
    return
  end
  Log.Error("\229\138\159\232\131\189\229\183\178\231\187\143\229\186\159\229\188\131\239\188\140\229\166\130\230\158\156\233\156\128\232\166\129\228\189\191\231\148\168\232\175\183\233\135\141\230\150\176\230\143\144\233\156\128\230\177\130")
  local world = _G.UE4Helper.GetCurrentWorld()
  local ballClass, ball
  if world and ballClass then
    ball = world:Abs_SpawnActor(ballClass)
    if ball then
      ball:SetActorEnableCollision(false)
      ball:InitOutSceneAsync()
    end
  end
  return ball
end

function MiracleExchangeModule:CodeCtrlBlackScreen()
  local DialogueConf = {}
  local ExtraConf = {}
  DialogueConf.speed = 0
  ExtraConf.fade_in_speed = 1.5
  ExtraConf.fade_out_speed = 1.5
  ExtraConf.show_time = 1
  DialogueConf.text = ""
  _G.NRCModuleManager:DoCmd(_G.CampingModuleCmd.ShowBlackScreen, DialogueConf, nil, ExtraConf)
end

function MiracleExchangeModule:BlackScreen(Event, Skill)
  local DialogueConf = {}
  DialogueConf.speed = 0
  _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.ShowDialogueBlack, DialogueConf)
end

function MiracleExchangeModule:CloseBlackScreen(Event, Skill)
  _G.NRCModuleManager:DoCmd(_G.DialogueModuleCmd.FadeOutDialogueBlack)
end

function MiracleExchangeModule:FinishSkillCallback(Name, SkillObject)
  if self.FinishAction then
    self.FinishAction:Finish()
  end
  self.FinishAction = nil
  if self.NpcBall then
    self.NpcBall:K2_DestroyActor()
  end
  self.NpcBall = nil
  self.NpcBallRef = nil
  self.FormBallId = nil
  self.ToBallId = nil
  local showTip = _G.DataConfigManager:GetLocalizationConf("magic_change_success_text").msg
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, showTip)
end

return MiracleExchangeModule
