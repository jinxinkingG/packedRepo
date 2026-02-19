extends "effect_20000.gd"

#豆兵效果
#【豆兵】大战场，锁定技。你方回合结束阶段，记录你的兵力为Y，然后你的兵力增加X，X=在场你以外的武将人数*100，至多增至2500。你方回合开始时，若你的兵力大于Y，则兵力降为Y。

func on_trigger_20016()->bool:
	var wf = DataManager.get_current_war_fight()
	var soldiers = wf.get_war_actors(false, true).size() * 100 - 100
	if soldiers <= 0:
		return false
	soldiers = ske.add_war_tmp_soldier(actorId, soldiers, 2500)
	if soldiers <= 0:
		return false

	ske.war_report()

	var msg = "太玄在上，如律令敕！\n（【{0}】增加临时兵力 {1}".format([
		ske.skill_name, soldiers
	])
	map.draw_actors()
	me.attach_free_dialog(msg, 0)
	return false

func on_trigger_20013()->bool:
	var lost = actor.remove_tmp_soldiers()
	if lost <= 0:
		return false
	
	var msg = "失去临时兵力 {0}".format([abs(lost)])
	#me.attach_free_dialog(msg, 2)
	map.draw_actors()
	ske.append_message(msg)
	ske.war_report()
	return false
