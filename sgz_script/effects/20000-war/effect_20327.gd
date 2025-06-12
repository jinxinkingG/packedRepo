extends "effect_20000.gd"

#毅谋诱发效果
#【毅谋】大战场，诱发技。若你兵力不为0，己方武将被用伤兵计时才能发动。若那次计策成功，你代替受到计策伤害。每个回合限1次。

const EFFECT_ID = 20327
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20012()->bool:
	if me == null or me.disabled:
		return false

	var se = DataManager.get_current_stratagem_execution()
	if not se.damage_soldier():
		return false
	if se.succeeded <= 0:
		return false

	var wa = DataManager.get_war_actor(se.targetId)
	if not me.is_teammate(wa):
		return false

	var damage = se.get_soldier_damage_for(se.targetId)
	if damage <= 0:
		return false

	# 自己得有兵
	if actor.get_soldiers() <= 0:
		return false

	return true

func effect_20327_AI_start():
	goto_step("start")
	return

func effect_20327_start():
	var se = DataManager.get_current_stratagem_execution()
	var damage = se.get_soldier_damage_for(se.targetId)

	ske.cost_war_cd(1)
	var recover = ske.cost_self_soldiers(damage)
	if recover > 0:
		ske.change_actor_soldiers(se.targetId, recover)
	var msg = "{0}所在险要\n此难吾部当之！".format([
		DataManager.get_actor_honored_title(se.targetId, actorId)
	])
	report_skill_result_message(ske, 2000, msg, 0)
	return

func on_view_model_2000()->void:
	wait_for_pending_message(FLOW_BASE + "_2", "")
	return

func effect_20327_2():
	report_skill_result_message(ske, 2000)
	return
