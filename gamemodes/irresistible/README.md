# Irresistible Gaming Development Framework
#### Copyright (C) 2011-2019

**Source Contributors:**  Lorenc, Stev, Damen

**BIG THANKS to Stev, Nibble, Banging7Grams, Kova, Queen and Panther for making this possible.**

### Custom Script Callbacks

- `SetPlayerRandomSpawn( playerid )`
    - Called when a player is attempting to be respawned somewhere randomly
- `OnServerUpdate( )`
    - Called every second (or sooner) indefinitely
- `OnServerTickSecond( )`
    - Called every second (specifically) indefinitely
- `OnPlayerUpdateEx( playerid )`
    - Same interval as OnServerUpdate, but it is called indefinitely for every player in-game
    - When you wish to update something frequently, but not use OnPlayerUpdate
- `OnPlayerTickSecond( playerid )`
    - Called every second (specifically a second) for a player, indefinitely
- `OnServerGameDayEnd( )`
    - Called every 24 hours in-game (basically when a new day starts)
- `OnNpcConnect( npcid )`
    - Called specifically when an NPC connects, as OnPlayerConnect will not
- `OnNpcDisconnect( npcid, reason )`
    - Called specifically when an NPC disconnects, as OnPlayerDisconnect will not
- `OnPlayerDriveVehicle( playerid, vehicleid )`
    - Called when a player enters a vehicle as a driver
- `OnPlayerPassedBanCheck( playerid )`
    - Called when a player passes a ban check (done before authenticating)
- `OnPlayerRegister( playerid )`
    - Called when a player successfully registers an account
- `OnPlayerLogin( playerid )`
    - Called when a player successfully logs into their account
- `OnHouseOwnerChange( houseid, ownerid )`
    - Called when the ownership of a home is changed
- `OnPlayerFirstSpawn( playerid )`
    - Called when a player spawns for the first time
- `OnPlayerMovieMode( playerid, toggled )`
    - Called when player toggles movie mode
- `OnPlayerAccessEntrance( playerid, entranceid )`
    - Called when a player accesses an entrance id
- `OnPlayerEndModelPreview( playerid, handleid )`
	- Called when a player closes a model preview
- `OnGangLoad( gangid )`
    - Called when a gang is loaded
- `OnGangUnload( gangid, bool: deleted )`
    - Called when a gang is unloaded (or deleted)
- `OnPlayerJoinGang( playerid, gangid )`
    - Called when a player joins a gang
- `OnPlayerLeaveGang( playerid, gangid, reason )`
    - Called when a player leaves a gang
- `OnPlayerEnterHouse( playerid, houseid )`
    - Called when a player enters a house
- `OnPlayerAttemptBreakIn( playerid, houseid, businessid )`
    - Called when a player attempts to break into a business/house
- `OnPlayerLoadTextdraws( playerid )`
    - Called when a player is loading textdraws
- `OnPlayerUnloadTextdraws( playerid )`
    - Called when a player is unloading textdraws (on death, request class...)
- `OnPlayerC4Blown( playerid, Float: X, Float: Y, Float: Z, worldid )`
    - Called when a player C4 is blown
- `OnPlayerJailed( playerid )`
    - Called when a player is jailed
- `OnPlayerUnjailed( playerid, reasonid )`
    - Called when a player is unjailed for a reason id
- `OnPlayerArrested( playerid, victimid, totalarrests, totalpeople )`
    - Called when a player is arrested
- `OnPlayerMoneyChanged( playerid, amount )`
    - Called when a player's money is changed
- `OnServerVariablesLoaded( )`
    - Called when server variables are fully loaded
