params ["_marker", "_aiGroup"]; // [this] execVM "thisScript.sqf";

_markerPos = getPosVisual _marker;
_markerElev = getPosATL _marker;
_markerDir = getDirVisual _marker;

/*
_unit = (_aiGroup) createUnit ["O_Soldier_VR_F", _markerPos, [], 0, "CAN_COLLIDE"];

_unit setPos _markerPos;
_unit setPosATL _markerElev;
_unit setDir _markerDir;
_unit disableAI "PATH";
	
[_unit] execVM "roomClearing.sqf";
*/