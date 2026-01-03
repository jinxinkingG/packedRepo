extends "effect_30000.gd"

#伏骑效果
#【伏骑】小战场，锁定技。非城战，你的兵种默认5盾5弓，并且阵型固定，你方盾兵受到的弓箭伤害时，受击免伤倍率临时增至0.9；你方弓兵射程+1，对骑兵射击时，远程倍率临时增至1.5。

func on_trigger_30003()->bool:
	bf.update_extra_formation_setting(
		actorId, ske.skill_name, "常规", {
			"兵种数量": {"步": 5, "弓": 5},
			"分配顺序": ["步", "弓"],
		}
	)

	# 固定阵型
	var bf = DataManager.get_current_battle_fight()
	if actorId == bf.get_attacker_id():
		bf.presetAttackerFormation = 8
	elif actorId == bf.get_defender_id():
		bf.presetDefenderFormation = 8
	return false

func on_trigger_30024() -> bool:
	var unitId = get_env_int("白兵.初始化单位ID")
	var bu = get_battle_unit(unitId)
	if bu == null:
		return false
	if bu.Type == "步":
		bu.reset_combat_info("步(刀盾)")
	elif bu.Type == "弓":
		bu.reset_combat_info("弓(伏骑)")
		bu.mark_buffed()
	return false
