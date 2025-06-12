extends "effect_20000.gd"

#火裔效果
#【火裔】大战场,诱发技。受祖上火神庇佑，战争初始，你的[祝]标记+5，你被火类计策命中的场合，可以消耗1个[祝]标记发动：免疫本次火类计策伤害。

const EFFECT_ID = 20156
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const FLAG_NAME = "祝"
const FLAG_INIT_COUNT = 5

func on_trigger_20013()->bool:
	var dic = ske.get_war_skill_val_dic()
	if not dic.has("flagInit"):
		dic["flags"] = {FLAG_NAME: FLAG_INIT_COUNT}
		dic["flagInit"] = 1
		ske.set_war_skill_val(dic)
		ske.append_message("首次出战，获得{0}个[{1}]".format([
			FLAG_INIT_COUNT, FLAG_NAME,
		]))
		ske.war_report()
	return false


func on_trigger_20012():
	var se = DataManager.get_current_stratagem_execution()
	if se.targetId != self.actorId:
		return false
	if not se.damage_soldier():
		return false
	if se.get_nature() != "火":
		return false
	var damage = se.get_soldier_damage_for(self.actorId)
	if damage <= 0:
		return false
	var flags = SkillHelper.get_skill_flags_number(20000, EFFECT_ID, self.actorId, FLAG_NAME)
	if flags <= 0:
		return false
	return true

func effect_20156_AI_start():
	goto_step("2")
	return

func effect_20156_start():
	var se = DataManager.get_current_stratagem_execution()
	var flags = SkillHelper.get_skill_flags_number(20000, EFFECT_ID, self.actorId, FLAG_NAME)
	var msg = "发动【{0}】免疫{1}\n消耗一个[{2}]标记，可否？\n（现有：{3}".format([
		ske.skill_name, se.name, FLAG_NAME, flags
	])
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func on_view_model_2000()->void:
	wait_for_yesno(FLOW_BASE + "_2", false)
	return

func effect_20156_2():
	var se = DataManager.get_current_stratagem_execution()
	var damage = se.get_soldier_damage_for(me.actorId)
	var flags = SkillHelper.get_skill_flags_number(20000, EFFECT_ID, me.actorId, FLAG_NAME)
	if flags <= 0:
		LoadControl.end_script()
		return
	SkillHelper.set_skill_flags(20000, EFFECT_ID, me.actorId, FLAG_NAME, flags - 1)
	actor.set_soldiers(actor.get_soldiers() + damage)
	var skillInfo = "{0}发动【{1}】\n　免疫{2}".format([
		actor.get_name(), ske.skill_name, se.name, FLAG_NAME, flags - 1
	])
	se.skip_redo = 1
	# 此时 se 已经汇报过了，加 message 没用
	#se.append_result(ske.skill_name, skillInfo, damage, self.actorId)
	ske.append_message("免疫<r{0}>".format([se.name]))
	ske.war_report()
	FlowManager.add_flow("draw_actors")
	var msg = "火神庇佑，炎阳不侵！\n（{0}".format([skillInfo])
	me.attach_free_dialog(msg, 0)
	LoadControl.end_script()
	return
