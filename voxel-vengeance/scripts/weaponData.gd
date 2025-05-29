extends Node

var weaponDict = {
	"ak47": {
		"crosshair": "std_crosshair",
		"distance": 10,
		"shrinkSpeed": 20,
		"growSpeed": 20,
		"maxSpread": 5,
		"cooldown": 0.2,
		"spawnPosition": Vector3(0.4,0,0),
		"autofire": true,
		"bulletSpeed":140,
		"damage": 5,
		"shakeStrength": 0.1,
		"shakeFade": 15,
		"angle": 0,
		"bulletNum": 1,
			},
	"pistol": {
		"crosshair": "std_crosshair",
		"distance": 5,
		"shrinkSpeed": 20,
		"growSpeed": 10,
		"maxSpread": 3,
		"cooldown": 0.3,
		"spawnPosition": Vector3(0,0,-.2),
		"autofire": false,
		"bulletSpeed":200,
		"damage": 10,
		"shakeStrength": 0.15,
		"shakeFade": 20,
		"angle": 0,
		"bulletNum": 1,
		},
	"shotgun": {
		"crosshair": "pump_crosshair",
		"distance": 3,
		"shrinkSpeed": 5,
		"growSpeed": 20,
		"maxSpread": 10,
		"cooldown": 1,
		"spawnPosition": Vector3(0.4,0,0),
		"autofire": false,
		"bulletSpeed":80,
		"damage": 15,
		"shakeStrength": 0.4,
		"shakeFade": 5,
		"angle": 45,
		"bulletNum": 5,
	},
	"sniper": {
		"crosshair": "std_crosshair",
		"distance": 55,
		"shrinkSpeed": 50,
		"growSpeed": 50,
		"maxSpread": 50,
		"cooldown": 2,
		"spawnPosition": Vector3(0.4,0,0),
		"autofire": false,
		"bulletSpeed":400,
		"damage": 50,
		"shakeStrength": 0.5,
		"shakeFade": 5,
		"angle": 0,
		"bulletNum": 1,
	}
}
var tempDict = {}
func getWeaponData(weaponName):
	for item in weaponDict:
		if weaponName == item:
			tempDict["crosshair"] = get_node("/root/main/Crosshairs/" + str(weaponDict[item]["crosshair"]))
			tempDict["weaponname"] = item
			tempDict["rayLength"] = weaponDict[item]["distance"]
			tempDict["shrinkSpeed"] = weaponDict[item]["shrinkSpeed"]
			tempDict["growSpeed"] = weaponDict[item]["growSpeed"]
			tempDict["maxSpread"] = weaponDict[item]["maxSpread"]
			tempDict["cooldown"] = weaponDict[item]["cooldown"]
			tempDict["spawnPosition"] = weaponDict[item]["spawnPosition"]
			tempDict["autofire"] = weaponDict[item]["autofire"]
			tempDict["bulletSpeed"] = weaponDict[item]["bulletSpeed"]
			tempDict["damage"] = weaponDict[item]["damage"]
			tempDict["shakeStrength"] = weaponDict[item]["shakeStrength"]
			tempDict["shakeFade"] = weaponDict[item]["shakeFade"]
			tempDict["angle"] = weaponDict[item]["angle"]
			tempDict["bulletNum"] = weaponDict[item]["bulletNum"]
	return tempDict
