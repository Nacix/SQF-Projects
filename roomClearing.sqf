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
		_unit setUnitPos "MIDDLE";
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