extends "effect_20000.gd"

#换帻诱发技 #替代防御
#【换帻】大战场，诱发技。你方主将被攻击的场合，你可替代之进行防御；若主将不在太守府，开战前，你与其交换位置。每个回合限1次。

const EFFECT_ID = 20153
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const SUIT_ID = 12

func on_trigger_20015() -> bool:
	var bf = DataManager.get_current_battle_fight()
	if ske.actorId != bf.get_defender_id():
		# 不是防守方，跳过
		return false
	if ske.actorId != me.get_main_actor_id():
		# 不是主将，跳过
		return false
	if ske.actorId == me.actorId:
		# 自己没必要触发
		return false
	return true

func effect_20153_AI_start():
	var bf = DataManager.get_current_battle_fight()
	if me.get_soldiers() <= bf.get_defender().get_soldiers() \
		and me.get_soldiers() < 1500:
		LoadControl.end_script()
		return
	goto_step("confirmed")
	return

func effect_20153_start():
	var bf = DataManager.get_current_battle_fight()
	var leader = bf.get_defender()

	map.cursor.hide()
	var msg = "发动【{0}】\n替代{1}进入白兵\n可否？"
	var blockCN = map.get_blockCN_by_position(leader.position)
	if blockCN != "太守府":
		msg = "发动【{0}】\n替代{1}进入白兵\n并交换位置，可否？"
	msg = msg.format([ske.skill_name, leader.get_name()])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed", false)
	return

func effect_20153_confirmed():
	var bf = DataManager.get_current_battle_fight()
	var leader = bf.get_defender()

	ske.cost_war_cd(1)
	var blockCN = map.get_blockCN_by_position(leader.position)
	if blockCN != "太守府":
		ske.swap_war_actor_positions(me.actorId, leader.actorId)
	ske.replace_battle_defender(leader.actorId)
	ske.war_report()

	var msg = "{0}且退，{1}当之！\n（{2}替代防御".format([
		DataManager.get_actor_honored_title(leader.actorId, me.actorId),
		DataManager.get_actor_self_title(me.actorId), me.get_name(),
	])
	if ske.actorId == StaticManager.ACTOR_ID_SUNJIAN:
		# 对孙坚发动
		if ske.affair_get_skill_val_int() <= 0:
			# 未换装过
			var current = actor.get_suit()
			if current.id != SUIT_ID:
				# 目前装备不是赤帻
				ske.affair_set_skill_val(1)
				var vs = clVState.vstate(me.vstateId)
				vs.add_stored_equipment(current)
				actor.set_equip(clEquip.equip(SUIT_ID, current.type))
				msg += "\n（换装「{0}」，{1}入库".format([
					actor.get_suit().name(), current.name(),
				])

	play_dialog(actorId, msg, 0, 2990)
	return
