local BP_RichTextHyperLinkDecorator_C = NRCClass:Extend("BP_RichTextHyperLinkDecorator_C")

function BP_RichTextHyperLinkDecorator_C:ClickFun(Url)
  Log.Error("Click on url")
  UE4.UWebViewStatics.OpenUrl(Url)
end

return BP_RichTextHyperLinkDecorator_C
