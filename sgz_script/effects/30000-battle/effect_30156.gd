extends "effect_30000.gd"

#绝守锁定技 #战术值
#【绝守】小战场，锁定技。城类战中，若你为守方，初始时你可消耗X点机动力发动。发动后：每过1轮，对方战术值-1，若对方战术为0，强制结算为攻城失败（X为该技能累计发动次数）。

const EFFECT_ID = 30156
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2")
	return

func effect_30156_AI_start():
	goto_step("2")
	return

func effect_30156_start():
	var ap = ske.get_war_skill_val_int() + 1
	var msg = "消耗{0}机动力\n发动【{1}】\n可否？（当前机动：{2}".format([
		ap, ske.skill_name, me.action_point,
	])
	SceneManager.show_yn_dialog(msg, me.actorId)
	LoadControl.set_view_model(2000)
	return

func effect_30156_2():
	var ap = ske.get_war_skill_val_int() + 1
	ske.cost_ap(ap)
	ske.set_war_skill_val(ap)
	ske.set_battle_skill_val(1)
	ske.battle_report()

	var d = War_Character.DialogInfo.new()
	d.text = "静密专安，无隙无瑕\n心固则气固，兵固则城固\n（{0}发动【{1}】".format([
		me.get_name(), ske.skill_name,
	])
	d.actorId = me.actorId
	d.mood = 2
	d.sceneId = 30000
	me.add_dialog_info(d)
	LoadControl.end_script()
	return

func on_trigger_30005()->bool:
	if enemy == null or enemy.disabled:
		return false
	var ap = ske.get_war_skill_val_int() + 1
	return me.action_point >= ap

func on_trigger_30009()->bool:
	if enemy == null or enemy.disabled:
		return false
	if ske.get_battle_skill_val_int() != 1:
		return false
	ske.battle_change_tactic_point(-1, enemy)
	if enemy.battle_tactic_point > 0:
		return false

	var bu = enemy.battle_actor_unit()
	if bu == null:
		return false
	bu.unit_position.x = -5

	var d = War_Character.DialogInfo.new()
	d.text = "敌势已疲，此城坚如磐石！\n（{0}战术已尽，被迫撤退".format([
		enemy.get_name(),
	])
	d.actorId = me.actorId
	d.mood = 0
	d.sceneId = 30000
	me.add_dialog_info(d)

	return false
