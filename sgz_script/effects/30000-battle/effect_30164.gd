extends "effect_30000.gd"

#励精技能实现
#【励精】小战场，锁定技。你方单位击杀对方主将时，你获得对方25%经验，但最大不超过5000。

func on_trigger_30023()->bool:
	var bu = ske.battle_is_unit_hit_by(UNIT_TYPE_SOLDIERS, ["将"], ["ALL"])
	if bu == null:
		return false
	var targetUnitId = DataManager.get_env_int("白兵.受伤单位")
	var targetUnit = get_battle_unit(targetUnitId)
	if targetUnit == null or targetUnit.get_hp() > 0 or not targetUnit.disabled:
		# 未被击杀
		return false

	var robExp = min(5000, int(enemy.actor().get_exp() / 4))
	ske.change_actor_exp(enemy.actorId, -robExp)
	ske.change_actor_exp(actorId, robExp)
	# 汇报到大战场
	ske.war_report()
	# 有可能重复触发，加 CD，但在 report 之后，避免误解
	ske.battle_cd(99999)
	return false
