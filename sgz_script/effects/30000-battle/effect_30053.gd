extends "effect_30000.gd"

#神符效果实现
#【神符】小战场,锁定技。你方士兵单位被击杀时，可发动黄巾军秘术，使得剩余每个士兵单位的兵力+x，x＝你的等级。

func check_trigger_correct():
	#self.trace = true

	if not DataManager.common_variable.has("白兵.受伤单位"):
		return false

	var unitId = int(DataManager.common_variable["白兵.受伤单位"])
	if unitId < 0 or unitId >= DataManager.battle_units.size():
		return false
	var bu = DataManager.battle_units[unitId]
	if bu.leaderId != self.actorId:
		return false
	if bu.get_unit_type() == "将":
		return false
	if not bu.disabled:
		return false

	# 我方单位被攻击后消灭
	var actor = ActorHelper.actor(self.actorId)
	var x:int = actor.get_level()
	for _bu in DataManager.battle_units:
		if _bu.leaderId != self.actorId:
			continue
		if _bu.get_unit_type() in ["将", "城门"]:
			continue
		if _bu.disabled:
			continue
		_bu.set_hp(_bu.get_hp() + x, true)

	return false
