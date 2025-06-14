extends Resource

#AI用计
func _init() -> void:
	return

# 对何人使用什么计策
# @return 返回字典{目标:int,计策名:String,评分:float}
func best_use_strategy(fromId:int, excludedActorIds:PoolIntArray=[], schemeHistory:Dictionary={}, rateLimit:int=10)->Dictionary:
	var ret = {"目标":-1,"计策名":"","命中率":0,"评分":0}
	var from = DataManager.get_war_actor(fromId)
	if from == null or from.disabled:
		return ret

	# 缓存无言检查的结果
	var silenced = -1
	for scheme in from.get_stratagems():
		if scheme.is_area_targeting():
			#选择区域的跳过
			continue
		if scheme.may_damage_soldier():
			# @since 1.58x
			# AI 无言的效果在这里实现
			# 以避免 20006 回调，实现加速
			if silenced == -1:
				silenced = 0
				if SkillHelper.actor_has_skills(fromId, ["无言"], false):
					silenced = 1
			if silenced == 1:
				continue
		DataManager.grouped_trace("")
		var targets = scheme.get_available_targets(fromId, excludedActorIds)[0]
		DataManager.grouped_trace("TARGET")
		if targets.empty():
			# 当前没有可释放的目标，跳过
			continue
		for targetId in targets:
			if targetId in excludedActorIds:
				continue
			var res = _get_score_of_strategy_to(scheme, fromId, targetId, schemeHistory, rateLimit)
			var score = float(res[0])
			var rate = int(res[1])
			if score > ret["评分"]:
				ret["目标"] = targetId
				ret["计策名"] = scheme.name
				ret["命中率"] = rate
				ret["评分"] = score
	return ret

#获取武将对目标用指定计策的评分
#同时返回命中率和评分
#@return <score, rate>
func _get_score_of_strategy_to(scheme:StratagemInfo, fromId:int, targetId:int, schemeHistory:Dictionary, rateLimit:int)->Array:
	if DataManager.diffculities >= 4:
		for history in schemeHistory.values():
			for se in history:
				if not se is StratagemExecution:
					continue
				if se.name != scheme.name:
					continue
				if se.targetId != targetId:
					continue
				if se.succeeded <= 0:
					continue
				if scheme.may_damage_soldier() and se.get_soldier_damage_for(se.targetId) == 0:
					if se.skill == "攻心":
						continue
					# 计策成功但未造成伤害的情况
					_notice_for_exceptional(scheme, fromId, targetId)
					return [0.0, 0]
				if scheme.name in ["虚兵", "连环"]:
					var target = DataManager.get_war_actor(targetId)
					if target.get_buff("定止")["回合数"] <= 0:
						# 不知道什么原因没定住或者解开了，算了
						_notice_for_exceptional(scheme, fromId, targetId)
						return [0.0, 0]


	var actor = ActorHelper.actor(fromId)
	var rate = scheme.get_rate(fromId, targetId)
	if rate <= rateLimit:
		#命中率低于最低门槛0，直接0分
		return [0.0, rate]
	var cost = scheme.get_cost_ap(fromId)
	var fromWA = DataManager.get_war_actor(fromId);
	var fromWV = fromWA.war_vstate()
	var targetWA = DataManager.get_war_actor(targetId);
	var targetWV = targetWA.war_vstate()
	var distance = Global.get_range_distance(fromWA.position, targetWA.position)
	var related = scheme.get_all_related_targets(fromWA, targetWA)
	#装备附加智力值
	var addedInt = actor.get_equip_feature_total("计策附加智力")
	
	var score = 0
	for key in scheme.impact:
		var formula = scheme.impact[key]
		match key:
			"rice":
				if targetWV.rice < 120:
					formula = formula.replace("b.米",str(targetWV.rice));
					formula = formula.replace("a.米",str(fromWV.rice));
					var damage = int(Global.count_formula_number(formula, fromId, targetId, {"知": addedInt}));
					damage = min(targetWV.rice, damage);
					score += abs(damage)/2;#评分增加烧米量
			"hp":
				for id in related:
					var damage = int(Global.count_formula_number(formula, fromId, id, {"知": addedInt}));
					damage = min(ActorHelper.actor(id).get_hp(), damage)
					score += abs(damage)
			"soldier":
				for id in related:
					var damage = int(Global.count_formula_number(formula, fromId, id, {"知": addedInt}));
					damage = min(ActorHelper.actor(id).get_soldiers(), damage)
					score += abs(damage)
			"buff":
				var setting = Dictionary(formula)
				var buff = str(setting["name"])
				var turns = 0
				if "round" in setting:
					turns = int(setting["round"])
				if turns <= 0:
					if "formula" in setting:
						turns = int(Global.count_formula_number(setting["formula"], fromWA.actorId, targetId, {"知":addedInt}))
				if turns > 0:
					var buffInfo = StaticManager.get_buff(buff)
					var label = buffInfo.get_label()
					if "乱石阵" in label:
						for id in related:
							var wa = DataManager.get_war_actor(id)
							if wa.get_buff(buff)["回合数"] == 0:
								#八阵期望评分=120*八阵回合数
								score += min(ActorHelper.actor(id).get_soldiers(), abs(turns * 120))
					elif "禁止移动" in label:
						for id in related:
							var wa = DataManager.get_war_actor(id)
							if wa.get_buff(buff)["回合数"] == 0:
								#定止评分=定止回合数 * 士兵数/100 * 随机系数
								score += abs(turns) * ActorHelper.actor(id).get_soldiers() * Global.get_random(50,100)/100.0;
								# 太远的虚兵没有必要
								if distance > 10:
									score = 0
								# 兵力太少的也没必要
								if targetWA.get_soldiers() < 1000:
									score = 0
			"specialEffect":
				if formula == "笼络":
					for id in related:
						score += Global.get_random(500, 2000)
		
	# 分数 = 效果数值*命中率%/所需的机动力
	score = score * rate/100.0 / cost
	# 兵力加成
	if targetWA.get_soldiers() < 1000:
		score /= 2
	# 距离加成
	if distance <= 3:
		score *= 1.5
	if distance >= 6:
		score /= 2
	return [score, rate]

# 发现无效计策后发出提示
func _notice_for_exceptional(scheme:StratagemInfo, fromId:int, targetId:int)->void:
	var review = DataManager.get_env_dict("战争.DAILY.计策复盘")
	var key = "{0}|{1}".format([targetId, scheme.name])
	if key in review:
		return
	review[key] = 1
	DataManager.set_env("战争.DAILY.计策复盘", review)
	var wa = DataManager.get_war_actor(fromId)
	var reporter = wa.get_leader()
	if reporter == null:
		reporter = wa
	var msg = "{0}似乎对{1}毫无作用...".format([
		scheme.name, ActorHelper.actor(targetId).get_name(),
	])
	reporter.attach_free_dialog(msg)
	return
