extends "effect_30000.gd"

#连弩锁定效果部分，如果连弩buff失效，重新初始化单位
#【连弩】小战场,主动技。使用后：你的全体士兵立即装备连弩，每日限1次。注：连弩：远近伤害倍率均为0.6，默认1~3格射程，火矢不生效，一回合射击3次，持续3回合。

const LIANNU_EFFECT_ID = 30109

func check_trigger_correct():
	var skv = SkillHelper.get_skill_variable(30000, LIANNU_EFFECT_ID, self.actorId)
	if skv["turn"] < 0 or skv["value"] == null:
		return false
	var me = DataManager.get_war_actor(self.actorId)
	if me == null or me.disabled:
		return false
	if me.get_buff_label_turn(["连弩"]) > 0:
		return false
	# 连弩已失效，重置单位
	SkillHelper.set_skill_variable(30000, LIANNU_EFFECT_ID, self.actorId, 0, 0)
	for bu in DataManager.battle_units:
		if bu == null or bu.disabled or bu.leaderId != self.actorId:
			continue
		if bu.get_unit_type() == "将":
			continue
		bu.init_combat_info()
		bu.wait_action_times = bu.get_action_times()
	return false
