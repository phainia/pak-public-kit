local BaseBattleInfoUtility = NRCClass("BaseBattleInfoUtility")

function BaseBattleInfoUtility:SafeCall(memberFuncName, ...)
  local func = self[memberFuncName]
  if func then
    return func(self, ...)
  end
end

return BaseBattleInfoUtility
