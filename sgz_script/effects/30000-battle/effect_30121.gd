extends "effect_30000.gd"

#束武效果实现
#【束武】小战场,主动技。使用后，视为使用一次“咒缚”，若命中，对方武-5。若对方武＜你，则必定命中。每次小战场限一次。

func effect_30121_start():
	ske.battle_cd(99999)
	var succeeded = true
	if me.battle_power <= enemy.battle_power:
		if not Global.get_rate_result(50):
			succeeded = false
	if succeeded:
		DataManager.set_env("结果", 1)
		var original = enemy.calculate_battle_morale(enemy.battle_power, enemy.battle_lead, 0)
		ske.battle_change_power(-5, enemy)
		var changed = enemy.calculate_battle_morale(enemy.battle_power, enemy.battle_lead, 0)
		ske.battle_change_morale(changed - original, enemy)
		ske.battle_report()
		FlowManager.add_flow("tactic_impact_0")
	else:
		SceneManager.show_confirm_dialog("【束武】失败", actorId, 3)
		LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation("tactic_end", false)
	return
