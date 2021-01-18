// TODO: Add a parameter for effective range
// TODO: Add a counter to check total/remaining hostiles

/* Tutorial (Loadouts)
	copy thing
*/

params ["", "", "", "_params"];

if ((_this select 0) getVariable "isRunning") exitWith { 
		systemChat "A simulation is already running or is under cooldown!"; 
};

_loadoutList = _params select 0;
_difficulty = _params select 1;
_object = _this select 0;

scriptStarter = {
	params ["_object", "_loadoutList", "_firstTime", "_difficulty"];
	_targetUnits = [];
	{
		if (vehicleVarName _x == vehicleVarName _object && vehicleVarName _x != "") then {
			_object setVariable ["isRunning", true, true];
			if (alive _x) then {
				_targetUnits pushback _x;
			};
		};
	} forEach (nearestObjects [_object, ["O_Soldier_VR_F"], 9999]);
	
	{
		_x setVariable ["script", [_x, 0, _loadoutList, _object, _difficulty] execVM "roomClearing.sqf", true];
	} forEach _targetUnits;
	
	[_targetUnits] spawn killTracker;
	
	uiSleep 6.2;
	[_object, 0] call BIS_fnc_dataTerminalAnimate;
};

killTracker = {
	params ["_targetUnits"];
	
	_startTime = diag_tickTime;
	_count = count _targetUnits;
	
	while { _count != 0 } do {
		uiSleep 0.15;
		{
			if (!alive _x) then {
				_count = _count - 1;
				_targetUnits deleteAt _forEachIndex;
			};
		} forEach _targetUnits;
		hintSilent format ["Remaining Enemies: %1", _count];
	};
	
	hintSilent format ["Simulation Complete!\nTime Elapsed: %1", [(diag_tickTime - _startTime), "HH:MM:SS", false] call BIS_fnc_secondsToString];
};

if (!(_object getVariable "isRunning")) then {
	[_object, 3] call BIS_fnc_dataTerminalAnimate;
	[_object, _loadoutList, true, _difficulty] spawn scriptStarter;
} 
else 
{ 
	systemChat "A simulation is already running or is under cooldown!";
};

// local variable waituntil instead of cooldown so each mode has its own thing? -- yes yes do this

// Temp: Delete anything below this line:

/*



*/




























/*
_loadoutVeryEasy = [[],[],["rhsusf_weap_m9","","","",["rhsusf_mag_15Rnd_9x19_JHP",15],[],""],[],["V_Pocketed_olive_F",[["rhsusf_mag_15Rnd_9x19_JHP",11,15]]],["B_Messenger_Coyote_F",[["ACE_Banana",140]]],"LOP_H_Pakol","G_Balaclava_oli",[],["","","","","",""]];

_loadoutEasy = [["rhs_weap_m3a1","","","",["rhsgref_30rnd_1143x23_M1911B_SMG",30],[],""],[],[],[],["rhsgref_TacVest_ERDL",[["rhsgref_30rnd_1143x23_M1911B_SMG",5,30]]],["B_Messenger_Olive_F",[["rhsgref_30rnd_1143x23_M1911B_SMG",8,30]]],"LOP_H_Beanie_marpat","rhssaf_veil_Green",[],["","","","","",""]];

_loadoutNormal = [["rhs_weap_MP44","","","",["rhsgref_30Rnd_792x33_SmE_StG",30],[],""],[],[],[],["rhsgref_TacVest_ERDL",[["rhsgref_30Rnd_792x33_SmE_StG",8,30]]],["B_RadioBag_01_wdl_F",[["rhsgref_30Rnd_792x33_SmE_StG",6,30]]],"LOP_H_6B27M_ess_Flora","CUP_FR_NeckScarf5",[],["","","","","",""]];

_loadoutHard = [["arifle_AKS_F","","","",["30Rnd_545x39_Mag_Tracer_F",30],[],""],[],[],[],["CUP_V_CZ_vest15",[["30Rnd_545x39_Mag_Tracer_F",2,30]]],[],"LOP_H_ChDKZ_Beret","G_Bandanna_khk",[],["","","","","",""]];

_loadoutVeryHard = [["arifle_AKS_F","","","",["30Rnd_545x39_Mag_F",30],[],""],[],[],[],["LOP_V_6B23_CDF",[["30Rnd_545x39_Mag_Tracer_F",2,30]]],["B_RadioBag_01_wdl_F",[["30Rnd_545x39_Mag_Tracer_F",10,30]]],"LOP_H_6B27M_ess_CDF","G_Balaclava_blk",[],["","","","","",""]];

_loadoutList = [_loadoutVeryEasy, _loadoutEasy, _loadoutNormal, _loadoutHard, _loadoutVeryHard];
*/