extends "effect_20000.gd"

#计袭诱发技
#【计袭】大战场,诱发技。你使用伤兵类计策命中的场合，你可以发动：你方武力最高的将领与该受计者进入白刃战，且在此次白刃战中，那名敌将技能失效。每个回合限1次。。

const EFFECT_ID = 20141
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const ACTIVE_EFFECT_ID = 20420
const KEY_SKILL_ACTOR = "技能.计袭.武将"

func on_trigger_20012()->bool:
	# 托管模式下不发动
	if me.war_vstate().delegated:
		return false
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(actorId) != actorId:
		return false
	if not se.damage_soldier():
		return false
	if se.succeeded <= 0:
		return false
	if se.targetId < 0:
		return false
	var targetWA = DataManager.get_war_actor(se.targetId)
	if targetWA == null or targetWA.disabled:
		return false
	if not me.is_enemy(targetWA):
		return false
	var selected = ske.get_war_skill_val_int(ACTIVE_EFFECT_ID, -1, -1)
	if selected >= 0:
		var wa = DataManager.get_war_actor(selected)
		if wa == null or wa.disabled or not me.is_teammate(wa):
			selected = -1
	if selected < 0:
		var targets = get_teammate_targets(me, 999)
		var maxPower = -1
		for targetId in targets:
			var power = ActorHelper.actor(targetId).get_power()
			if power > maxPower:
				maxPower = power
				selected = targetId
	if selected < 0:
		return false
	DataManager.set_env(KEY_SKILL_ACTOR, selected)
	return true

func effect_20141_AI_start():
	var selected = DataManager.get_env_int(KEY_SKILL_ACTOR)
	var se = DataManager.get_current_stratagem_execution()
	var targetId = se.targetId
	var wa = DataManager.get_war_actor(selected)
	var enemy = DataManager.get_war_actor(se.targetId)
	if wa == null or wa.disabled:
		skill_end_clear()
		return
	if enemy == null or enemy.disabled:
		skill_end_clear()
		return
	wa.battle_init(true)
	enemy.battle_init(true)
	if wa.battle_morale * wa.get_soldiers() < enemy.battle_morale * enemy.get_soldiers() * 3:
		skill_end_clear()
		return
	goto_step("start")
	return

func effect_20141_start():
	var selected = DataManager.get_env_int(KEY_SKILL_ACTOR)
	var se = DataManager.get_current_stratagem_execution()
	var msg = "{0}今中吾计矣\n{1}可趁势掩杀！\n（{2}发动【{3}】".format([
		DataManager.get_actor_naughty_title(se.targetId, me.actorId),
		DataManager.get_actor_honored_title(selected, me.actorId),
		me.get_name(), ske.skill_name,
	])
	if me.get_controlNo() < 0:
		play_dialog(actorId, msg, 0, 2000)
	else:
		play_dialog(actorId, msg, 0, 3000, true)
		SceneManager.actor_dialog.lsc.cursor_index = 1
	return

func on_view_model_2000():
	Global.wait_for_confirmation(FLOW_BASE + "_2")
	return

func on_view_model_3000():
	wait_for_yesno(FLOW_BASE + "_2", false)
	return

func effect_20141_2():
	var selected = DataManager.get_env_int(KEY_SKILL_ACTOR)
	# SE-TODO
	# 暂时手动处理日志和 flow，未来通过 BattleExecution 解决
	var se = DataManager.get_current_stratagem_execution()
	se.report()
	var wa = DataManager.get_war_actor(se.targetId)
	ske.set_war_skill_val(selected)
	ske.cost_war_cd(1)
	ske.set_war_buff(wa.actorId, "沉默", 1)
	start_battle_and_finish(selected, se.targetId, ske.skill_name, actorId)
	return
