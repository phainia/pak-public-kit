local DebugTabBase = require("NewRoco.Modules.System.Debug.Tabs.DebugTabBase")
local TipEnum = require("NewRoco.Modules.System.TipsModule.Utils.TipEnum")
local TipObject = require("NewRoco.Modules.System.TipsModule.Utils.TipObject")
local TipUtils = require("NewRoco.Modules.System.TipsModule.Utils.TipUtils")
local RolePlayModuleDef = require("NewRoco.Modules.System.RolePlay.RolePlayModuleDef")
local Base = DebugTabBase
local DebugTabTips = Base:Extend("DebugTabTips")

function DebugTabTips:Ctor()
  Base.Ctor(self)
end

function DebugTabTips:SetupTabs()
  self:Add("\230\181\139\232\175\149CatchPetTips", self.DebugCatchPetTips, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "DebugCatchPetTips")
  self:Add("\230\181\139\232\175\149LegendaryTaskUnlockTips", self.DebugLegendaryTaskUnlockTips, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "DebugLegendaryTaskUnlockTips")
  self:Add("\230\181\139\232\175\149MusicCollectUnlockTips", self.DebugMusicCollectUnlockTips, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "DebugMusicCollectUnlockTips")
  self:Add("\230\181\139\232\175\149TaskSummary", self.DebugTaskSummary, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "DebugTaskSummary")
  self:Add("\230\181\139\232\175\149TaskReturnReward", self.DebugTaskReturnReward, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "DebugTaskReturnReward")
  self:Add("\230\181\139\232\175\149BreakThroughTips", self.DebugBreakThroughTips, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "DebugBreakThroughTips")
  self:Add("\230\181\139\232\175\149NewPet", self.DebugNewPet, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "DebugNewPet")
  self:Add("\230\181\139\232\175\149FunUnlockTips", self.DebugFunUnlockTips, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "DebugFunUnlockTips")
  self:Add("\230\181\139\232\175\149MagicTips", self.DebugMagicTips, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "DebugMagicTips")
  self:Add("\230\181\139\232\175\149ActivityZoneTip", self.DebugActivityZoneTip, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "DebugActivityZoneTip")
  self:Add("\230\181\139\232\175\149EnterHomeZoneTip", self.DebugEnterHomeZoneTip, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "DebugEnterHomeZoneTip")
  self:Add("\230\181\139\232\175\149HomeAddExpTips", self.DebugHomeAddExpTips, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "DebugHomeAddExpTips")
  self:Add("\230\181\139\232\175\149HomeRoomExpandTips", self.DebugHomeRoomExpandTips, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "DebugHomeRoomExpandTips")
  self:Add("\230\181\139\232\175\149RolePlayGetTips", self.DebugRolePlayGetTips, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "DebugRolePlayGetTips")
  self:Add("\228\184\128\233\148\174\232\167\166\229\143\14520\230\172\161Reward", self.DebugPushManyReward, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "DebugPushManyReward")
  self:Add("\228\184\128\233\148\174\232\167\166\229\143\14520\230\172\161NewPet", self.DebugPushManyNewPet, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "DebugPushManyNewPet")
  self:Add("\228\184\128\233\148\174\232\167\166\229\143\145pass\228\186\146\230\150\165\231\154\132tips", self.DebugPushConflictTags, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "DebugPushConflictTags")
  self:Add("\230\181\139\232\175\149SeasonBeginsTips", self.DebugSeasonBeginsTips, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\229\133\182\228\187\150", nil, "")
  self:Add("TeachingUnlockTips", self.CreateTeachingUnlockTips, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "CreateTeachingUnlockTips")
  self:Add("npctips", self.CreateNPCTips, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "CreateNPCTips")
  self:Add("\230\181\139\232\175\149MonthlyCardDailyRewardTips", self.DebugMonthlyCardDailyRewardTips, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "", "DebugMonthlyCardDailyRewardTips")
  self:Add("\230\184\133\231\169\186BP\229\149\134\229\159\142\232\180\173\228\185\176\230\172\161\230\149\176", self.DebugClearShopBuyTimes, self, nil, "\231\168\139\229\186\143\230\181\139\232\175\149", "\231\137\185\233\156\128", nil, "", "DebugClearShopBuyTimes")
  self:Add("\228\187\187\229\138\161\229\188\128\229\167\139", self.DebugTaskStart, self)
  self:Add("\228\187\187\229\138\161\231\187\147\230\157\159", self.DebugTaskComplete, self)
  self:Add("\229\137\175\230\156\172\233\152\182\230\174\181\229\174\140\230\136\144", self.DebugDungeonStage, self)
  self:Add("\229\137\175\230\156\172\230\142\162\231\180\162\229\174\140\230\136\144", self.DebugDungeonComplete, self)
end

function DebugTabTips:DebugClearShopBuyTimes()
  local req = _G.ProtoMessage:newZoneGmResetShopGoodsBuyNumReq()
  req.shop_id = 9001
  _G.ZoneServer:SendWithHandler(_G.ProtoCMD.ZoneSvrGmCmd.ZONE_GM_RESET_SHOP_GOODS_BUY_NUM_REQ, req, self, self.OnZoneGmResetShopGoodsBuyNumRsp)
end

function DebugTabTips:OnZoneGmResetShopGoodsBuyNumRsp(rsp)
  if 0 == rsp.ret_info.ret_code then
    Log.Info("\230\184\133\231\169\186BP\229\149\134\229\159\142\232\180\173\228\185\176\230\172\161\230\149\176\230\136\144\229\138\159")
  else
    Log.Error("\230\184\133\231\169\186BP\229\149\134\229\159\142\232\180\173\228\185\176\230\172\161\230\149\176\229\164\177\232\180\165")
  end
end

function DebugTabTips:EnableTipDebug()
  TipUtils.SetDebugLogEnable(true)
end

function DebugTabTips:DebugTipsStatus()
  local TipsModule = _G.NRCModuleManager:GetModule("TipsModule")
  local Coordinator = TipsModule.TipsCoordinator
  
  local function TipCompareImpl(tip1, tip2)
    if tip1:GetTipStatus() ~= tip2:GetTipStatus() then
      return tip1:GetTipStatus() > tip2:GetTipStatus()
    end
    return tip1.tipSeq < tip2.tipSeq
  end
  
  local blockingTips = {}
  for _, _distributor in pairs(Coordinator.RegisteredTipsDistributor) do
    if _distributor:ShouldWaitDispatchFinished() and _distributor.blockingTips then
      for _, _tip in pairs(_distributor.blockingTips) do
        table.insert(blockingTips, _tip)
      end
    end
    table.sort(blockingTips, TipCompareImpl)
  end
  local pausedStatus = {}
  for _name, _v in pairs(TipEnum.TipsPauseReason) do
    if 0 ~= Coordinator.PausedStatus & _v then
      pausedStatus[_name] = _v
    end
  end
  local areaNames = {}
  for _name, _area in pairs(TipEnum.TipDisplayArea) do
    areaNames[_area] = _name
  end
  local areaBlockTips = {}
  local areaBlockFlags = {}
  for _area, _areaData in pairs(Coordinator.EffectingTipAreaMutex) do
    local areaName = areaNames[_area]
    if _areaData.blockingTipCnt and _areaData.blockingTipCnt > 0 then
      local areaTips = {}
      areaBlockTips[areaName] = areaTips
      if _areaData.blockingTips then
        for _, _tip in pairs(_areaData.blockingTips) do
          table.insert(areaTips, _tip)
        end
      end
      table.sort(areaTips, TipCompareImpl)
    end
    if _areaData.blockingFlags and #_areaData.blockingFlags > 0 then
      areaBlockFlags[areaName] = table.copy(_areaData.blockingFlags)
    end
  end
  local Show = {
    ["Tips\232\176\131\229\186\166\229\153\168\231\138\182\230\128\129"] = {PausedStatus = pausedStatus},
    ["\231\188\147\229\173\152\228\184\173\231\154\132Tips"] = {
      NoDependency = Coordinator.NoDependencyTipsCache._items,
      NoPassMutex = Coordinator.NoPassMutexRequiredTipCache._items,
      Default = Coordinator.TipsCache._items
    },
    ["\233\152\187\229\161\158\228\184\173\231\154\132Tips"] = blockingTips,
    ["\229\140\186\229\159\159\228\186\146\230\150\165Tips"] = areaBlockTips,
    ["\229\140\186\229\159\159\229\177\143\232\148\189\230\160\135\232\175\134"] = areaBlockFlags
  }
  self:Inspect(Show, "Tips\231\138\182\230\128\129")
end

function DebugTabTips:PushTip(tip)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.AddTip, tip)
end

function DebugTabTips:RandomChooseFromTable(data, excludeFunc)
  local keys = {}
  for _key, _conf in pairs(data) do
    if not excludeFunc or not excludeFunc(_conf) then
      table.insert(keys, _key)
    end
  end
  local randomKey = keys[math.random(1, #keys)]
  return data[randomKey]
end

function DebugTabTips:DebugZoneTips()
  local allConf = _G.DataConfigManager:GetAllByName("AREA_FUNC_CONF")
  local areaFuncConf
  areaFuncConf = self:RandomChooseFromTable(allConf, function(_conf)
    if string.IsNilOrEmpty(_conf.name) or _conf.broadcast_type == _G.Enum.AreaBroadcastType.ABT_NONE then
      return true
    end
  end)
  if areaFuncConf then
    local areaInfo = {}
    areaInfo.id = areaFuncConf.id
    areaInfo.Conf = areaFuncConf
    areaInfo.bIsUnlocked = true
    return self:PushTip(TipObject.CreateZoneTip(areaFuncConf.id, areaInfo))
  else
    Log.Error("\231\148\159\230\136\144ZoneTips\229\164\177\232\180\165!")
  end
end

function DebugTabTips:DebugExpTips()
  if self.GetNewZoneExpChangeData == nil then
    local function CreateZoneExpChangeData()
      local curLevel = _G.DataModelMgr.PlayerDataModel:GetPlayerLevel()
      
      local curExp, curMaxExp = _G.DataModelMgr.PlayerDataModel:GetPlayerExpInfo()
      return function()
        local expTipData = {}
        expTipData.oldLevel = curLevel
        expTipData.oldExp = curExp
        local addExp = math.random(10, 200)
        if addExp >= curMaxExp - curExp then
          curLevel = curLevel + 1
          curExp = curExp + addExp - curMaxExp
          curMaxExp = _G.DataConfigManager:GetRoleExpConf(curLevel).need_exp
        else
          curExp = curExp + addExp
        end
        expTipData.newLevel = curLevel
        expTipData.newExp = curExp
        expTipData.addExp = addExp
        return expTipData
      end
    end
    
    self.GetNewZoneExpChangeData = CreateZoneExpChangeData()
  end
  return self:PushTip(TipObject.CreateExpChangeTip(self.GetNewZoneExpChangeData()))
end

function DebugTabTips:DebugLeaderFightTips()
  return self:PushTip(TipObject.FromLeaderFight({}, TipEnum.TipObjectType.LeaderFight))
end

function DebugTabTips:DebugStampsChangeTips()
  local notify = {}
end

function DebugTabTips:DebugIncreaseUseCount()
  local AllBagItems = _G.DataConfigManager:GetAllByName("BAG_ITEM_CONF")
  local BagItemConf
  BagItemConf = self:RandomChooseFromTable(AllBagItems, function(_conf)
    if _conf.initial_use_times <= 1 then
      return true
    end
  end)
  if BagItemConf then
    local old = math.random(1, BagItemConf.initial_use_times - 1)
    local newItem = {}
    newItem.id = BagItemConf.id
    newItem.type = BagItemConf.type
    newItem.remain_use_cnt = BagItemConf.initial_use_times - old
    newItem.max_use_cnt = newItem.remain_use_cnt + math.random(1, 5)
    newItem.num = math.random(1, 10)
    return self:PushTip(TipObject.FromIncreaseUseCount(newItem, old, BagItemConf.id))
  else
    Log.Error("\231\148\159\230\136\144IncreaseUseCountTips\229\164\177\232\180\165!")
  end
end

function DebugTabTips:DebugAmplifyUseEffect()
  local AllBagItems = _G.DataConfigManager:GetAllByName("BAG_ITEM_CONF")
  local BagItemConf
  BagItemConf = self:RandomChooseFromTable(AllBagItems, function(_conf)
    if _conf.initial_use_times <= 1 then
      return true
    end
  end)
  if BagItemConf then
    local old = math.random(1, BagItemConf.initial_use_times - 1)
    local newItem = {}
    newItem.id = BagItemConf.id
    newItem.type = BagItemConf.type
    newItem.remain_use_cnt = BagItemConf.initial_use_times - old
    newItem.max_use_cnt = newItem.remain_use_cnt + math.random(1, 5)
    newItem.num = math.random(1, 10)
    return self:PushTip(TipObject.FromAmplifyUseEffect(newItem, old, BagItemConf.id))
  else
    Log.Error("\229\136\155\229\187\186AmplifyUseEffectTips\229\164\177\232\180\165!")
  end
end

function DebugTabTips:DebugMiracleExchange()
end

function DebugTabTips:DebugHandbookChange()
end

function DebugTabTips:DebugPetBallCatchAward()
end

function DebugTabTips:DebugHandbookTopic()
  local changeData = {}
  changeData.finish_cnt = 1
  changeData.handbook_id = 5
  changeData.max_cnt = 1
  changeData.petbase_id = 3003
  changeData.topicConf = _G.DataConfigManager:GetPetTopicTypeConf(1)
  changeData.topic_id = 0
  changeData.topic_type = 1
  self:PushTip(TipObject.CreateHandbookTopicDataTip(changeData))
end

function DebugTabTips:DebugTaskUpdate()
  return self:PushTip(TipObject.FromTaskUpdate())
end

function DebugTabTips:DebugTaskStart()
  local AllTasks = _G.DataConfigManager:GetAllByName("TASK_CONF")
  local StartTasks = {}
  for ID, Task in pairs(AllTasks) do
    if Task.is_para_start and 0 ~= Task.paragraph_id then
      local Paragraph = _G.DataConfigManager:GetParagraphConf(Task.paragraph_id)
      if Paragraph and Paragraph.show_task_start then
        table.insert(StartTasks, ID)
      end
    end
  end
  local RandomIndex = math.random(1, #StartTasks)
  local RandomTaskID = StartTasks[RandomIndex]
  local NewInfo = _G.ProtoMessage:newPlayerTaskInfo()
  NewInfo.id = RandomTaskID
  return self:PushTip(TipObject.FromTaskAccept(NewInfo))
end

function DebugTabTips:DebugTaskComplete()
  local AllTasks = _G.DataConfigManager:GetAllByName("TASK_CONF")
  local CompleteTasks = {}
  for ID, Task in pairs(AllTasks) do
    if Task.is_para_done and 0 ~= Task.paragraph_id then
      local Paragraph = _G.DataConfigManager:GetParagraphConf(Task.paragraph_id)
      if Paragraph then
        table.insert(CompleteTasks, ID)
      end
    end
  end
  local RandomIndex = math.random(1, #CompleteTasks)
  local RandomTaskID = CompleteTasks[RandomIndex]
  local NewInfo = _G.ProtoMessage:newPlayerTaskInfo()
  NewInfo.id = RandomTaskID
  return self:PushTip(TipObject.FromTaskComplete(NewInfo))
end

function DebugTabTips:DebugDungeonStage()
  return self:PushTip(TipObject.FromDungeonStateCompleted("\230\181\139\232\175\149\229\137\175\230\156\172\233\152\182\230\174\181\229\174\140\230\136\144"))
end

function DebugTabTips:DebugDungeonComplete()
  return self:PushTip(TipObject.FromDungeonCompleted("\230\181\139\232\175\149\229\137\175\230\156\172\229\133\168\233\131\168\229\174\140\230\136\144"))
end

function DebugTabTips:DebugReward()
  local goodsItem = _G.ProtoMessage:newGoodsItem()
  goodsItem.type = Enum.GoodsType.GT_RP_BEHAVIOR
  goodsItem.id = 10
  goodsItem.num = 1
  return self:PushTip(TipObject.FromGoodsItem(goodsItem))
end

function DebugTabTips:DebugLobbyDownTips()
  local petData = {
    base_conf_id = 3001,
    gender = 1,
    mutation_type = _G.Enum.MutationDiffType.MDT_SHINING,
    blood_id = 1,
    level = 5
  }
  return self:PushTip(TipObject.FormLobbyDownTips(TipEnum.LobbyDownTipsType.BookPrompt, petData))
end

function DebugTabTips:CreateTeachingUnlockTips()
  local allTeachItems = _G.DataConfigManager:GetAllByName("TEACH_CONF")
  local choose = self:RandomChooseFromTable(allTeachItems, function(_conf)
  end)
  if choose then
    local tipData = {
      TeachId = choose.id
    }
    self:PushTip(TipObject.CreateTeachingUnlockTips(tipData))
  end
end

function DebugTabTips:DebugRolePlayGetTips()
  local AllRolePlayItems = _G.DataConfigManager:GetAllByName("ROLEPLAY_BEHAVIOR_CONF")
  local chooseRolePlay = self:RandomChooseFromTable(AllRolePlayItems, function(_conf)
  end)
  if chooseRolePlay then
    _G.NRCModuleManager:DoCmd(_G.RolePlayModuleCmd.ShowGetNewRolePlayTips, chooseRolePlay.id)
  end
end

function DebugTabTips:DebugRolePlayGetTips_Suit()
  local AllSuitItems = _G.DataConfigManager:GetAllByName("FASHION_SUITS_CONF")
  local chooseSuits = self:RandomChooseFromTable(AllSuitItems, function(_conf)
  end)
  local suitNotify = ProtoMessage:newZoneSceneNewFashionSuitNotify()
  suitNotify.fashion_suit_id = chooseSuits.id
  local rolePlayModule = _G.NRCModuleManager:GetModule("RolePlayModule")
  rolePlayModule:OnGetNewSuit(suitNotify)
end

function DebugTabTips:DebugCatchPetTips()
  if self.GetNewCatchPetData == nil then
    local function CreateCatchPetData()
      return function()
        local customData = {}
        
        customData.showTime = 2
        customData.soundId = 41500501
        customData.text = "\230\184\172\232\169\166"
        customData.umgName = "UMG_ContinuousCapture_Tips"
        return customData
      end
    end
    
    self.GetNewCatchPetData = CreateCatchPetData()
  end
  return self:PushTip(TipObject.CreateCatchPetTip(self.GetNewCatchPetData()))
end

function DebugTabTips:DebugLegendaryTaskUnlockTips()
  if self.GetNewLegendaryTaskUnlockTips == nil then
    local function CreateLegendaryTaskUnlockTips()
      return function()
        local customData = {}
        
        customData.title = "\230\181\139\232\175\149"
        customData.iconPath = "Texture2D'/Game/NewRoco/Modules/System/Common/Icon/BagItem/100808.100808'"
        customData.content = "\229\183\178\229\162\158\229\138\160\230\150\176\228\185\166\233\161\181\227\128\140\229\134\146\233\153\169\229\174\182\227\128\141"
        customData.UnlockTipsType = ProtoEnum.TaleTaskType.TALE_NOTEBOOK_KELI
        customData.PageId = 1
        customData.countdown = 5
        customData.countdownStr = "\231\130\185\229\135\187\230\159\165\231\156\139\228\185\166\233\161\181\239\188\136%d\231\167\146\239\188\137"
        return customData
      end
    end
    
    self.GetNewLegendaryTaskUnlockTips = CreateLegendaryTaskUnlockTips()
  end
  return self:PushTip(TipObject.CreateLegendaryTaskUnlockTips(self.GetNewLegendaryTaskUnlockTips()))
end

function DebugTabTips:DebugMusicCollectUnlockTips()
  if self.GetNewMusicCollectUnlockTips == nil then
    local function CreateMusicCollectUnlockTips()
      return function()
        local id = 1002
        
        local MusicConf = _G.DataConfigManager:GetMusicConf(id)
        local customData = {}
        customData.UnlockId = id
        customData.Name = MusicConf.music_name
        customData.TypeName = _G.DataConfigManager:GetMusicTypeConf(MusicConf.music_type).music_type_name
        customData.countdown = _G.DataConfigManager:GetGlobalConfig("main_music_tips_showtime").num or 5
        customData.countdownStr = "\231\130\185\229\135\187\230\159\165\231\156\139\239\188\136%d\231\167\146\239\188\137"
        return customData
      end
    end
    
    self.GetNewMusicCollectUnlockTips = CreateMusicCollectUnlockTips()
  end
  return self:PushTip(TipObject.CreateMusicCollectUnlockTips(self.GetNewMusicCollectUnlockTips()))
end

function DebugTabTips:DebugTaskSummary()
  if self.GetNewTaskSummary == nil then
    local function CreateTaskSummary()
      return function()
        self.player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
        
        local taskId = 21607021
        local TaskConf = _G.DataConfigManager:GetTaskConf(taskId)
        local summary_id
        for _, Condition in ipairs(TaskConf.finish_action) do
          if Condition.type == Enum.TaskStateChangeActionType.TSCAT_TASK_SUMMARY then
            summary_id = Condition.data1[1]
          end
        end
        local customData = {
          summary_id = summary_id,
          tod = Enum.TimeOfDay.TOD_TWILIGHT,
          weather = Enum.WeatherType.WT_SUNNY,
          fashion = {
            fashion_id = self.player:GetFashionItems(),
            salon_item_data = self.player:GetSalonIds()
          },
          Weather2 = 1734356451
        }
        return customData
      end
    end
    
    self.GetNewTaskSummary = CreateTaskSummary()
  end
  return self:PushTip(TipObject.CreateTaskSummaryTips(self.GetNewTaskSummary()))
end

function DebugTabTips:DebugTaskReturnReward()
  _G.GlobalConfig.DebugOpenUI = true
  return self:PushTip(TipObject.CreateTaskReturnRewardTips())
end

function DebugTabTips:DebugBreakThroughTips()
  local worldLevelConf = _G.DataConfigManager:GetWorldLevelConf(4)
  local tipExpData = {}
  local playerLv = _G.DataModelMgr.PlayerDataModel:GetPlayerLevel()
  tipExpData.frameCnt = _G.UpdateManager.FrameCnt
  tipExpData.oldLevel = playerLv
  tipExpData.newLevel = playerLv + 1
  tipExpData.oldExp = _G.DataModelMgr.PlayerDataModel:GetVItemCount(_G.ProtoEnum.VisualItem.VI_ROLEEXP)
  tipExpData.newExp = tipExpData.oldExp + 500
  tipExpData.addExp = 500
  local expTip = TipObject.CreateExpChangeTip(tipExpData)
  return self:PushTip(TipObject.CreateBreakThroughTip(worldLevelConf, expTip))
end

function DebugTabTips:DebugNewPet()
  local petData = {
    base_conf_id = 3001,
    gender = 1,
    mutation_type = _G.Enum.MutationDiffType.MDT_SHINING,
    blood_id = 1,
    level = 5
  }
  return self:PushTip(TipObject.FormLobbyDownTips(TipEnum.LobbyDownTipsType.BookPrompt, petData))
end

function DebugTabTips:DebugFunUnlockTips()
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.AddTip, TipObject.CreateUnlockUIEnumTip(1))
end

function DebugTabTips:DebugMagicTips()
  local customData = {}
  customData.coro_id = 13578
  customData.id = 100732
  customData.num = 1
  customData.op = 2
  customData.type = 1
  customData.update_time = 1764814892
  local conf = _G.DataConfigManager:GetMagicBaseConf(2)
  customData.bag_item = {
    can_charge = false,
    can_in_battle = false,
    gid = 1,
    id = 100732,
    num = 1,
    type = 5,
    conf = conf
  }
  self:PushTip(TipObject.CreateMagicUnlockTip(customData))
end

function DebugTabTips:DebugActivityZoneTip()
  local Desc = "\230\181\139\232\175\149\230\180\187\229\138\168ZoneTip"
  self:PushTip(TipObject.CreateActivityZoneTip(Desc))
end

function DebugTabTips:DebugEnterHomeZoneTip()
  self:PushTip(TipObject.CreateEnterHomeZoneTip())
end

function DebugTabTips:DebugHomeAddExpTips()
  local Data = {
    newExp = 300,
    newLevel = 2,
    oldExp = 200,
    oldLevel = 1,
    addExp = 100,
    targetMaxExp = 0
  }
  self:PushTip(TipObject.CreateAddHomeExpTip(Data))
end

function DebugTabTips:DebugHomeRoomExpandTips()
  self:PushTip(TipObject.CreateHomeExpandTip())
end

function DebugTabTips:DebugRolePlayGetTips()
  local conf = _G.DataConfigManager:GetRoleplayBehaviorConf(1)
  local roleConfigTableId = _G.DataConfigManager.ConfigTableId.ROLE_GLOBAL_CONFIG
  local configTime = _G.DataConfigManager:GetGlobalConfigByKeyType("roleplay_reward_toast_time", roleConfigTableId).num / 1000
  local customData = {}
  customData.content = conf.toast_text
  customData.iconPath = conf.icon_path
  customData.countdown = 0 == configTime % 1 and math.floor(configTime) or configTime
  customData.rolePlayType = RolePlayModuleDef.RolePlayType.Action
  customData.title = _G.LuaText.roleplay_reward_text1
  customData.countdownStr = _G.DataConfigManager:GetGlobalConfigByKeyType("roleplay_reward_toast_text1", roleConfigTableId).str
  self:PushTip(TipObject.CreateRolePlayTips(customData))
end

function DebugTabTips:DebugPushManyReward()
  for i = 1, 20 do
    self:DebugReward()
  end
end

function DebugTabTips:DebugPushManyNewPet()
  for i = 1, 20 do
    self:DebugNewPet()
  end
end

function DebugTabTips:DebugPushConflictTags()
  self:DebugLobbyDownTips()
  self:DebugHandbookTopic()
  self:DebugReward()
  self:DebugExpTips()
  self:DebugBreakThroughTips()
end

function DebugTabTips:DebugSeasonBeginsTips()
  local seasonInfo = _G.NRCModuleManager:DoCmd(_G.SeasonIntegrationModuleCmd.GetSeasonInfo)
  if nil == seasonInfo then
    Log.Error("DebugTabCommon:ShowSeasonBeginsTips seasonInfo is nil")
    return
  end
  local seasonConf = _G.DataConfigManager:GetSeasonConf(seasonInfo.season_id)
  if seasonConf and seasonConf.popup_path then
    local umgPath = string.format("/Game/NewRoco/Modules/System/SeasonIntegration/Res/%s", seasonConf.popup_path)
    local module = _G.NRCModuleManager:GetModule("SeasonIntegrationModule")
    local panelData = module:GetPanelData("SeasonBeginsTips")
    panelData.panelPath = NRCUtils.FormatBlueprintAssetPath(umgPath)
    self:PushTip(TipObject.CreateSeasonBeginsTips())
  end
end

function DebugTabTips:DebugMonthlyCardDailyRewardTips()
  local clientMonthCardConf = _G.NRCModuleManager:DoCmd(_G.ShopModuleCmd.OnCmdGetClientMonthCardConf)
  local _DayRewardConf = _G.DataConfigManager:GetRewardConf(clientMonthCardConf.dayRewardId)
  local _DayRewardItem = _DayRewardConf and _DayRewardConf.RewardItem[1]
  if _DayRewardConf and _DayRewardConf.RewardItem and #_DayRewardConf.RewardItem > 0 then
    for k, v in ipairs(_DayRewardConf.RewardItem) do
      self:PushTip(TipObject.CreateMonthlyCardDailyRewardTips(v.Type, v.Id, v.Count, k))
    end
  end
end

function DebugTabTips:CreateNPCTips()
  Log.Error("\232\167\163\233\148\129\230\150\176\231\154\132npc")
  local uiData = {}
  uiData.npcID = 1
  uiData.countdown = 5
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.AddTip, TipObject.CreateNPCRosterTips(uiData))
end

function DebugTabTips:CreateRandomTips()
  local debugTipsFunc = {}
  table.insert(debugTipsFunc, self.DebugZoneTips)
  table.insert(debugTipsFunc, self.DebugExpTips)
  table.insert(debugTipsFunc, self.DebugLeaderFightTips)
  table.insert(debugTipsFunc, self.DebugStampsChangeTips)
  table.insert(debugTipsFunc, self.DebugIncreaseUseCount)
  table.insert(debugTipsFunc, self.DebugAmplifyUseEffect)
  table.insert(debugTipsFunc, self.DebugHandbookChange)
  table.insert(debugTipsFunc, self.DebugPetBallCatchAward)
  table.insert(debugTipsFunc, self.DebugHandbookTopic)
  table.insert(debugTipsFunc, self.DebugTaskUpdate)
  table.insert(debugTipsFunc, self.DebugReward)
  table.insert(debugTipsFunc, self.DebugLobbyDownTips)
  table.insert(debugTipsFunc, self.DebugTaskStart)
  table.insert(debugTipsFunc, self.DebugTaskComplete)
  table.insert(debugTipsFunc, self.DebugDungeonStage)
  table.insert(debugTipsFunc, self.DebugDungeonComplete)
  local num = math.random(1, 10)
  for i = 1, num do
    local debugFunc = debugTipsFunc[math.random(1, #debugTipsFunc)]
    if debugFunc then
      debugFunc(self)
    end
  end
end

return DebugTabTips
