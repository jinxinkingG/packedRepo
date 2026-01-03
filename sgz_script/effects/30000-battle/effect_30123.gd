extends "effect_30000.gd"

#戟士技能实现
#【戟士】小战场，锁定技。你默认4骑6步，你的步兵攻击距离1~2。你方步兵攻击范围内不存在敌兵时变为弓兵，你方弓兵1~2格内存在敌兵时，变为步兵。

const ENHANCEMENT = {
	"近战距离": 2,
}

func on_trigger_30003()->bool:
	bf.update_extra_formation_setting(
		actorId, ske.skill_name, "常规", {
			"兵种数量": {"步":6, "弓":0, "骑":4},
		}
	)
	return false

func on_trigger_30009()->bool:
	for bu in DataManager.battle_units:
		if bu.leaderId != actorId:
			continue
		if not bu.get_unit_type() in ["弓", "步"]:
			continue
		var enemiesAround = 0
		var offsets = StaticManager.NEARBY_DIRECTIONS.duplicate()
		for dir in StaticManager.NEARBY_DIRECTIONS:
			offsets.append(dir * 2)
		for offset in offsets:
			var pos = bu.unit_position + offset
			var target = DataManager.get_battle_unit_by_position(pos)
			if target == null or target.disabled:
				continue
			if target.leaderId == actorId:
				continue
			enemiesAround += 1
		if enemiesAround > 0 and bu.get_unit_type() == "弓":
			bu.init_combat_info("步")
		elif enemiesAround == 0 and bu.get_unit_type() == "步":
			bu.init_combat_info("弓")
	return false

func on_trigger_30024()->bool:
	ske.battle_enhance_current_unit(ENHANCEMENT, ["步"])
	return false
