extends "effect_40000.gd"

#龙爪效果
#【龙爪】单挑，锁定技。①你单挑击败对手后，可以无视装备类型，抢夺对方比你高级的S级装备。②你在单挑中击杀/俘虏对方武将后，本次战争结束前，你获得<回矢>。

const BUFF_SKILL = "回矢"

func on_trigger_40002() -> bool:
	var enemy = me.get_battle_enemy_war_actor()
	if enemy == null:
		return false
	if not enemy.disabled:
		return false
	# 对手已亡
	ske.cost_war_cd(99999)
	ske.add_war_skill(actorId, BUFF_SKILL, 99999)
	ske.war_report()
	return true

func effect_40007_AI_start() -> void:
	goto_step("start")
	return

func effect_40007_start() -> void:
	var enemy = me.get_battle_enemy_war_actor()
	var msg = "{0}击败{1}\n解锁【{2}】".format([
		me.get_name(), enemy.get_name(), BUFF_SKILL,
	])
	SceneManager.show_confirm_dialog(msg)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation("")
	return
