extends "effect_20000.gd"

#离魂被动触发判断
#【离魂】大战场,限定技。指定1名男性武将为目标，消耗你10点机动力发动。你与目标同时定止8~10回合。若你或目标其中一个离开战场，留下的另一人解除定止状态。

const EFFECT_ID = 20177

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	var skv = SkillHelper.get_skill_variable(20000, EFFECT_ID, self.actorId)
	if skv["turn"] <= 0 or skv["value"] == null:
		return false
	var targetId = int(skv["value"])
	if ske.actorId == self.actorId:
		# 自身离开战场
		pass
	elif targetId == ske.actorId:
		# 离魂目标离开战场
		pass
	else:
		return false
	var targetWA = DataManager.get_war_actor(targetId)
	if targetWA != null and targetWA.get_buff("定止")["回合数"] > 0:
		targetWA.dic_buffs.erase("定止")
		var d = War_Character.DialogInfo.new()
		d.text = "{0} ……".format([DataManager.get_actor_honored_title(self.actorId, targetId)])
		d.mood = 3
		d.actorId = targetId
		targetWA.add_dialog_info(d)
	var me = DataManager.get_war_actor(self.actorId)
	if me != null and me.get_buff("定止")["回合数"] > 0:
		me.dic_buffs.erase("定止")
	FlowManager.add_flow("draw_actors")
	SkillHelper.set_skill_variable(20000, EFFECT_ID, self.actorId, 0, 99999)
	return false
