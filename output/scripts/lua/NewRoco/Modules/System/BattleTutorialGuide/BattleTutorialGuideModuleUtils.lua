local BattleTutorialGuideModuleUtils = {}
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local GuideConfigTypes = require("NewRoco.Modules.System.Guidance.Types.GuideConfigTypes")

function BattleTutorialGuideModuleUtils.GetGuideWidget(Paths)
  local pathWidgets = {}
  if not Paths or not Paths[1] then
    Log.Debug("BattleTutorialGuideModuleUtils.GetGuideWidget: \232\183\175\229\190\132\230\149\176\231\187\132\228\184\186\231\169\186\230\136\150\231\172\172\228\184\128\228\184\170\229\133\131\231\180\160\228\184\186nil")
    return nil
  end
  local curWidget = BattleTutorialGuideModuleUtils.GetPanelByName(Paths[1])
  if not curWidget then
    return nil
  end
  local targetPanelData = curWidget.panelData
  table.insert(pathWidgets, curWidget)
  local pathCount = #Paths
  for i = 2, pathCount do
    local widgetName = Paths[i]
    local listName, targetIndex = widgetName:match("^(.+)%[(%d+)%]$")
    if listName then
      targetIndex = tonumber(targetIndex)
    else
      listName = widgetName
      targetIndex = nil
    end
    curWidget = curWidget[listName]
    if not curWidget then
      Log.Debug("BattleTutorialGuideModuleUtils.GetGuideWidget: \230\142\167\228\187\182\228\184\141\229\173\152\229\156\168\239\188\140\232\183\175\229\190\132\231\180\162\229\188\149=" .. i .. ", \230\142\167\228\187\182\229\144\141=" .. listName)
      return nil
    end
    table.insert(pathWidgets, curWidget)
    if i == pathCount then
      if curWidget:IsA(UE.UNRCWidgetLoader) then
        return curWidget
      end
    else
      if not curWidget then
        Log.Debug("BattleTutorialGuideModuleUtils.GetGuideWidget: \230\142\167\228\187\182\228\184\141\229\173\152\229\156\168\239\188\140\232\183\175\229\190\132\231\180\162\229\188\149=" .. i .. ", \230\142\167\228\187\182\229\144\141=" .. listName)
        return nil
      end
      if curWidget:IsA(UE.UNRCWidgetLoader) then
        curWidget = curWidget:GetPanel()
        table.insert(pathWidgets, curWidget)
      end
    end
    if not curWidget then
      Log.Debug("BattleTutorialGuideModuleUtils.GetGuideWidget: \230\142\167\228\187\182\228\184\141\229\173\152\229\156\168\239\188\140\232\183\175\229\190\132\231\180\162\229\188\149=" .. i .. ", \230\142\167\228\187\182\229\144\141=" .. listName)
      return nil
    end
    if curWidget:IsA(UE.UNRCScrollView) then
      local itemCount = curWidget:GetItemCount()
      if targetIndex and targetIndex <= itemCount then
        curWidget = curWidget:GetItemByIndex(targetIndex - 1)
        table.insert(pathWidgets, curWidget)
      else
        Log.Debug("BattleTutorialGuideModuleUtils.GetGuideWidget: ScrollView\231\180\162\229\188\149\230\151\160\230\149\136\239\188\140\232\183\175\229\190\132\231\180\162\229\188\149=" .. i .. ", \231\155\174\230\160\135\231\180\162\229\188\149=" .. tostring(targetIndex) .. ", \230\128\187\233\161\185\231\155\174\230\149\176=" .. itemCount)
        return nil
      end
    end
    if not curWidget then
      Log.Debug("BattleTutorialGuideModuleUtils.GetGuideWidget: \230\142\167\228\187\182\228\184\141\229\173\152\229\156\168\239\188\140\232\183\175\229\190\132\231\180\162\229\188\149=" .. i .. ", \230\142\167\228\187\182\229\144\141=" .. listName)
      return nil
    end
  end
  return curWidget, targetPanelData, pathWidgets
end

function BattleTutorialGuideModuleUtils.GetPanelByName(topWidgetName)
  if "TeamPetClickTip" == topWidgetName then
    local Pet = _G.BattleManager.battlePawnManager:GetTeamPet(BattleEnum.Team.ENUM_TEAM, 1)
    if not Pet then
      return nil
    end
    local targetWidget
    if Pet and Pet.battlePetComponents and Pet.battlePetComponents.ClickTipUIActor then
      targetWidget = Pet.battlePetComponents.ClickTipUIActor
    end
    if not BattleTutorialGuideModuleUtils.CheckWidgetVisible(targetWidget) then
      return nil
    end
    return targetWidget
  elseif "EnemyPetClickTip" == topWidgetName then
    local Pet = _G.BattleManager.battlePawnManager:GetTeamPet(BattleEnum.Team.ENUM_ENEMY, 1)
    if not Pet then
      return nil
    end
    if not _G.BattleUtils.CheckPetInViewPort(Pet) then
      return nil
    end
    local targetWidget
    if Pet and Pet.battlePetComponents and Pet.battlePetComponents.ClickTipUIActor then
      targetWidget = Pet.battlePetComponents.ClickTipUIActor
    end
    if not BattleTutorialGuideModuleUtils.CheckWidgetVisible(targetWidget) then
      return nil
    end
    return targetWidget
  end
  local moduleName, panelName = BattleTutorialGuideModuleUtils.SplitPath(topWidgetName)
  if not moduleName or not panelName then
    Log.Debug("BattleTutorialGuideModuleUtils.GetGuideWidget: \232\183\175\229\190\132\229\136\134\229\137\178\229\164\177\232\180\165\239\188\140moduleName=" .. tostring(moduleName) .. ", panelName=" .. tostring(panelName))
    return nil
  end
  local curWidget = _G.NRCPanelManager:GetPanel(moduleName, panelName)
  if not curWidget then
    Log.Debug("BattleTutorialGuideModuleUtils.GetGuideWidget: \229\136\157\229\167\139\233\157\162\230\157\191\228\184\141\229\143\175\232\167\129\239\188\140moduleName=" .. moduleName .. ", panelName=" .. panelName)
    return nil
  end
  return curWidget
end

function BattleTutorialGuideModuleUtils.SplitPath(str)
  local delimiter = "/"
  if not str:find(delimiter, 1, true) then
    return str, nil
  end
  local result = {}
  for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
    table.insert(result, match)
  end
  return result[1], result[2]
end

function BattleTutorialGuideModuleUtils.CheckWidgetVisible(widget)
  if widget and widget:GetVisibility() ~= UE4.ESlateVisibility.Collapsed and widget:GetVisibility() ~= UE4.ESlateVisibility.Hidden and widget:GetRenderOpacity() > 0 then
    return true
  else
    return false
  end
end

function BattleTutorialGuideModuleUtils.IsWidgetVisible(widget)
  if not widget then
    return false
  end
  return BattleTutorialGuideModuleUtils.IsWidgetVisibleDfs(widget)
end

function BattleTutorialGuideModuleUtils.IsWidgetVisibleDfs(widget)
  if not widget then
    return true
  end
  if BattleTutorialGuideModuleUtils.CheckWidgetVisible(widget) then
    return BattleTutorialGuideModuleUtils.IsWidgetVisibleDfs(widget:GetParent())
  else
    return false
  end
end

return BattleTutorialGuideModuleUtils
