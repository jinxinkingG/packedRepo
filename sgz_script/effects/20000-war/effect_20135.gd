extends "effect_20000.gd"

#破势效果
#【破势】大战场,锁定技。你白兵获胜时，可以无视条件和冷却发动1次<骁勇>。

const XIAOYONG_EFFECT_ID = 20013

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	var bf = DataManager.get_current_battle_fight()
	var me = ske.get_war_actor()
	if me == null or me.disabled:
		return false

	var targetId = -1
	if me.actorId == bf.get_attacker_id():
		targetId = bf.get_defender_id()
	elif me.actorId == bf.get_defender_id():
		targetId = bf.get_attacker_id()
	else:
		return false

	var loser = bf.get_loser()
	if loser == null or loser.actorId != targetId:
		return false
	# 尝试触发骁勇
	if not SkillHelper.actor_has_skills(actorId, ["骁勇"]):
		return false
	if me.get_controlNo() < 0: # AI 不发动
		return false
	var dic = {
		"current_actor": me.actorId,
		"effect_id": XIAOYONG_EFFECT_ID,
		"triggerId": -1,
		"skill_name": "骁勇",
		"skill_actor": me.actorId,
	}
	var st = SkillTriggerInfo.new()
	st.induce_dialog = ""
	st.actorId = me.actorId
	st.triggerId = -1
	st.lock_effects = [dic]
	st.induce_effects = []
	# 特殊的 next_flow，以便骁勇判断流程
	st.next_flow = "FORCED_CALL"
	SkillHelper.add_skill_triggerinfo(st)
	return false
