params ["_unit"];

unitRespawn = {
	params ["_unit", "_unitPos", "_unitDir", "_unitType", "_unitGroup", "_unitElev"];
	
	sleep 5;
	{deleteVehicle _x;} forEach (nearestObjects [_unitPos, ["GroundWeaponHolder", "WeaponHolderSimulated"], 5]); // Deletes any dropped weapons within 5m of the unit
	//{deleteVehicle _x;} forEach (_unitPos nearObjects [["GroundWeaponHolder", "WeaponHolderSimulated"], 5]); // Deletes any dropped weapons within 5m of the unit
	deleteVehicle _unit;
	
	// Creates a new unit at the original position and direction
	_unit = _unitGroup createUnit [_unitType, _unitPos, [], 0, "CAN_COLLIDE"];
	_unit disableAI "ALL";
	_unit allowDamage true;
	_unit setPosATL _unitElev;
	_unit setDir _unitDir;
	
	_unitPos = getPosVisual _unit;
	_unitDir = getDirVisual _unit;
	_unitType = typeOf _unit;
	_unitGroup = group _unit;
	_unitElev = getPosATL _unit;
	
	_unit addAction ["Transfer Loadout", {
		_loadout = getUnitLoadout (_this select 1);
		_loadout set [3, ""];
		(_this select 0) setUnitLoadout [_loadout, true];
	}];
	
	waitUntil { !alive _unit };
	[_unit, _unitPos, _unitDir, _unitType, _unitGroup, _unitElev] spawn unitRespawn
};

_unit disableAI "ALL";
_unit allowDamage true;

_unitPos = getPosVisual _unit;
_unitDir = getDirVisual _unit;
_unitType = typeOf _unit;
_unitGroup = group _unit;
_unitElev = getPosATL _unit;

waitUntil { !alive _unit };
[_unit, _unitPos, _unitDir, _unitType, _unitGroup, _unitElev] spawn unitRespawn;

/* Current Obj. Init.

[this] execVM "LoadoutTransfer.sqf";

this addAction ["Transfer Loadout", { 
 _loadout = getUnitLoadout (_this select 1); 
 _loadout set [3, ""]; 
 (_this select 0) setUnitLoadout [_loadout, true]; 
}];

*/