extends "effect_10000.gd"

#德助效果
#【德助】内政，太守技。每年3/6/9/12月初始若本城民忠＞＝50，概率触发民众资助事件，民忠越高，效果越好。
#每年3/6/9/12月初始，若本城民忠＞＝50，概率触发民众资助事件，民忠越高，效果越好。 （括号内不写进游戏内：情况1，获得10～50米。情况2，获得10～50金。情况3，遇见铁匠，可以把装备库的1～4级武器或者1～4级防具，提高1个档次，锤子的话，先不考虑。情况4，获得1个宝。民忠50～74，触发1和2；民忠75～89触发1～3，民忠90～100，触发1～4）

const EVENTS = [
	{"米": {"min": 10, "max": 50}},
	{"金": {"min": 10, "max": 50}},
	{"武器升级": {"min": 1, "max": 4}},
	{"宝": {"min": 1, "max": 1}},
]

func on_trigger_10001()->bool:
	if DataManager.month % 3 != 0: # 3/6/9/12
		return false
	var cityId = get_working_city_id()
	if cityId < 0:
		return false
	var city = clCity.city(cityId)
	var loy = city.get_loyalty()
	if loy < 50:
		return false
	var chances = [0,1]
	if loy >= 75:
		chances = [0,1,2]
	if loy >= 90:
		chances = [2,3]
	_random_event(city, chances)
	return false

func _random_event(city, chances)->void:
	if chances.empty():
		return
	chances.shuffle()
	var event = Global.dicval(EVENTS[chances[0]])
	var somethingHappened = false
	for key in event:
		if key == "武器升级":
			# 武器升级
			var vs = clVState.vstate(city.get_vstate_id())
			var equipToUpgrade = null
			for item in vs.list_stored_equipments():
				var equip = item[0]
				if equip.type != "武器":
					continue
				var score = equip.level_score()
				if score < int(event[key]["min"]) or score > int(event[key]["max"]):
					continue
				equipToUpgrade = equip
				break
			if equipToUpgrade == null:
				continue
			var properLevel = -1
			var upgradedEquip = null
			for equip in clEquip.all_equips(equipToUpgrade.type):
				if equip.subtype() != equipToUpgrade.subtype():
					continue
				if equip.level_score() <= equipToUpgrade.level_score():
					continue
				if properLevel > 0 and equip.level_score() >= properLevel:
					continue
				properLevel = equip.level_score()
				upgradedEquip = equip
			if upgradedEquip == null:
				continue
			vs.remove_stored_equipment(equipToUpgrade)
			vs.add_stored_equipment(upgradedEquip)
			somethingHappened = true
			if DataManager.get_scene_actor_control(actorId) >= 0:
				var msg = "民众感念德政，聘请匠人为我军升级装备，将一把{0}重铸为{1}".format([
					equipToUpgrade.name(), upgradedEquip.name(),
				])
				city.attach_free_dialog(msg, actorId, 1)
		else:
			# 普通贡献
			var minVal = int(event[key]["min"])
			var maxVal = int(event[key]["max"])
			var val = Global.get_random(minVal, maxVal)
			val = city.add_city_property(key, val)
			if val > 0:
				somethingHappened = true
				if DataManager.get_scene_actor_control(actorId) >= 0:
					var msg = "民众感念德政，襄助 {0}{1}".format([val, key])
					city.attach_free_dialog(msg, actorId, 1)
	if somethingHappened:
		return
	# 什么都没发生
	chances.remove(0)
	_random_event(city, chances)
	return
