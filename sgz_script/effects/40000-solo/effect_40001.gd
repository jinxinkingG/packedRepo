extends "effect_40000.gd"

#怒斩效果
#【怒斩】单挑,锁定技。单挑暴击率+20%。单挑击败敌将后，若你方武将人数少于对方，你的机动力+6，体力+15。

const BUFF_AP = 6
const HP_RECOVER = 15

func on_trigger_40005()->bool:
	var rate = DataManager.get_env_int("单挑.暴击率")
	DataManager.set_env("单挑.暴击率", rate + 20)
	return false

func on_trigger_40002()->bool:
	var enemy = me.get_battle_enemy_war_actor()
	if enemy == null:
		return false
	if not enemy.disabled:
		return false
	# 对手已亡
	var teammatesCount = me.get_teammates(false).size()
	var enemyCount = me.get_enemy_war_actors(false).size()
	if teammatesCount >= enemyCount:
		return false
	return true

func effect_40001_AI_start():
	goto_step("start")
	return

func effect_40001_start():
	ske.change_actor_ap(actorId, BUFF_AP)
	var recovered = ske.change_actor_hp(actorId, HP_RECOVER)
	ske.war_report()

	var enemy = me.get_battle_enemy_war_actor()
	var msg = "{0}击败{1}，触发【{2}】\n机动力回复 {3}"
	if recovered > 0:
		msg += "\n体力回复 {4}"
	msg = msg.format([
		me.get_name(), enemy.get_name(),
		ske.skill_name, BUFF_AP, recovered,
	])
	SceneManager.current_scene().update_actor_info()
	SceneManager.show_confirm_dialog(msg)
	LoadControl.set_view_model(2990)
	return
