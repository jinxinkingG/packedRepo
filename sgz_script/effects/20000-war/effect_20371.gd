extends "effect_20000.gd"

#遵威诱发技
#【遵威】大战场，主将诱发技。你的队友白刃战败时，若其未被击杀/俘虏/投降，你获得其所有机动力。

const EFFECT_ID = 20371
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20020()->bool:
	var bf = DataManager.get_current_battle_fight()
	if bf.loserId != ske.actorId:
		return false
	if bf.loserId == me.actorId:
		return false
	var wa = bf.get_loser()
	if wa == null or wa.disabled:
		return false
	if wa.action_point <= 0:
		return false
	return true

func on_view_model_2000()->void:
	wait_for_yesno(FLOW_BASE + "_2", false)
	return

func on_view_model_2001()->void:
	wait_for_skill_result_confirmation("")
	return

func effect_20371_AI_start():
	goto_step("2")
	return

func effect_20371_start():
	var bf = DataManager.get_current_battle_fight()
	var wa = bf.get_loser()
	var msg = "夺取{0}全部机动力\n可否？".format([
		wa.get_name(),
	])
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func effect_20371_2():
	var bf = DataManager.get_current_battle_fight()
	var wa = bf.get_loser()
	var ap = ske.change_actor_ap(wa.actorId, -wa.action_point)
	ap = ske.change_actor_ap(me.actorId, -ap)
	ske.war_report()
	var msg = "此败{0}罪责难逃\n退下！看我破敌\n（夺取{0}{1}机动力".format([
		wa.get_name(), ap,
	])
	play_dialog(me.actorId, msg, 0, 2001)
	return
