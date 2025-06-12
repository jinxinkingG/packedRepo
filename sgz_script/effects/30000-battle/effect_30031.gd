extends "effect_30000.gd"

#锐取效果实现
#【锐取】小战场,锁定技。非城地形，若你为攻方，每回合初，你方最前方的两排士兵在本回合获得：基础伤害倍率+0.25，基础减伤倍率+0.06。

const ENHANCEMENT = {
	"额外伤害": 0.25,
	"额外免伤": 0.06,
	"BUFF": 1,
}

func on_trigger_30009():
	# 遍历我方单位，获取各行的前排
	var max_x = -1
	var second_x = -1
	# 计算最前排的 x 坐标
	for bu in DataManager.battle_units:
		if bu == null or bu.disabled or bu.leaderId != actorId:
			continue
		if bu.get_unit_type() in ["将", "城门"]:
			continue
		var x = bu.unit_position.x
		if x > max_x:
			second_x = max_x
			max_x = x
		elif x == max_x:
			continue
		elif x > second_x:
			second_x = x
		if bu.dic_combat.has(ske.skill_name):
			bu.dic_combat.erase(ske.skill_name)
			bu.requires_update = true

	# 为最前方两排加 buff，其他单位去 buff
	for bu in DataManager.battle_units:
		if bu == null or bu.disabled or bu.leaderId != actorId:
			continue
		if bu.get_unit_type() in ["将", "城门"]:
			continue
		var x = bu.unit_position.x
		if x == max_x or x == second_x:
			bu.dic_combat[ske.skill_name] = ENHANCEMENT
			bu.requires_update = true

	return false
