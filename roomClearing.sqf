params ["_unit", "_mode", "_loadoutList", "_object", "_difficulty"]; // [this] execVM "roomClearing.sqf";

// Resolves a bug/conflict? where the AI combat mode is changed to GREEN
behaviorFix = {
	params ["_unitGroup"];
	while { { alive _x } count units _unitGroup != 0 } do {
		sleep 0.3;
		if (combatMode _unitGroup != "YELLOW") then {
			systemChat format ["Fixing group assignment ( %1 -> YELLOW )", combatMode _unitGroup];
			_unitGroup setCombatMode "YELLOW";
		};
	};
};

// Automatically respawns groups/units
autoSpawner = {
	params ["_unit", "_mode", "_unitPos","_unitDir","_unitType", "_unitGroup", "_unitElev", "_loadoutList", "_object", "_difficulty"];
	while { true } do {
		if ( _mode <= 2) then {
			waitUntil {{ alive _x } count units _unitGroup == 0}; // Waits for all the units in the group to die
		} else {
			waitUntil { !alive _unit }; // Waits for the unit to die
		};
		[_unit, _mode, _unitPos, _unitDir, _unitType, _unitGroup, _unitElev, _loadoutList, _object, _difficulty] spawn targetRespawner; // Creates and initializes a respawned unit
		if ( _mode <= 2) then {
			waitUntil {{ alive _x } count units _unitGroup != 0}; // Waits for the units to respawn before continuing the loop
		} else {
			waitUntil { alive _unit }; // Waits for the unit to respawn before continuing the loop
		};
	};
};

// Runs the respawn function once
triggerSpawner = {
	params ["_unit", "_mode", "_unitPos","_unitDir","_unitType", "_unitGroup", "_unitElev", "_loadoutList", "_object", "_difficulty"];
	waitUntil {{ alive _x } count units _unitGroup == 0}; // Waits for all the units in the group to die
	[_unit, _mode, _unitPos, _unitDir, _unitType, _unitGroup, _unitElev, _loadoutList, _object, _difficulty] spawn targetRespawner;
	// waitUntil {{ alive _x } count units _unitGroup != 0}; // Waits for the units to respawn before ending the function (Might be unneeded)
};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

targetRespawner = {
	params ["_unit", "_mode", "_unitPos","_unitDir","_unitType", "_unitGroup", "_unitElev", "_loadoutList", "_object", "_difficulty"];
	
	sleep 10;
	{deleteVehicle _x;} forEach (nearestObjects [_unitPos, ["GroundWeaponHolder","WeaponHolderSimulated"],5]); // Deletes any dropped weapons within 5m of the unit
	deleteVehicle _unit;
	
	// Creates a new unit at the original position and direction
	_unit = _unitGroup createUnit [_unitType, _unitPos, [], 0, "CAN_COLLIDE"];
	_unit enableAI "ALL";
	_unit disableAI "PATH";
	_unit allowDamage true;
	_unit setPosATL _unitElev;
	_unit setDir _unitDir;
	_unit setVehicleVarName unitVarName;
	
	// Adds Zeus compatibility to units (ruined by dalton)
	/*
	{
		_x addCuratorEditableObjects [[_unit],false];
	} forEach allCurators;
	*/
	
	// Configures the unit's AI settings
	if (_mode <= 1) then {
		_unit setUnitPos "MIDDLE"; // This stupid little command (behaviorFix too) has an entire lore behind it. Check the block comment down below for an epic gamer story.
		if (_mode == 1) then {
			if (_difficulty == 0) then {
				_unit setUnitLoadout selectRandom _loadoutList;
			} else {
				_unit setUnitLoadout (_loadoutList select (_difficulty - 1));
			};
		} 
		else { 
			// _unit setUnitPos "MIDDLE";
			_unit allowDamage false;
		};
		[_unitGroup] spawn behaviorFix;
	};
	if (_mode == 0) then {
		_object setVariable ["isRunning", false, true];
	};
};

// Sets the unit's loadout
if (_mode <= 1) then {
	if (_difficulty == 0) then {
		_unit setUnitLoadout selectRandom _loadoutList;
	} else {
		_unit setUnitLoadout (_loadoutList select (_difficulty - 1));
	}
 };
 
 // Initializes the unit's properties
_unit enableAI "ALL";
_unit disableAI "PATH";
_unit allowDamage true;

// Grabs unit's data and saves it for the respawn
_unitPos = getPosVisual _unit;
_unitDir = getDirVisual _unit;
_unitType = typeOf _unit;
_unitGroup = group _unit;
_unitElev = getPosATL _unit;

unitVarName = vehicleVarName _unit;

// Sets up the unit for respawn
 if (_mode == 0) then {
	[_unit, _mode, _unitPos, _unitDir, _unitType, _unitGroup, _unitElev, _loadoutList, _object, _difficulty] spawn triggerSpawner;
} else {
	[_unit, _mode, _unitPos, _unitDir, _unitType, _unitGroup, _unitElev, _loadoutList, _object, _difficulty] spawn autoSpawner;
};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
	Okay so you're probably wondering how much significance a stance change could have possily had on this entire script. 
	It was a big one. It's probably the reason you're reading this and this file isn't just sitting in my Arma Project folder.
	The story behind it starts with the dynamic loadout assignment. When I started assigning the custom loadouts to the braindead respawned AI,
	they couldn't figure out what was going on so they would constanly safety and unsafety their weapons while staring very angrily at me.
	This happened seemingly at random; about 40% the respawn waves had the issue. Occasionally, the AI would also shoot once or twice and then go back to safteying.
	These parameters led me to believe that the reasoning behind this bug couldn't make any sense at all since there was no logical pattern behind it.
	I tried everything to fix this, including manually blacklisting the broken animations, micromanaging the AI processing, and setting the loadout manually rather than using a nice clean array.
	Those are just the fun ones, I tried tons of other small fixes that never went anywhere. After two days of dead-end brainblasts, I finally found a fix.
	
	To pinpoint the exact cause of this bug, I began compiling a list of all the functions and commands in SQF that handled combat, weapon handling,
	movement, or pretty much anything that the AI could do. Once I had the list set up, I began printing out each variable when a new group spawned in
	so I could see what all changed when the unit spawned in normally vs autistically. Once I had gotten to the combatMode command, I noticed that when the AI stopped functioning,
	their combat state had moved to GREEN, meaning that they would not fire under any circumstances and would hold position. I quickly threw together a 
	function that would correct this problem whenever the AI's combat mode changed from YELLOW and started another session. The problem was still there
	even after the combatMode change and I died a little inside.
	
	Because I was lazy and didn't want to go through another dozen commands, I started playing around with anything I could use to override the animations
	and AI logic. I handcuffed a dude, shot him, and unhandcuffed him so he would maybe do something? I didn't know at that point tbh.
	Once I freed the AI unit, he crouched down and healed himself before I could mess with him more, and then proceeded to shoot me 10 times in the face before standing back up
	and resuming autism mode. That was the moment where I had the completely luck-based brainblast that saved this script. I found a command that changes unit position, set it
	to crouch, and started yet another session (I started like 100 new sessions trying to fix this).
	Of course, the wackass AI decided not to listen to the crouch command, but the game still had him flagged as being crouched, meaning that he would not be
	able to perform the animations that were breaking him previously, even when he crouched on his own since the flag was explicitly assigned via the script.
/*