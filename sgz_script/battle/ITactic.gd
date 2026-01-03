extends Resource

#默认咒缚命中率
const DEFAULT_STOP_RATE = 50

#获取指定武将的战术值
func get_actor_tactic(actorId:int, includeSkills:bool=true) -> PoolStringArray:
	var ret = []
	var wa = DataManager.get_war_actor(actorId)
	if wa.can_use_tactic() and not wa.continuous_tactic_on():
		for name in StaticManager.TACTICS.keys():
			var cost = get_tactic_cost(wa, name)
			if cost > wa.battle_tactic_point:
				continue
			ret.append(name)

		#没有一个战术能用，玩家列表也显示个【束缚】,AI没有
		if ret.empty() and not wa.is_AI_use():
			ret.append(StaticManager.TACTICS.keys()[0])

	if includeSkills:
		# 加入白刃战主动技
		for skill in SkillHelper.get_actor_active_skills(actorId):
			ret.append("<{0}>".format([skill.name]))

	var bf = DataManager.get_current_battle_fight()
	# 本场战斗不可发起单挑
	if bf.solo_disabled():
		ret.erase("挑衅")

	return ret

#获取战术值消耗
func get_tactic_cost(wa:War_Actor, tactic:String)->int:
	var val:int = 0
	if StaticManager.TACTICS.has(tactic):
		var tacticInfo = StaticManager.TACTICS[tactic]
		val = int(tacticInfo["消耗"])
	var key = "{0}额外消耗".format([tactic])
	if wa.dic_other_variable.has(key):
		val += int(wa.dic_other_variable[key])
	key = "{0}固定消耗".format([tactic])
	if wa.dic_other_variable.has(key):
		val = int(wa.dic_other_variable[key])
	return val

#获取描述
func get_tactic_description(actorId:int,tactic_name:String):
	var val:int = 0
	if !StaticManager.TACTICS.has(tactic_name):
		return "";
	var tac_tic_dic = StaticManager.TACTICS[tactic_name];
	var desc = str(tac_tic_dic["描述"]);
	desc = desc.replace("{咒缚成功率}",str(get_stop_tactic_rate(actorId)))
	return desc;
	
#获取咒缚成功率
func get_stop_tactic_rate(actorId:int)->int:
	var rate = DEFAULT_STOP_RATE
	var actor = ActorHelper.actor(actorId)
	rate += actor.get_equip_feature_max("咒缚成功率加成")
	return int(min(100, rate))
