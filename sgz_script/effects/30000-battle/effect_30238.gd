extends "effect_30000.gd"

#斧手小战场的锁定效果，包括阵型和结束时退回所有保存的兵力
#【斧手】大战场，主动技。指定1名攻击范围内的敌将，消耗4点机动力发动。你对之发起攻击，以此法进入的白刃战，你固定为全步兵，但不计入实际兵力损失。每回合限一次。

const ACTIVE_EFFECT_ID = 20460

func on_trigger_30004()->bool:
	# 先恢复默认值
	me.dic_other_variable.erase("撤退损兵率")
	#获取发动标记
	if ske.get_war_skill_val_int(ACTIVE_EFFECT_ID) <= 0:
		return false
	ske.set_war_skill_val(0, 0, ACTIVE_EFFECT_ID)
	#获得发动前的兵力
	var soldiers = ske.get_battle_skill_val_int()
	actor.set_soldiers(soldiers)
	# 暂不判断，默认为进攻
	bf.attackerSoldiers = soldiers
	bf.attackerRemaining = soldiers
	return false

func on_trigger_30003()->bool:
	if ske.get_war_skill_val_int(ACTIVE_EFFECT_ID) <= 0:
		return false
	var formationKey = "白兵.阵型优先.{0}".format([actorId])
	if DataManager.get_env_int(formationKey) > 5:
		return false

	ske.set_battle_skill_val(actor.get_soldiers())

	var setting = DataManager.get_env_dict("兵种数量")
	var sorting = DataManager.get_env_array("分配顺序")
	DataManager.set_env("兵种数量", {"步":10,"弓":0,"骑":0})
	DataManager.set_env("分配顺序", ["步"])
	DataManager.set_env(formationKey, 5)

	# 修正白兵战数据
	me.dic_other_variable["撤退损兵率"] = 0.0

	return false

func on_trigger_30024()->bool:
	if ske.get_war_skill_val_int(ACTIVE_EFFECT_ID) <= 0:
		return false
	var unitId = get_env_int("白兵.初始化单位ID")
	var bu = get_battle_unit(unitId)
	if bu == null or bu.Type != "步":
		return false
	bu.reset_combat_info("步(斧手)")
	return false

