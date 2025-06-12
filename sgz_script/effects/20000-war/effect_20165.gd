extends "effect_20000.gd"

#长歌效果
#【长歌】大战场,锁定技。你非主将时，每回合初始，你与你方主将机动力回复+x，x=2+战争天数/2，最大为6；

# 在战争第一天，先初始化的是部下，最后是主将
# 因此不能在自己初始化时统一处理，需要分别处理
func on_trigger_20013():
	var wf = DataManager.get_current_war_fight()
	var leaderId = me.get_main_actor_id()
	if me.actorId == leaderId:
		# 我是主将
		return false
	var x:int = min(6, 2 + int(wf.date / 2))
	if leaderId == ske.actorId:
		# 当前是主将
		ske.change_actor_ap(leaderId, x)
		ske.war_report()
	if me.actorId == ske.actorId:
		# 当前是我自己
		ske.change_actor_ap(me.actorId, x)
		ske.war_report()
	return false
