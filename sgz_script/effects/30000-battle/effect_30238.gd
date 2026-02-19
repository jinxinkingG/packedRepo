extends "effect_30000.gd"

#斧手小战场的锁定效果
#【斧手】小战场，锁定技。战争开始时，你有 500 {斧手}。白刃战主将被攻击，进入单挑时，若你的 {斧手} 数量大于 0，你率 {斧手} 掩护主将撤出战斗，并与敌将开始白刃战。每日限1次。\n现有斧手：<var:1:0>。

const ACTIVE_EFFECT_ID = 20460

func on_trigger_30003()->bool:
	if ske.get_war_skill_val_int(ACTIVE_EFFECT_ID) <= 0:
		return false
	ske.set_war_skill_val(0, 0, ACTIVE_EFFECT_ID)
	bf.update_extra_formation_setting(
		actorId, ske.skill_name, "场合", {
			"兵种数量": {"步":10,"弓":0,"骑":0},
			"分配顺序": ["步"],
			"小战场标记ID": [30238],
			"布阵锁定兵种": 1,
		}
	)
	var recover = bf.get_env_dict("战后兵力")
	recover[str(actorId)] = actor.get_soldiers()
	bf.set_env("战后兵力", recover)
	return false

func on_trigger_30024()->bool:
	if ske.get_battle_skill_val_int() <= 0:
		return false
	var unitId = DataManager.get_env_int("白兵.初始化单位ID")
	var bu = get_battle_unit(unitId)
	if bu == null or bu.Type != "步":
		return false
	# 强制转化，绕过兵种锁定
	bu.formation_init("步(斧手)", true)
	return false
