local Logger = {}

function Logger:LogScreenError(message)
  UEPrintError(message)
  UE4Helper.PrintScreenMsg(message)
end

return Logger
