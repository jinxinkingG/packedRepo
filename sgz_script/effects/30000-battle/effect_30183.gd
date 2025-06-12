extends "effect_30000.gd"

#警叛诱发后的小战场效果 #士气 #战术值
#【警叛】大战场，诱发技。你方武将被笼络成功时，你可以发动：选择一个己方武将与背叛者进入白刃战，且己方武将的士气+10，战术值+10

const INDUCE_EFFECT_ID = 20326

func on_trigger_30005()->bool:
	var bf = DataManager.get_current_battle_fight()
	var fromId = ske.actorId
	if fromId != bf.get_attacker_id():
		return false
	var targetId = bf.get_defender_id()
	# 检查大战场发动标记
	if ske.get_war_skill_val_int(INDUCE_EFFECT_ID, fromId) <= 0:
		return false
	# 无条件清除标记
	ske.set_war_skill_val(0, 0, INDUCE_EFFECT_ID, fromId)
	# 赋予 buff
	var wa = DataManager.get_war_actor(fromId)
	ske.battle_change_morale(10, wa)
	ske.battle_change_tactic_point(10, wa)
	ske.battle_report()
	# 有【镇乱】的话，由【镇乱】发言
	if SkillHelper.actor_has_skills(fromId, ["镇乱"]):
		return false

	var d = War_Character.DialogInfo.new()
	d.text = "{0}反复无常！\n看{1}镇奸平乱！".format([
		DataManager.get_actor_naughty_title(targetId, fromId),
		DataManager.get_actor_self_title(fromId),
	])
	d.actorId = fromId
	d.mood = 0
	d.sceneId = 30000
	wa.add_dialog_info(d)
	return false
