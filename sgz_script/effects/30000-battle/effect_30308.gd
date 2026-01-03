extends "effect_30000.gd"

#斧手小战场的锁定效果
#【斧手】白刃战，锁定技。战争开始时，你有 500 {斧手}。白刃战主将被攻击，进入单挑时，若你的 {斧手} 数量大于 0，你率 {斧手} 掩护主将撤出战斗，并与敌将开始白刃战。每日限1次。

const WAR_EFFECT_ID = 20688

func on_trigger_30003()->bool:
	if bf.source != ske.skill_name:
		return false
	var soldiers = ske.get_war_skill_val_int_array(WAR_EFFECT_ID)
	if soldiers.size() != 2 or soldiers[1] <= 0:
		return false
	bf.update_extra_formation_setting(
		actorId, ske.skill_name, "场合", {
			"兵种数量": {"步":5,"弓":0,"骑":0},
			"分配顺序": ["步"],
			"小战场标记ID": [30238],
			"禁用兵种转换": 1,
		}
	)
	var recover = bf.get_env_dict("战后兵力")
	recover[str(actorId)] = actor.get_soldiers()
	bf.set_env("战后兵力", recover)
	
	actor.set_soldiers(soldiers[1])
	return false

func on_trigger_30024()->bool:
	if bf.source != ske.skill_name:
		return false
	var unitId = DataManager.get_env_int("白兵.初始化单位ID")
	var bu = get_battle_unit(unitId)
	if bu == null or bu.Type != "步":
		return false
	bu.reset_combat_info("步(斧手)")
	return false

func on_trigger_30099() -> bool:
	if bf.source != ske.skill_name:
		return false
	# 战后更新斧手数量
	var remaining = int(ceil(bf.get_battle_sodiers(actorId, true, false)))
	ske.set_war_skill_val([2, remaining], 99999, WAR_EFFECT_ID)
	return false
