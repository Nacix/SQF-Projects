_player = _this select 1;

// Checks if the player is an engineer
if (_player getVariable "ACE_IsEngineer" >= 1) then {
	[_this select 0, 3] call BIS_fnc_dataTerminalAnimate; // Animates the fancy box
	sleep 5;

	{
		_localHitPoints = getAllHitPointsDamage _x select 0;
		if ((_x getVariable "isVehicleDummy") && !(_x getVariable "isDamaged")) then {
			_vehicle = _x;
			systemChat "we goin";
			{
				if (!("wheel" in toLower _x)) then {
					[_vehicle, _forEachIndex, selectRandom[0.3, 0.5, 0.75, 0.85], false] call ace_repair_fnc_setHitPointDamage;
				} else {
					[_vehicle, _forEachIndex, selectRandom[0.4, 0.6, 0.85, 1.0], false] call ace_repair_fnc_setHitPointDamage;
				};
				// sleep 0.05;
				//_vehicle setHitIndex [_forEachIndex, selectRandom[0.3,0.5,0.7,0.85], true];
			} foreach (getAllHitPointsDamage _x select 0);
			_x setVariable ["isDamaged", true];
		} else {
			systemChat "we comin back";
			[_player, _x] call ace_repair_fnc_doFullRepair;
			_x setVariable ["isDamaged", false];
		}
	} foreach ((nearestObjects [(_this select 0), [], 100]));

	[_this select 0, 0] call BIS_fnc_dataTerminalAnimate // Stops animating the fancy box
}
else {
	// Yells at the player if they're not an engineer
	systemChat "Only vehicle staff can use this!";
};

//[veh, selectRandom[0.3,0.5,0.7,0.9], "LeftLeg", selectrandom ["stab", "bullet", "falling"]] call ace_medical_fnc_addDamageToUnit;

/* Box Init

if (isServer) then {
[this, ["Damage Vehicles","engineeringTrainer.sqf", {}]]
remoteExec ["addAction", ["call", 0], true];
};