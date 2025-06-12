extends "effect_20000.gd"

# 诈投锁定技
#【诈投】大战场，锁定技。敌方回合，自动免疫你前X次受到的攻击（X=前1回合你使用<过江>的次数）。

const ACTIVE_EFFECT_ID = 20592

func on_trigger_20015() -> bool:
	var bf = DataManager.get_current_battle_fight()
	if bf.targetId != actorId:
		return false
	return true

func effect_20593_AI_start() -> void:
	goto_step("start")
	return

func effect_20593_start() -> void:
	var times = ske.get_war_skill_val_int(ACTIVE_EFFECT_ID)
	if times <= 0:
		if ske.get_war_skill_val_int() > 0:
			ske.set_war_skill_val(0, 0)
			var msg = "巧言令色！\n但受死可也！"
			bf.get_attacker().attach_free_dialog(msg, 0)
		LoadControl.end_script()
		return

	# 表示本回合曾发动过
	ske.set_war_skill_val(1, 1)
	ske.set_war_skill_val(times - 1, 99999, ACTIVE_EFFECT_ID)
	bf.skip_execution(actorId, ske.skill_name)
	bf.war_report()

	var msg = "某特为输诚而来\n勿相攻击"
	me.attach_free_dialog(msg, 1)
	LoadControl.end_script()
	SkillHelper.remove_current_skill_trigger()

	map.cursor.hide()
	map.clear_can_choose_actors()
	var nextFlow = "AI_before_ready"
	if me.get_controlNo() < 0:
		nextFlow = "player_ready"
	FlowManager.add_flow(nextFlow)
	return
