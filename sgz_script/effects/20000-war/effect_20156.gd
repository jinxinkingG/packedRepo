extends "effect_20000.gd"

#火裔效果
#【火裔】大战场,诱发技。受祖上火神庇佑，你被火类计策命中的场合，可以消耗1个[祝]标记发动：免疫本次火类计策伤害。每击杀一个敌将，你的[祝]标记+5；每过一回合，你的[祝]标记+1。

const EFFECT_ID = 20156
const FLOW_BASE = "effect_" + str(EFFECT_ID)

# 区分ID是为了与技能变量兼容
const FLAG_ID = 20157
const FLAG_NAME = "祝"
const FLAG_DEFEAT_BONUS = 5
const FLAG_DAILY_BONUS = 1

func on_trigger_20013() -> bool:
	if ske.get_war_skill_val_int() <= 0:
		ske.clear_skill_flags(20000, FLAG_ID, FLAG_NAME)
		ske.set_war_skill_val(1)
	ske.add_skill_flags(20000, FLAG_ID, FLAG_NAME, FLAG_DAILY_BONUS)
	ske.append_message("获得{0}个[{1}]".format([
		FLAG_DAILY_BONUS, FLAG_NAME,
	]))
	ske.war_report()
	return false

func on_trigger_20020()->bool:
	var bf = DataManager.get_current_battle_fight()
	if not ske.actorId in [bf.get_attacker_id(), bf.get_defender_id()]:
		return false
	var loser = bf.get_loser()
	if loser == null or loser.actorId == ske.actorId:
		return false
	if not loser.disabled:
		return false
	ske.add_skill_flags(20000, FLAG_ID, FLAG_NAME, FLAG_DEFEAT_BONUS)
	ske.war_report()
	var msg = "此獠可祭火神！\n（触发【{0}】\n（获得{1}个[{2}]".format([
		ske.skill_name, FLAG_DEFEAT_BONUS, FLAG_NAME,
	])
	me.attach_free_dialog(msg, 0)
	return false

func on_trigger_20012():
	var se = DataManager.get_current_stratagem_execution()
	if se.targetId != actorId:
		return false
	if not se.damage_soldier():
		return false
	if se.get_nature() != "火":
		return false
	var damage = se.get_soldier_damage_for(actorId)
	if damage <= 0:
		return false
	var flags = ske.get_skill_flags(20000, FLAG_ID, FLAG_NAME)
	if flags <= 0:
		return false
	return true

func effect_20156_AI_start():
	goto_step("2")
	return

func effect_20156_start():
	var se = DataManager.get_current_stratagem_execution()
	var flags = ske.get_skill_flags(20000, FLAG_ID, FLAG_NAME)
	var msg = "发动【{0}】免疫{1}\n消耗一个[{2}]标记，可否？\n（现有：{3}".format([
		ske.skill_name, se.name, FLAG_NAME, flags
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000()->void:
	wait_for_yesno(FLOW_BASE + "_2", false)
	return

func effect_20156_2():
	var se = DataManager.get_current_stratagem_execution()
	var damage = se.get_soldier_damage_for(actorId)
	var flags = ske.get_skill_flags(20000, FLAG_ID, FLAG_NAME)
	if flags <= 0:
		LoadControl.end_script()
		return
	ske.cost_skill_flags(20000, FLAG_ID, FLAG_NAME, 1)
	ske.add_actor_soldiers(actorId, damage)
	var skillInfo = "{0}发动【{1}】\n　免疫{2}".format([
		actor.get_name(), ske.skill_name, se.name,
	])
	se.skip_redo = 1
	# 此时 se 已经汇报过了，加 message 没用
	#se.append_result(ske.skill_name, skillInfo, damage, self.actorId)
	ske.append_message("免疫<r{0}>".format([se.name]))
	ske.war_report()
	map.draw_actors()
	var msg = "火神庇佑，炎阳不侵！\n（{0}".format([skillInfo])
	me.attach_free_dialog(msg, 0)
	LoadControl.end_script()
	return
