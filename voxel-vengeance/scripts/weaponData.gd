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
		"shakeFade": 15
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
		"shakeFade": 20
		}
}
var tempDict = {}
func getWeaponData():
	for item in weaponDict:
		if Main.currentWeapon == item:
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
	return tempDict
