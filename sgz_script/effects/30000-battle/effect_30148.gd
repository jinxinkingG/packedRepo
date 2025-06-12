extends "effect_30000.gd"

#巧缚效果
#【巧缚】小战场,锁定技。你使用咒缚，若成功，你获得2回合士气向上。若失败，你的战术值+1。

const EFFECT_ID = 30148
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_30008()->bool:
	if DataManager.get_env_str("值") != "咒缚":
		return false
	return true

func effect_30148_AI_start():
	goto_step("start")
	return

func effect_30148_start():
	var msg = "咒止失败，【巧缚】发动\n战术值 +1"
	if DataManager.get_env_int("结果") > 0:
		msg = "{0}被咒止\n【巧缚】发动\n获得两回合士气向上".format([
			ActorHelper.actor(enemy.actorId).get_name()
		])
		ske.set_battle_buff(actorId, "士气向上", 2)
		ske.set_battle_buff(actorId, "咒缚", 3)
	else:
		ske.battle_change_tactic_point(1, me)
	ske.battle_report()
	SceneManager.show_confirm_dialog(msg, actorId, 2)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_end", false)
	return

func effect_30148_end():
	skill_end_clear(true)
	tactic_end()
	return
