local discord = RegisterMod("Discord Mod", 1)
local game = Game()
local frameCounter = 0;
local lockPosition = false;


--Items--
local legacy_item = Isaac.GetItemIdByName( "Dad's Legacy" )
local krampus_horn = Isaac.GetItemIdByName( "Krampuses Horn" )
local shart = Isaac.GetItemIdByName( "The Shart" )
local bhope = Isaac.GetItemIdByName("Beggar's Hope")
local philID = Isaac.GetCardIdByName("Philosopher's Stone")

--Timing--
function discord:updateFrame() 
    local player = Isaac.GetPlayer(0)
    if(lockPosition == true) then 
        player:AddVelocity(Vector(-player.Velocity.X, -player.Velocity.Y)); -- apply negative velocity so player barely moves
        frameCounter = frameCounter + 1;
        
        if(frameCounter >= 20) then
            frameCounter = 0;
            lockPosition = false;
        end
    end
end

--Card Effects--
function discord:CardCallBack(cardId)
	--if cardId == philID then	
end

--Passive Items--
function discord:cache(p, flag)
  local player = Isaac.GetPlayer(0)
  
  if player:HasCollectible(legacy_item) and flag == CacheFlag.CACHE_SPEED then
    player.MoveSpeed = player.MoveSpeed + 0.3
  end
  if player:HasCollectible(legacy_item) and flag == CacheFlag.CACHE_DAMAGE then
    player.Damage = player.Damage + 2
  end 
end

--Active Items--
--Krampuses Horn--
function discord:use_krampus_horn()
    local player = Isaac.GetPlayer(0)
    local entities = Isaac.GetRoomEntities()
    lockPosition = true;
    
    for i = 1, #entities do
        if(entities[i]:IsVulnerableEnemy()) then
            brim = player:FireBrimstone(entities[i].Position);
            brim.Angle = math.deg(math.atan((entities[i].Position.Y - player.Position.Y),(entities[i].Position.X - player.Position.X)))
        end
    end
return true
end

--The Shart--
function discord:use_shart()
	local chance = math.random(1, 2)
	if chance == 1 then
		for i = 1, 3 do
			local player = Isaac.GetPlayer(0)
			local pos = Isaac.GetFreeNearPosition(player.Position, 80.0);
			Isaac.GridSpawn(GridEntityType.GRID_POOP, 0, pos, false);
		end
	end
	if chance == 2 then
		local player = Isaac.GetPlayer(0)
		local pos = player.Position
		game.ButterBeanFart (game, pos, 3, player, true)
	end
return true
end

--Beggar's Hope--
function discord:use_bhope()
	local room = Game():GetRoom()
	local coinNum = room:GetAliveEnemiesCount();
	local player = Isaac.GetPlayer(0)
	for i = 1, coinNum do
		pos = Isaac.GetFreeNearPosition(player.Position, 80.0);
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, pos, Vector(0, 0), Isaac.GetPlayer(0));
	end
return true
end

--Callbacks--
discord:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, discord.cache);
discord:AddCallback(ModCallbacks.MC_USE_ITEM, discord.use_krampus_horn, krampus_horn);
discord:AddCallback(ModCallbacks.MC_USE_ITEM, discord.use_shart, shart);
discord:AddCallback(ModCallbacks.MC_USE_ITEM, discord.use_bhope, bhope);
discord:AddCallback(ModCallbacks.MC_POST_UPDATE, discord.updateFrame);