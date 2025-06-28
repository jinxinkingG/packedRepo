extends "effect_20000.gd"

# 熬寒效果
#【熬寒】大战场，锁定技。若你上回合受过伤兵计策的伤害，则本回合你恢复机动力时，可以突破机动力上限的限制，最多回复到你的 [知] 数值。

func on_trigger_20009()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.get_soldier_damage_for(actorId) <= 0:
		return false
	ske.set_war_skill_val(1)
	return false

func on_trigger_20013()->bool:
	if ske.get_war_skill_val_int() <= 0:
		return false
	ske.set_war_skill_val(0)
	var exceededKey = "战争.机动力溢出.{0}".format([actorId])
	var exceeded = DataManager.get_env_int(exceededKey)
	exceeded = min(exceeded, actor.get_wisdom() - me.get_max_action_ap())
	if exceeded > 0:
		ske.change_actor_ap(actorId, exceeded)
	DataManager.unset_env(exceededKey)
	ske.war_report()
	return false
