extends "effect_30000.gd"

#朝凤锁定技 #武将强化
#【朝凤】小战场，锁定技。你武器为枪时，枪的穿刺伤害倍率从0.7提升至1.2，你击杀对方士兵单位时，可以额外行动一次。每轮额外行动次数上限为1次，且场上其他武将拥有<枪神>或<冲阵>时，次数上限改为2次。

const ENHANCEMENT = {
	"枪倍率": 1.2,
	"BUFF": 1,
}

const RELATED_SKILLS = [
	"枪神", "冲阵",
]

func get_times_limit()->int:
	# 简单处理，直接使用枪神触发标记，不再扫描技能，提速
	if DataManager.get_env_int("战争.童渊弟子") > 0:
		return 2
	return 1

func on_trigger_30023()->bool:
	var bu = get_leader_unit(me.actorId)
	if bu == null:
		return false

	var attackUnitId = get_env_int("白兵伤害.来源")
	if attackUnitId != bu.unitId:
		return false

	if not bu.dic_combat.has(ske.skill_name):
		return false
	var limit = int(bu.dic_combat[ske.skill_name])
	var triggered = ske.get_battle_skill_val_int()
	if triggered >= limit:
		return false

	var defendUnitId = get_env_int("白兵伤害.单位")
	var hurtId = get_env_int("白兵.受伤单位")
	if defendUnitId != hurtId:
		return false
	var hurt = get_battle_unit(hurtId)
	if hurt == null or hurt.leaderId == bu.leaderId:
		return false
	if not hurt.disabled:
		return false

	# 计数
	ske.set_battle_skill_val(triggered + 1, 1)
	bu.wait_action_times += 1
	bu.add_status_effect("朝凤#F0C000")
	return false

func on_trigger_30024()->bool:
	var bu = ske.battle_enhance_current_unit(ENHANCEMENT, ["将"], "枪")
	if bu == null:
		return false
	bu.dic_combat[ske.skill_name] = get_times_limit()
	return false
