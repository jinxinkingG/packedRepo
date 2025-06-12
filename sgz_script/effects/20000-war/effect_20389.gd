extends "effect_20000.gd"

#挺援诱发技 #替代防御
#【挺援】大战场，诱发技。你方其他武将被攻击时，你可以消耗所有机动力（至少5点），代替你方武将进入白刃战。若消耗的机动力至少10点，你在本次白刃战中，临时获得<奋威>。若你本次白刃战失败，与你交战的对方武将机动力变为0。（包括退回大战场，被杀，被俘虏）

const EFFECT_ID = 20389
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const MIN_AP = 5

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2", false)
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation("")
	return

func on_trigger_20015()->bool:
	var bf = DataManager.get_current_battle_fight()
	if ske.actorId != bf.get_defender_id():
		# 不是防守方，跳过
		return false
	if ske.actorId == me.actorId:
		# 自己没必要触发
		return false
	# 机动力不足，无法发动
	if me.action_point < MIN_AP:
		return false
	return true

func on_trigger_20020()->bool:
	if ske.get_war_skill_val_int() <= 0:
		# 未发动技能，忽略
		return false
	# 无条件清除标记
	ske.set_war_skill_val(0, 0)
	ske.remove_war_skill(me.actorId, "奋威")
	var bf = DataManager.get_current_battle_fight()
	if me.actorId != bf.get_defender_id():
		# 不是防守方，忽略
		return false
	var loser = bf.get_loser()
	if loser == null or loser.actorId != me.actorId:
		# 不是我失败，忽略
		return false
	var attacker = bf.get_attacker()
	if attacker == null:
		return false
	ske.clear_actor_ap(bf.get_attacker_id())
	ske.war_report()
	return false

func effect_20389_AI_start():
	var bf = DataManager.get_current_battle_fight()
	if me.get_soldiers() <= bf.get_defender().get_soldiers() \
		and me.get_soldiers() < 1500:
		LoadControl.end_script()
		return
	goto_step("2")
	return

func effect_20389_start():
	var bf = DataManager.get_current_battle_fight()
	map.cursor.hide()
	var msg = "消耗全部机动力\n发动【{0}】，替代{1}迎击{2}。可否？".format([
		ske.skill_name, ActorHelper.actor(ske.actorId).get_name(),
		bf.get_attacker().get_name(),
	])
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func effect_20389_2():
	var bf = DataManager.get_current_battle_fight()
	ske.set_war_skill_val(1, 1)
	if me.action_point >= 10:
		ske.add_war_skill(me.actorId, "奋威", 1)
	ske.cost_ap(me.action_point)
	ske.replace_battle_defender(ske.actorId)
	ske.war_report()

	var msg = "{0}张狂，某当死战！\n({1}代替被攻击)".format([
		DataManager.get_actor_naughty_title(bf.get_attacker_id(), me.actorId),
		me.get_name(),
	])
	play_dialog(me.actorId, msg, 0, 2001)
	return
