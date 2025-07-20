extends "effect_30000.gd"

#束武效果实现
#【束武】小战场,主动技。使用后，视为使用一次“咒缚”，若命中，对方武-5。若对方武＜你，则必定命中。每次小战场限一次。

const EFFECT_ID = 30121
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const POWER_DEBUFF = 5

func effect_30121_start() -> void:
	ske.battle_cd(99999)
	if me.battle_power <= enemy.battle_power:
		if not Global.get_rate_result(50):
			var msg = "【{0}】失败".format([ske.skill_name])
			SceneManager.show_confirm_dialog(msg, actorId, 3)
			LoadControl.set_view_model(2000)
			return

	DataManager.set_env("结果", 1)
	ske.battle_change_power(-POWER_DEBUFF, enemy)
	ske.battle_report()
	FlowManager.add_flow("tactic_impact_0")
	var msg = "{0}哪里走！\n（【{1}】效果，{2}武力 -{3}".format([
		DataManager.get_actor_naughty_title(enemy.actorId, actorId),
		ske.skill_name, enemy.get_name(), POWER_DEBUFF,
	])
	me.attach_free_dialog(msg, 0, 30000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_end", false)
	return

func effect_30121_end() -> void:
	tactic_end()
	return
