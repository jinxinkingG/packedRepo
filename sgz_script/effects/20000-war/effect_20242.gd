extends "effect_20000.gd"

#城击锁定技
#【城击】大战场，锁定技。你在城地形时，你可以消耗5点机动力，对距离2以内的非城地形敌人，发起攻击宣言。

const COST_AP = 5

func check_trigger_correct() -> bool:
	var ske = SkillHelper.read_skill_effectinfo()
	var me = ske.get_war_actor()
	if me == null or me.disabled:
		return false
	match ske.trigger_Id:
		20014: # 计算攻击消耗机动力
			var dic = get_env_dict("战争.攻击消耗")
			if dic.empty():
				return false
			var fromId = int(dic["攻击来源"])
			var targetId = int(dic["攻击目标"])
			if fromId != me.actorId:
				return false
			var targetWA = DataManager.get_war_actor(targetId)
			if targetWA == null or targetWA.disabled:
				return false
			var disv = targetWA.position - me.position
			if abs(disv.x) + abs(disv.y) == 2:
				dic["固定"] = COST_AP
				set_env("战争.攻击消耗", dic)
		20030:
			if not check_env(["战争.攻击距离", "战争.目标地形排除"]):
				return false
			var map = SceneManager.current_scene().war_map
			var blockCN = map.get_blockCN_by_position(me.position)
			if not blockCN in StaticManager.CITY_BLOCKS_CN:
				return false
			if me.action_point < COST_AP:
				return false
			set_env("战争.目标地形排除", StaticManager.CITY_BLOCKS_CN.duplicate())
			set_env("战争.攻击距离", 2)
	return false
