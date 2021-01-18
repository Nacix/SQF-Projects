_player = _this select 1;


// TODO: Make a max unit count


// Despawns the deceased unit after 30 seconds
unitCleanup = {
	params ["_unit"];
	uisleep 30;
	deleteVehicle _unit;
};

// Checks if the player is a medic
if (_player getVariable "ace_medical_medicclass" >= 1) then {
	[_this select 0, 3] call BIS_fnc_dataTerminalAnimate; // Animates the fancy box
	sleep 5;
	_medicalTrainingGroup = createGroup west; // Makes a new group for the medical dummies. Gotta change this because there's a group limit
	
	// Grabs every patient spawner within 100 meters and adds them to an array.
	_spawnerList = [];
	{
		if (toLower _x find "patientspawn" != -1 && markerPos _x distance (_this select 0) < 100) then {
			_spawnerList pushBack _x;
		};
	} foreach allMapMarkers;
	
	// Creates a dummy at a random PatientSpawn marker and turns them into a vegetable.
	'B_Soldier_VR_F' createUnit [markerPos (_spawnerList select floor random count _spawnerList), _medicalTrainingGroup, 'pat = this; dostop pat'];
	pat disableAI "PATH";
	
	// Activates the unitCleanup function when a unit in the medical training group is killed
	{
		_x addEventHandler ["Killed", {
			params ["_unit", "_killer", "_instigator", "_useEffects"];
			[_unit] spawn unitCleanup;
		}];
	} forEach (units _medicalTrainingGroup);
	
	
	// Activates the unitCleanup function and makes a cool noise when the unit is successfully healed
	successHandler = {
		params ["_unit", "_player"];
		waitUntil {!(_unit call ACE_medical_ai_fnc_isInjured) || !alive _unit;};
		if (alive _unit) then {PlaySound "Hint";};
		hint "Patient Stabilized Successfully!";
		[_unit] spawn unitCleanup;
	};
	[pat, _player] spawn successHandler;
	

	// Applies randomized ace3 damage to the patient on eacvh limb.
	[pat, selectRandom[0,0.3,0.5,0.7,0.9], "LeftLeg", selectrandom ["stab", "bullet", "falling"]] call ace_medical_fnc_addDamageToUnit;
	[pat, selectRandom[0,0.3,0.5,0.7,0.9], "RightLeg", selectrandom ["stab", "bullet", "falling"]] call ace_medical_fnc_addDamageToUnit;
	[pat, selectRandom[0,0.3,0.5,0.7,0.9], "Body", selectrandom ["stab", "bullet", "falling"]] call ace_medical_fnc_addDamageToUnit;
	[pat, selectRandom[0,0.3,0.5,0.7,0.9], "Head", selectrandom ["stab", "bullet", "falling"]] call ace_medical_fnc_addDamageToUnit;
	[pat, selectRandom[0,0.3,0.5,0.7,0.9], "RightArm", selectrandom ["stab", "bullet", "falling"]] call ace_medical_fnc_addDamageToUnit;
	[pat, selectRandom[0,0.3,0.5,0.7,0.9], "LeftArm", selectrandom ["stab", "bullet", "falling"]] call ace_medical_fnc_addDamageToUnit;

	[_this select 0, 0] call BIS_fnc_dataTerminalAnimate // Stops animating the fancy box
}
else {
	// Yells at the player if they're not a medic
	systemChat "Only medical staff can spawn patients!";
};

/* Box Init

if (isServer) then {
[this, ["Spawn Patient","medicalTrainer.sqf", {}]]
remoteExec ["addAction", ["call", 0], true];
};

*/

