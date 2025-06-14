extends "effect_20000.gd"

#苦肉效果
#【苦肉】大战场,锁定技。你方队友可以对你使用伤兵计策且必中。当你受到计策伤害时，与你相邻的对方武将（非城地形），受到与该计策相同的伤害。若拥有<都督>的队友对你用计，可为你避免伤害。

const RELATED_SKILL = "都督"

func on_trigger_20026()->bool:
	# AI 不发动
	if me.get_controlNo() < 0:
		return false
	# 自己不发动
	if ske.actorId == actorId:
		return false
	var typeKey = "战争.DAILY.目标无视阵营.{0}".format([actorId])
	DataManager.set_env(typeKey, 1)
	return false

func on_trigger_20010()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if not se.damage_soldier():
		return false
	if se.actionId != ske.actorId:
		return false
	if se.targetId != actorId:
		return false
	se.set_must_success(actorId, ske.skill_name)
	return false

func on_trigger_20002()->bool:
	var se = DataManager.get_current_stratagem_execution()
	var targetId = DataManager.get_env_int("计策.ONCE.伤害武将")
	if targetId != actorId:
		return false
	var damage = DataManager.get_env_int("计策.ONCE.伤害")
	damage = min(damage, actor.get_soldiers())
	var enhanceRate = actor.get_equip_feature_max("苦肉增强")
	if enhanceRate > 0:
		damage += int(damage * enhanceRate / 100)
	if damage <= 0:
		return false
	var actionId = se.get_action_id(actorId)
	if actorId != actionId:
		var actioner = DataManager.get_war_actor(actionId)
		if me.is_teammate(actioner) and SkillHelper.actor_has_skills(actionId, [RELATED_SKILL], false):
			DataManager.set_env("计策.ONCE.伤害", 0)
			var msg = "{0}【{1}】令{2}规避伤害".format([
				ActorHelper.actor(actionId).get_name(),
				RELATED_SKILL, actor.get_name(),
			])
			se.append_result(RELATED_SKILL, msg, 0, actorId)
			if se.name == "劫火" and DataManager.get_env_int("战争." + RELATED_SKILL + ".对话") <= 0:
				se.skip_redo = 1
				var extraMsg = "{0}，计成矣\n{1}匹夫，骄横必亡！".format([
					DataManager.get_actor_honored_title(actionId, actorId),
					me.get_enemy_leader().get_name(),
				])
				me.attach_free_dialog(extraMsg, 1)
				DataManager.set_env("战争." + RELATED_SKILL + ".对话", 1)
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = dir + me.position
		if map.get_blockCN_by_position(pos) in StaticManager.CITY_BLOCKS_CN:
			continue
		var wa = DataManager.get_war_actor_by_position(pos)
		if not me.is_enemy(wa):
			continue
		var chainedDamage = min(damage, wa.get_soldiers())
		if chainedDamage <= 0:
			continue
		var msg = "{0}【{1}】令{2}损兵{3}".format([
			me.get_name(), ske.skill_name, wa.get_name(), chainedDamage
		])
		DataManager.damage_sodiers(se.fromId, wa.actorId, chainedDamage)
		se.append_result(ske.skill_name, msg, 0, actorId)
	return false
