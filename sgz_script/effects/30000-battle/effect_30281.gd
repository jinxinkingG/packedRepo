extends "effect_30000.gd"

# 暴矢效果
#【暴矢】小战场，锁定技。白刃战布阵结束后，你的步兵变为弓兵，你的弓兵有X*10%概率造成150%伤害，X=本轮初始，你的骑兵单位个数。

func on_trigger_30005() -> bool:
	for bu in bf.battle_units(actorId):
		if bu.get_unit_type() == "步":
			bu.reset_combat_info("弓")
	return false

func on_trigger_30009() -> bool:
	var x = 0
	for bu in bf.battle_units(actorId):
		if bu.get_unit_type() == "骑":
			x += 1
	# TODO，改造 ske.battle_enhance_unit 以兼容双层 BUFF
	for bu in bf.battle_units(actorId):
		if bu.get_unit_type() != "弓":
			continue
		if x <= 0:
			bu.dic_combat.erase(ske.skill_name)
		else:
			bu.dic_combat[ske.skill_name] = {
				"射箭爆率": 0.1 * x,
				"BUFF": 1
			}
		bu.requires_update = true
	return false
