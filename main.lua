local discord = RegisterMod("TBOI - Prebirth", 1)
local game = Game()
local frameCounter = 0;
local lockPosition = false;

--Items--
local legacy_item = Isaac.GetItemIdByName( "Dad's Legacy" )
local krampus_horn = Isaac.GetItemIdByName( "Krampuses Horn" )
local shart = Isaac.GetItemIdByName( "The Shart" )
local bhope = Isaac.GetItemIdByName("Beggar's Hope")
local threeLeaf = Isaac.GetItemIdByName("Three Leaf Clover")
local dplush = Isaac.GetItemIdByName("Dark Plushie")
local redbrick = Isaac.GetItemIdByName("Red Brick")
local mindseye = Isaac.GetItemIdByName("Mind's Eye")
local philId = Isaac.GetItemIdByName("Philosopher's Stone")
local threeLeafUsed = false
local mindsEyeUsed = false

--Timing--
function discord:updateFrame() 
    local player = Isaac.GetPlayer(0)
    if(lockPosition == true) then 
        player:AddVelocity(Vector(-player.Velocity.X, -player.Velocity.Y));
        frameCounter = frameCounter + 1;
        
        if(frameCounter >= 20) then
            frameCounter = 0;
            lockPosition = false;
        end
    end
end

--Passive Items--
function discord:cache(p, flag)
	local player = Isaac.GetPlayer(0)
  
	--Dad's Legacy--
	if player:HasCollectible(legacy_item) and flag == CacheFlag.CACHE_SPEED then
		player.MoveSpeed = player.MoveSpeed + 0.3
	end
	if player:HasCollectible(legacy_item) and flag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + 2
	end 

	--Red Brick--
	if player:HasCollectible(redbrick) and flag == CacheFlag.CACHE_SPEED then
		player.MoveSpeed = player.MoveSpeed + 0.4
	end
	if player:HasCollectible(redbrick) and flag == CacheFlag.CACHE_LUCK then
		player.Luck = player.Luck - 0.5
	end
	
	--Mind's Eye--
	function getFlag(arr, currentFlag)
		number = currentFlag;
   
		for i = 1, #arr do
			number = number | 2^(arr[i] - 1);
		end
   
		return number;
	end

	if player:HasCollectible(mindseye) and mindsEyeUsed == false then
		if (cacheFlag == CacheFlag.CACHE_TEARFLAG) then
			player.TearFlags = getFlag({1}, player.TearFlags);
		end
		player:AddSoulHearts(4)
		player:AddCard(Card.CARD_WORLD)
		mindsEyeUsed = true
	end
end

--Three Leaf Clover--
function discord:threeLeaf_Effect()
	local player=Isaac.GetPlayer(0)
    if player:HasCollectible(threeLeaf) and threeLeafUsed == false  then
        player:AddBombs(33)
        player:AddKeys(33)
        player:AddCoins(33)
        threeLeafUsed = true
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

--Philosopher's Stone--
function discord:use_philStone()
	local entities = Isaac.GetRoomEntities()
    for i = 1, #entities do
        if entities[i].Variant == PickupVariant.PICKUP_COIN and entities[i].SubType == CoinSubType.COIN_PENNY then
            pos = entities[i].Position
            entities[i]:Remove();
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_NICKEL, pos, Vector(0, 0), Isaac.GetPlayer(0));
        end

        if entities[i].Variant == PickupVariant.PICKUP_COIN and entities[i].SubType == CoinSubType.COIN_NICKEL then
            pos = entities[i].Position
            entities[i]:Remove();
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_DIME, pos, Vector(0, 0), Isaac.GetPlayer(0));
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

--Dark Plushie
function discord:use_dplush()
    local player = Isaac.GetPlayer(0);
    player:AddMaxHearts(-2,true)
    player:UseCard(Cards.JOKER_CARD)
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
discord:AddCallback(ModCallbacks.MC_POST_UPDATE, discord.threeLeaf_Effect);
discord:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, discord.cache);
discord:AddCallback(ModCallbacks.MC_USE_ITEM, discord.use_dplush, dplush);
discord:AddCallback(ModCallbacks.MC_USE_ITEM, discord.use_philStone, philId);
discord:AddCallback(ModCallbacks.MC_USE_ITEM, discord.use_krampus_horn, krampus_horn);
discord:AddCallback(ModCallbacks.MC_USE_ITEM, discord.use_shart, shart);
discord:AddCallback(ModCallbacks.MC_USE_ITEM, discord.use_bhope, bhope);
discord:AddCallback(ModCallbacks.MC_POST_UPDATE, discord.updateFrame);