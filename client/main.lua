local ESX; CreateThread(function()
  if pcall(function() ESX = exports['es_extended']:getSharedObject() end) and ESX then return end
  while not ESX do TriggerEvent('esx:getSharedObject', function(o) ESX=o end) Wait(50) end
end)

local open=false
RegisterCommand(Config.Command,function() toggle() end,false)
RegisterKeyMapping(Config.Command,'Ouvrir Admin-menu','keyboard',Config.OpenKey)

function toggle()
  if open then closeMenu() else
    ESX.TriggerServerCallback('adminmenu:canOpen',function(ok)
      if ok then openMenu() else ESX.ShowNotification('~r~Accès refusé.') end
    end)
  end
end

function openMenu()
  ESX.TriggerServerCallback('adminmenu:getJobs',function(list)
    SetNuiFocus(true,true)
    SendNUIMessage({action='open',jobs=list})
    open=true
  end)
end
function closeMenu()
  open=false
  SetNuiFocus(false,false)
  SendNUIMessage({action='close'})
end

-- NUI callbacks
RegisterNUICallback('close',function(_,cb) closeMenu();cb('ok') end)
RegisterNUICallback('createJob',function(d,cb) TriggerServerEvent('adminmenu:createJob',d);cb('ok') end)
RegisterNUICallback('openJobBoss',function(job,cb)
  closeMenu()
  -- ouvre le bossmenu normal (F6) mais en envoyant une event custom
  TriggerEvent('bossmenu:forceOpenForJob',job)
  cb('ok')
end)

-- ESC côté jeu
CreateThread(function()
  while true do
    if open and not IsNuiFocused() and IsControlJustReleased(0,322) then closeMenu() end
    Wait(0)
  end
end)
