local discord = RegisterMod("Discord Mod", 1)
local game = Game()
local room = Room()
local frameCounter = 0;
local lockPosition = false;

--Items--
local legacy_item = Isaac.GetItemIdByName( "Dad's Legacy" )
local krampus_horn = Isaac.GetItemIdByName( "Krampuses Horn" )
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
	if cardId == philID then
		
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

--Callbacks--
discord:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, discord.cache);
discord:AddCallback(ModCallbacks.MC_USE_ITEM, discord.use_krampus_horn, krampus_horn);
discord:AddCallback(ModCallbacks.MC_POST_UPDATE, discord.updateFrame);