extends "effect_30000.gd"

#功著小战场效果实现
#【功著】大战场，锁定技。你<牵制>发动过的场合，直到当日结束前，你的战斗/用计经验获取将翻倍。

# 与大战场 buff 同步，只要存在大战场经验 buff，就附加小战场经验 buff
# TODO 潜在问题，目前 buff 没有来源技能，只有来源武将
# 未来如果大战场 buff 有其他来源，需要注意判断
func check_trigger_correct():
	var ske = SkillHelper.read_skill_effectinfo()
	var me = DataManager.get_war_actor(ske.skill_actorId)
	if me == null:
		return false
	var warBuff = me.get_buff("大战场经验加成")
	if warBuff["回合数"] <= 0 or warBuff["来源武将"] != ske.skill_actorId:
		return false
	me.set_buff("小战场经验加成", 99999, me.actorId, ske.skill_name, true)
	return false
