RegisterServerEvent('bank:balance')
AddEventHandler('bank:balance', function()
	local src = source
	local CharacterData = exports["drp_id"]:GetCharacterData(src)
	TriggerEvent("DRP_Bank:GetCharacterMoney", CharacterData.charid, function(characterMoney)
		balance = characterMoney.data[1].bank
		TriggerClientEvent('currentbalance1', src, balance)
	end)
end)

RegisterCommand('cash', function(source, args, rawCommand)
	local src = source
	local CharacterData = exports["drp_id"]:GetCharacterData(src)
	TriggerEvent("DRP_Bank:GetCharacterMoney", CharacterData.charid, function(characterMoney)
		cash = characterMoney.data[1].cash
		TriggerClientEvent('rh-banking:updateCash', src, cash)
	end)

end)

RegisterCommand('bank', function(source, args, rawCommand)
	local src = source
	local CharacterData = exports["drp_id"]:GetCharacterData(src)
	TriggerEvent("DRP_Bank:GetCharacterMoney", CharacterData.charid, function(characterMoney)
		bank = characterMoney.data[1].bank
		TriggerClientEvent('rh-banking:updateBank', src, bank)
	end)
end)




