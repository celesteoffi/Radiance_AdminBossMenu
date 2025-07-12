--============================================================--
-- Admin-Menu  (client)  v1.1                                 --
--============================================================--

local ESX
CreateThread(function()
  if pcall(function() ESX = exports['es_extended']:getSharedObject() end) and ESX then return end
  while ESX==nil do TriggerEvent('esx:getSharedObject', function(o) ESX=o end) Wait(50) end
end)

local isOpen = false

---------------------------------------------------------------
--  UI helpers                                                --
---------------------------------------------------------------
local function openUI(list)
  SetNuiFocus(true,true)
  SendNUIMessage({action='open',jobs=list})
  isOpen = true
end
local function closeUI()
  if not isOpen then return end
  isOpen=false
  SetNuiFocus(false,false)
  SendNUIMessage({action='close'})
end
RegisterNUICallback('close',function(_,cb) closeUI() cb('ok') end)

---------------------------------------------------------------
--  Ouverture (F7 ou /adminmenu)                              --
---------------------------------------------------------------
RegisterCommand('adminmenu',function()
  if isOpen then closeUI()
  else
    ESX.TriggerServerCallback('adminmenu:canOpen',function(ok)
      if not ok then ESX.ShowNotification('~r~Accès refusé') return end
      ESX.TriggerServerCallback('adminmenu:getJobs',function(list) openUI(list) end)
    end)
  end
end,false)
RegisterKeyMapping('adminmenu','Ouvrir Admin-Menu','keyboard','F7')

---------------------------------------------------------------
--  NUI → serveur                                             --
---------------------------------------------------------------
RegisterNUICallback('createJob',function(d,cb)
  TriggerServerEvent('adminmenu:createJob',d)
  cb('ok')
end)
RegisterNUICallback('openJobBoss',function(job,cb)
  closeUI()
  TriggerEvent('bossmenu:forceOpenForJob',job)
  cb('ok')
end)

---------------------------------------------------------------
--  MàJ reçue du serveur                                      --
---------------------------------------------------------------
RegisterNetEvent('adminmenu:updateJobs',function(list)
  if isOpen then
    SendNUIMessage({action='refresh',jobs=list})
  end
end)

---------------------------------------------------------------
--  ESC pour fermer                                           --
---------------------------------------------------------------
CreateThread(function()
  while true do
    if isOpen and not IsNuiFocused() and IsControlJustReleased(0,322) then closeUI() end
    Wait(0)
  end
end)
