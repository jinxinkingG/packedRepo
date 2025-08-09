extends "effect_20000.gd"

# 佯焚诱发技
#【佯焚】大战场，诱发技。你使用计策「火计」时，你可令此计策必定失败，若如此：该计策执行期间，每当对方存在可以发动的诱发技时，对方必须发动其中的一个。每回合限1次。

const EFFECT_ID = 20627
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20018() -> bool:
	var se = DataManager.get_current_stratagem_execution()
	return se.name == "火计"

func effect_20627_AI_start() -> void:
	goto_step("confirmed")
	return

func effect_20627_start() -> void:
	var msg = "佯作纵火，诱发敌军后招\n可否？"
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed", false)
	return

func effect_20627_confirmed() -> void:
	var se = DataManager.get_current_stratagem_execution()
	se.set_must_fail(actorId, ske.skill_name)
	se.set_env("强制诱发", 1)
	skill_end_clear()
	return
