extends "effect_30000.gd"

#斧手小战场的锁定效果，包括阵型和结束时退回所有保存的兵力
#【斧手】大战场，主动技。指定1名攻击范围内的敌将，消耗4点机动力发动。你对之发起攻击，以此法进入的白刃战，你固定为全步兵，但不计入实际兵力损失。每回合限一次。

const ACTIVE_EFFECT_ID = 20460

func on_trigger_30003()->bool:
	if ske.get_war_skill_val_int(ACTIVE_EFFECT_ID) <= 0:
		return false
	var formationKey = "白兵.阵型优先.{0}".format([actorId])
	if DataManager.get_env_int(formationKey) > 5:
		return false

	var setting = DataManager.get_env_dict("兵种数量")
	var sorting = DataManager.get_env_array("分配顺序")
	DataManager.set_env("兵种数量", {"步":10,"弓":0,"骑":0})
	DataManager.set_env("分配顺序", ["步"])
	DataManager.set_env(formationKey, 5)

	var recover = bf.get_env_dict("战后兵力")
	recover[str(actorId)] = actor.get_soldiers()
	bf.set_env("战后兵力", recover)

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

