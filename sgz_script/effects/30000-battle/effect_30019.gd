extends "effect_30000.gd"

#厚积效果实现
#你从白兵战中获得的经验值翻倍

#厚积只需要加上经验加成buff，经验具体计算由伤害结算函数负责
func check_trigger_correct():
	var ske = SkillHelper.read_skill_effectinfo()
	var me = DataManager.get_war_actor(ske.skill_actorId)
	if me == null:
		return false
	me.set_buff("小战场经验加成", 99999, me.actorId, ske.skill_name, true)
	return false
