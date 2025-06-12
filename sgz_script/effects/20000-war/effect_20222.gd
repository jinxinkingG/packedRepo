extends "effect_20000.gd"

#救主诱发技 #截击
#【救主】大战场,诱发技。你方主将小战场撤退时，你可以发动：对追击你方主将者，发起战斗宣言。

const EFFECT_ID = 20222
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func _init():
	FlowManager.bind_import_flow(FLOW_BASE + "_start", self)
	FlowManager.bind_import_flow(FLOW_BASE + "_AI_start", self)
	FlowManager.bind_import_flow(FLOW_BASE + "_2", self)
	FlowManager.bind_import_flow(FLOW_BASE + "_3", self)
	return

func _input_key(delta:float):
	match LoadControl.get_view_model():
		2000:
			wait_for_yesno(FLOW_BASE + "_2", false)
		2001:
			wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_20222_AI_start():
	FlowManager.add_flow(FLOW_BASE + "_2")
	return

func effect_20222_start():
	var ske = SkillHelper.read_skill_effectinfo()
	var bf = DataManager.get_current_battle_fight()
	var me = ske.get_war_actor()
	var leader = bf.get_loser()
	var target = leader.get_battle_enemy_war_actor()

	var msg = "{0}败退\n发动【{1}】，截击{2}\n可否？".format([
		leader.get_name(), ske.skill_name, target.get_name(),
	])
	play_dialog(me.actorId, msg, 2, 2000, true)
	var war_map = SceneManager.current_scene().war_map
	war_map.next_shrink_actors = [target.actorId, leader.actorId]
	return

func effect_20222_2():
	var ske = SkillHelper.read_skill_effectinfo()
	var bf = DataManager.get_current_battle_fight()
	var me = ske.get_war_actor()
	var leader = bf.get_loser()
	var target = leader.get_battle_enemy_war_actor()

	var msg = "{0}速退，{1}在此\n{2}休得张狂！".format([
		DataManager.get_actor_honored_title(leader.actorId, me.actorId),
		DataManager.get_actor_self_title(me.actorId),
		DataManager.get_actor_naughty_title(target.actorId, me.actorId),
	])
	play_dialog(me.actorId, msg, 0, 2001)
	var war_map = SceneManager.current_scene().war_map
	war_map.next_shrink_actors = [target.actorId, me.actorId]
	return

func effect_20222_3():
	var ske = SkillHelper.read_skill_effectinfo()
	var bf = DataManager.get_current_battle_fight()
	var me = ske.get_war_actor()
	var leader = bf.get_loser()
	var target = leader.get_battle_enemy_war_actor()
	start_battle_and_finish(me.actorId, target.actorId)
	return

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	var bf = DataManager.get_current_battle_fight()
	var me = ske.get_war_actor()
	if me == null or me.disabled:
		return false
	var loser = bf.get_loser()
	if loser == null or loser.disabled:
		return false
	if loser.actorId != ske.actorId:
		return false
	if ske.actorId == me.actorId:
		return false
	if loser.actorId != me.get_main_actor_id():
		return false
	var target = loser.get_battle_enemy_war_actor()
	if target == null or target.disabled:
		return false
	return true
