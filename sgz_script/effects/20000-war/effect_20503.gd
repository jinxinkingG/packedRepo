extends "effect_20000.gd"

#忍逆锁定技
#【忍逆】大战场，锁定技。上一日，你被对方攻击过，则本日初始：你的机动力额外恢复8点。☆制作组凤婶提醒，每日行动顺序为：守方援军→攻方→守方，行动顺序如果听不懂，可以去哔站看测试组“一只水羊羊”的相关视频。注意：如果你是守方，被攻击后，轮到你的时候，其实还是“本日”，此时无法触发机动力+8，得次日，轮到你的时候，才能触发机动力+8。本技能的特点就是：作为守方，触发有严重的滞后性，契合技能名称中的“忍”字。

func on_trigger_20013()->bool:
	var wf = DataManager.get_current_war_fight()
	var date = wf.date - 1
	if me.side() == "防守方":
		# 攻方先动，所以防守方受攻击在本日
		date = wf.date
	var defended = me.get_day_defended_actors(date).size()
	if defended <= 0:
		return false
	ske.change_actor_ap(actorId, 8)
	ske.war_report()
	return false
