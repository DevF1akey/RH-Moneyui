inMenu                      = true
local showblips = true
local atbank = false
local inATM = false
local sleeper = 0
local bankMenu = true
local banks = {

}	

local atm_models = {"prop_fleeca_atm", "prop_atm_01", "prop_atm_02", "prop_atm_03"}
atmuse = false


Citizen.CreateThread(function()
	if showblips then
	  for k,v in ipairs(banks)do
		local blip = AddBlipForCoord(v.x, v.y, v.z)
		SetBlipSprite(blip, v.id)
		SetBlipScale(blip, 0.7)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(tostring(v.name))
		EndTextCommandSetBlipName(blip)
    end
  end
end)








--===============================================
--==           Deposit Event                   ==
--===============================================
RegisterNetEvent('currentbalance1')
AddEventHandler('currentbalance1', function(balance)
	local id = PlayerId()
	local playerName = GetPlayerName(id)
	
	SendNUIMessage({
		type = "balanceHUD",
		balance = balance,
		player = playerName
		})
end)
--===============================================
--==           Deposit Event                   ==
--===============================================
RegisterNUICallback('deposit', function(data)
	TriggerServerEvent('bank:deposit', tonumber(data.amount))
end)

--===============================================
--==          Withdraw Event                   ==
--===============================================
RegisterNUICallback('withdrawl', function(data)
	TriggerServerEvent('bank:withdraw', tonumber(data.amountw))
end)

--===============================================
--==         Balance Event                     ==
--===============================================
RegisterNUICallback('balance', function()
	TriggerServerEvent('bank:balance')
end)

RegisterNetEvent('balance:back')
AddEventHandler('balance:back', function(balance)

	SendNUIMessage({type = 'balanceReturn', bal = balance})

end)


--===============================================
--==         Transfer Event                    ==
--===============================================
RegisterNUICallback('transfer', function(data)
	TriggerServerEvent('bank:transfer', data.to, data.amountt)
	
end)




--===============================================
--==               NUIFocusoff                 ==
--===============================================
RegisterNUICallback('NUIFocusOff', function()
  inMenu = false
  SetNuiFocus(false, false)
  SendNUIMessage({type = 'closeAll'})
  bankanimation()
  if inATM then
    inATM = false
    CloseATM()
  end
end)


--===============================================
--==            Capture Bank Distance          ==
--===============================================
function nearBank()
	local player = GetPlayerPed(-1)
	local playerloc = GetEntityCoords(player, 0)
	
	for _, search in pairs(banks) do
		local distance = GetDistanceBetweenCoords(search.x, search.y, search.z, playerloc['x'], playerloc['y'], playerloc['z'], true)
		
		if distance <= 1 then
			return true
		end
	end
end

function nearATM()
	local player = GetPlayerPed(-1)
	local playerloc = GetEntityCoords(player, 0)
	
	for _, search in pairs(atms) do
		local distance = GetDistanceBetweenCoords(search.x, search.y, search.z, playerloc['x'], playerloc['y'], playerloc['z'], true)
		
		if distance <= 3 then
			return true
		end
	end
end


function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

--===============================================
--==              Cash & Bank HUD              ==
--===============================================

-- listeners
RegisterNetEvent("es:addedMoney")
AddEventHandler("es:addedMoney", function(m, native, current)
	TriggerEvent("rh-banking:updateCash", current)
  TriggerEvent("rh-banking:addCash", m)
end)

RegisterNetEvent("es:removedMoney")
AddEventHandler("es:removedMoney", function(m, native, current)
	TriggerEvent("rh-banking:updateCash", current)
  TriggerEvent("rh-banking:removeCash", m)
end)

RegisterNetEvent("es:addedBank")
AddEventHandler("es:addedBank", function(m, native, current)
	TriggerEvent("rh-banking:updateBank", current)
  TriggerEvent("rh-banking:addBank", m)
end)

RegisterNetEvent("es:removedBank")
AddEventHandler("es:removedBank", function(m, native, current)
	TriggerEvent("rh-banking:updateBank", current)
  TriggerEvent("rh-banking:removeBank", m)
end)

-- nuis
--bank
RegisterNetEvent('rh-banking:updateBank')
AddEventHandler('rh-banking:updateBank', function(balance, show)
  local id = PlayerId()
  local playerName = GetPlayerName(id)
	SendNUIMessage({
		updateBank = true,
		bank = balance,
    player = playerName,
    show = show
	})
end)

RegisterNetEvent("rh-banking:addBank")
AddEventHandler("rh-banking:addBank", function(amount)
	SendNUIMessage({
		addBank = true,
		amount = amount
	})
end)

RegisterNetEvent("rh-banking:removeBank")
AddEventHandler("rh-banking:removeBank", function(amount)
	SendNUIMessage({
		removeBank = true,
		amount = amount
	})
end)

RegisterNetEvent("rh-banking:viewBank")
AddEventHandler("rh-banking:viewBank", function()
  SendNUIMessage({
    viewBank = true
  })
end)

--cash
RegisterNetEvent('rh-banking:updateCash')
AddEventHandler('rh-banking:updateCash', function(balance, show)
  local id = PlayerId()
  local playerName = GetPlayerName(id)
	SendNUIMessage({
		updateCash = true,
		cash = balance,
    show = show
	})
end)

RegisterNetEvent("rh-banking:addCash")
AddEventHandler("rh-banking:addCash", function(amount)
	SendNUIMessage({
		addCash = true,
		amount = amount
	})
end)

RegisterNetEvent("rh-banking:removeCash")
AddEventHandler("rh-banking:removeCash", function(amount)
	SendNUIMessage({
		removeCash = true,
		amount = amount
	})
end)


RegisterNetEvent("rh-banking:viewCash")
AddEventHandler("rh-banking:viewCash", function()
  SendNUIMessage({
		viewCash = true
	})
end)

function DrawText3Ds(x,y,z, text)
  local onScreen,_x,_y=World3dToScreen2d(x,y,z)
  local px,py,pz=table.unpack(GetGameplayCamCoords())
  SetTextScale(0.35, 0.35)
  SetTextFont(4)
  SetTextProportional(1)
  SetTextColour(255, 255, 255, 215)

  SetTextEntry("STRING")
  SetTextCentre(1)
  AddTextComponentString(text)
  DrawText(_x,_y)
  local factor = (string.len(text)) / 370
  DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

function loadAnimDict( dict )
  while ( not HasAnimDictLoaded( dict ) ) do
      RequestAnimDict( dict )
      Citizen.Wait( 5 )
  end
end
function bankanimation()
  local player = GetPlayerPed( -1 )
  if nearBank() then
    if ( DoesEntityExist( player ) and not IsEntityDead( player )) then

          loadAnimDict( "amb@prop_human_atm@male@enter" )
          loadAnimDict( "amb@prop_human_atm@male@exit" )
          loadAnimDict( "amb@prop_human_atm@male@idle_a" )

        if ( atmuse ) then
            ClearPedTasks(GetPlayerPed(-1))
            TaskPlayAnim( player, "amb@prop_human_atm@male@exit", "exit", 1.0, 1.0, -1, 49, 0, 0, 0, 0 )
            atmuse = false
            exports["t0sic_loadingbar"]:StartDelayedFunction('Retrieving Card', 3000, function()
              ClearPedTasks(GetPlayerPed(-1))
            end)
        else
            atmuse = true
            TaskPlayAnim( player, "amb@prop_human_atm@male@idle_a", "idle_b", 1.0, 1.0, -1, 49, 0, 0, 0, 0 )
        end
    end
  else
      if ( DoesEntityExist( player ) and not IsEntityDead( player )) then

          loadAnimDict( "mp_common" )

          if ( atmuse ) then
              ClearPedTasks(GetPlayerPed(-1))
              TaskPlayAnim( player, "mp_common", "givetake1_a", 1.0, 1.0, -1, 49, 0, 0, 0, 0 )
              atmuse = false
              exports["t0sic_loadingbar"]:StartDelayedFunction('Retrieving Card', 1000, function()
                ClearPedTasks(GetPlayerPed(-1))
              end)
          else
              atmuse = true
              TaskPlayAnim( player, "mp_common", "givetake1_a", 1.0, 1.0, -1, 49, 0, 0, 0, 0 )
              Citizen.Wait(1000)
              ClearPedTasks(GetPlayerPed(-1))
          end
      end
  end
end

