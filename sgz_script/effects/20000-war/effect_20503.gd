extends "effect_20000.gd"

#忍逆锁定技
#【忍逆】大战场，锁定技。回合初始，你的机动力额外恢复X点，X＝上回合你被对方攻击次数*8

func on_trigger_20013()->bool:
	var wf = DataManager.get_current_war_fight()
	var date = wf.date - 1
	if me.side() == "防守方":
		# 攻方先动，所以防守方受攻击在本日
		date = wf.date
	var defended = me.get_day_defended_actors(date).size()
	if defended <= 0:
		return false
	ske.change_actor_ap(actorId, defended * 8)
	ske.war_report()
	return false
