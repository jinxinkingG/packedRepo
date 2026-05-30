extends "effect_20000.gd"

#趫猛锁定效果
#【趫猛】大战场，锁定技。回合结束时，对自身造成火焰伤害（与主动效果选择的档位对应）。

const ACTIVE_EFFECT_ID = 20723
const EFFECT_ID = 20724
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const DAMAGE_OPTIONS = [50, 100, 150]

func on_trigger_20016()->bool:
	var val = ske.get_war_skill_val_int(ACTIVE_EFFECT_ID)
	if val <= 0:
		return false
	return true

func effect_20724_AI_start():
	goto_step("start")
	return

func effect_20724_start():
	var idx = ske.get_war_skill_val_int(ACTIVE_EFFECT_ID) - 1
	ske.set_war_skill_val(null, 0, ACTIVE_EFFECT_ID)
	var damage = DAMAGE_OPTIONS[idx]

	var stratagem_name = "火计"
	var se = DataManager.new_stratagem_execution(ske.skill_actorId, stratagem_name, ske.skill_name)
	se.set_target(actorId)

	DataManager.damage_sodiers(actorId, actorId, damage)

	var msg = "【{0}】余波\n受到{1}火焰伤害".format([
		ske.skill_name, damage
	])
	ske.play_se_animation(se, 2000, msg, 3)
	return

func on_view_model_2000():
	wait_for_skill_result_confirmation()
	return
