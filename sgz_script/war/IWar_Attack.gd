extends Resource

# 获取可以被攻击的武将，若没有目标，返回错误类型
# @return [targets, reason]
func get_can_attack_actors(fromId:int, igonreAP:bool=false, evenForbidden:bool=false)->Array:

	var targets = []
	var reason = ""

	var fromWA = DataManager.get_war_actor(fromId)
	if fromWA.get_buff_label_turn(["禁止攻击"]) > 0 and not evenForbidden:
		reason = "已被禁止攻击"
		return [PoolIntArray(targets), reason]

	var srb = SkillRangeBuff.max_for_actor("攻击所需体力", fromId)
	if srb != null and fromWA.actor().get_hp() < srb.effectTagVal:
		reason = "因【{0}】效果\n体力不足，无法攻击".format([srb.skillName])
		return [PoolIntArray(targets), reason]

	DataManager.set_env("战争.攻击距离", fromWA.get_attack_distance())
	DataManager.set_env("战争.目标地形排除", [])
	DataManager.set_env("战争.攻击目标排除", {})
	DataManager.set_env("战争.额外攻击目标", [])
	SkillHelper.auto_trigger_skill(fromId, 20030, "")
	var max_distance = DataManager.get_env_int("战争.攻击距离")
	var except_blocks = DataManager.get_env_array("战争.目标地形排除")
	var excludedTargets = DataManager.get_env_dict("战争.攻击目标排除")
	var extra_targets = DataManager.get_env_array("战争.额外攻击目标")
	DataManager.unset_env("战争.攻击距离")
	DataManager.unset_env("战争.目标地形排除")
	DataManager.unset_env("战争.攻击目标排除")
	DataManager.unset_env("战争.额外攻击目标")
	targets.append_array(extra_targets)

	# 装备影响攻击距离，参考青铜铃等
	max_distance = max(max_distance, fromWA.actor().get_equip_feature_max("攻击距离"))

	var map = SceneManager.current_scene().war_map
	map.aStar.update_map_for_actor(fromWA)
	var wf = DataManager.get_current_war_fight()
	for wa in wf.get_war_actors(false, true):
		if wa.side() == fromWA.side():
			continue
		srb = SkillRangeBuff.max_for_actor("攻击所需体力", wa.actorId)
		if srb != null and fromWA.actor().get_hp() < srb.effectTagVal:
			reason = "因{0}【{1}】效果\n体力不足，无法攻击".format([wa.get_name(), srb.skillName])
			continue
		if not igonreAP:
			if get_attack_ap(fromId, wa.actorId) > fromWA.action_point:
				var dic = DataManager.get_env_dict("战争.攻击消耗")
				if "原因" in dic:
					reason = str(dic["原因"])
				if reason == "":
					# 只要有一个目标是因为机动力不足，就提示机动力不足
					reason = "机动力不足\n无法攻击"
				continue
		#攻击距离以十字为准
		var distance = Global.get_distance(wa.position, fromWA.position)
		if distance > max_distance:
			continue
		var blockCN = map.get_blockCN_by_position(wa.position)
		if blockCN in except_blocks:
			continue
		# 对于远距离攻击的情况，中间不能有城门和城墙
		if distance > 1:
			var route = map.aStar.get_attack_path(fromWA.position, wa.position)
			# 没路
			if route.empty():
				continue
			# 需要绕路，说明中间有城墙
			if route.size() > distance + 1:
				continue
		#根据坐标从左往右排序
		var index = 0;
		for i in targets.size():
			var o_actorId = targets[i];
			var o_war_actor = DataManager.get_war_actor(o_actorId);
			if(o_war_actor.position.x > wa.position.x):
				index = i;
				break;
			if(o_war_actor.position.x == wa.position.x):
				if(o_war_actor.position.y > wa.position.y):
					index = i;
					break;
		if wa.get_buff_label_turn(["潜行"]) > 0:
			if blockCN in ["山地", "树林"]:
				excludedTargets[wa.actorId] = "潜行"
		targets.insert(index, wa.actorId)

	if targets.size() == 1 and targets[0] in excludedTargets:
		# 只有一个目标且被排除，提示原因
		reason = "因【{0}】效果\n无法攻击{1}".format([
			excludedTargets[targets[0]], ActorHelper.actor(targets[0]).get_name(),
		])
	for targetId in excludedTargets.keys():
		targets.erase(targetId)

	if targets.empty() and reason == "":
		reason = "没有可攻击的目标"

	return [PoolIntArray(targets), reason]

#获取攻击指定目标所需机动力
func get_attack_ap(fromId:int,toId:int):
	DataManager.set_env("战争.攻击消耗", {
		"攻击来源":fromId,
		"攻击目标":toId,
		"初始":4,
		"减少":0,
		"增加":0,
		"至少":0,
		"至多":-1,
		"固定":-1,
	})

	SkillHelper.auto_trigger_skill(fromId, 20014, "")
	
	var dic = DataManager.get_env_dict("战争.攻击消耗")
	var ap = int(dic["初始"])#初始攻击力消耗
	ap -= int(dic["减少"])
	ap += int(dic["增加"])
	ap = max(ap, int(dic["至少"]))
	if dic["至多"] >= 0:
		ap = min(ap, int(dic["至多"]))
	if dic["固定"] >= 0:
		ap = int(dic["固定"])
	return ap
