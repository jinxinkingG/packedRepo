extends "effect_20000.gd"

#龙胆和绝境的实现，突进技能
#【龙胆】大战场,主动技。你可以选择1个6格内的空位，消耗5点机动力发动：你直接位移至指定地点。一回合限一次。
#【绝境】大战场,锁定技。你发动<龙胆>时，恢复10点体力；若你方「仅有你」或「仅有你和刘禅」的场合，龙胆没有一回合一次限制。

const EFFECT_ID = 20003
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 5
const RECOVER_HP = 10

func check_AI_perform_20000()->bool:
	# 防守方主将不跳
	if me.is_defender() and me.get_main_actor_id() == actorId:
		return false
	unset_env("AI.龙胆.目标")
	if me.action_point < COST_AP:
		return false
	# 优先级：占主城 > 绝境+劣势自保 > 攻击主城 > 攻击主将 > 攻击弱点 > 占城门
	var enemies = get_enemy_targets(me, true, 7)
	map.aStar.update_map_for_actor(me)
	var targets = []
	#1. 主城
	var cityPosition = map.get_position_by_buildCN("太守府")
	targets.append([cityPosition, null])
	#2. 绝境+劣势自保
	if actor.get_hp() <= 70 and desperate_situation():
		var disv = cityPosition - me.position
		if disv.x > 0:
			var targetPosition = Vector2(max(0, me.position.x - 6), me.position.y)
			targets.append([targetPosition, null])
		else:
			var targetPosition = Vector2(min(map.cell_columns - 1, me.position.x + 6), me.position.y)
			targets.append([targetPosition, null])
	#3. 攻击主城
	for dir in StaticManager.NEARBY_DIRECTIONS:
		targets.append([cityPosition, cityPosition])
	#4. 攻击主将
	#5. 攻击弱点
	var weakPoint = null
	var leastPower = 50 * actor.get_soldiers()
	for targetId in enemies:
		var targetWA = DataManager.get_war_actor(targetId)
		if targetId == targetWA.get_main_actor_id():
			# 找到主将
			targets.append([targetWA.position, targetWA.actorId])
		var targetActor = ActorHelper.actor(targetId)
		var morale = me.calculate_battle_morale(targetActor.get_power(), targetActor.get_leadership())
		var power = morale * targetActor.get_soldiers()
		if power < leastPower:
			weakPoint = targetWA
			leastPower = power
	if weakPoint != null:
		for dir in StaticManager.NEARBY_DIRECTIONS:
			targets.append([weakPoint.position + dir, weakPoint.actorId])
	#6. 占近端城门
	var main_position = map.get_position_by_buildCN("太守府");
	for doorPosition in map.door_position:
		var disv1 = main_position - doorPosition
		var disv2 = me.position - main_position
		if abs(disv1.x) + abs(disv1.y) > abs(disv2.x) + abs(disv2.y):
			continue
		targets.append([doorPosition, null])
	# 逐个判断
	for target in targets:
		var pos = target[0]
		if me.position == pos:
			return false
		var disv = pos - me.position
		if max(abs(disv.x), abs(disv.y)) > 6:
			continue
		var wa = DataManager.get_war_actor_by_position(pos)
		if wa != null:
			continue
		if map.get_blockCN_by_position(pos) == "城墙":
			continue
		var path = map.aStar.get_skill_path(me.position, pos, 6)
		if path.size() <= 1:
			continue
		set_env("AI.龙胆.目标", [pos.x, pos.y, target[1]])
		return true
	return false

func effect_20003_AI_start():
	var target = get_env_int_array("AI.龙胆.目标")
	var pos = Vector2(target[0], target[1])
	var path = map.aStar.get_skill_path(me.position, pos, 6)
	map.camer_to_actorId(me.actorId, "draw_actors")
	map.show_color_block_by_position(path, Color(0.0, 0.0, 0.8, 0.3))
	var reporter = -1
	var wv = me.war_vstate()
	if wv != null:
		var enemyWV = wv.get_enemy_vstate()
		if enemyWV != null:
			reporter = enemyWV.main_actorId
	var msg = "{0}发动【{1}】".format([me.get_name(), ske.skill_name])
	play_dialog(reporter, msg, 0, 3000)
	return

func on_view_model_3000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_AI_2")
	return

func effect_20003_AI_2():
	var target = get_env_int_array("AI.龙胆.目标")
	var pos = Vector2(target[0], target[1])
	ske.cost_ap(COST_AP, true)
	ske.change_war_actor_position(me.actorId, pos)

	map.show_color_block_by_position([])
	if target[2] >= 0:
		var key = "战争.AI.优先目标.{0}".format([me.actorId])
		set_env(key, target[2])
	var msg = _try_recover_and_get_message()
	ske.war_report()
	play_dialog(me.actorId, msg, 0, 3001)
	return

func on_view_model_3001():
	wait_for_skill_result_confirmation("AI_skill_end_trigger")
	return

func effect_20003_start():
	if not assert_action_point(me.actorId, COST_AP):
		return
	map.show_color_block_by_position([])
	map.cursor.show()
	map.clear_can_choose_actors()
	var msg = "请指定{0}释放地点".format([ske.skill_name])
	# 这一步目前是必要的，确保正确的技能范围定位
	get_skill_centers(me)
	play_dialog(me.actorId, msg, 2, 2000)
	return

func on_view_model_2000():
	wait_for_free_position(FLOW_BASE + "_2")
	return

func effect_20003_2():
	var target = map.cursor_position
	var disv = me.position - target
	var distance = max(abs(disv.x), abs(disv.y))
	var maxDistance = get_choose_distance()
	if distance > maxDistance:
		SceneManager.show_unconfirm_dialog("位移距离不能超过{0}".format([maxDistance]), me.actorId)
		LoadControl.set_view_model(2000)
		return
	var wa = DataManager.get_war_actor_by_position(target)
	if wa != null and not wa.disabled:
		SceneManager.show_unconfirm_dialog("必须选择空位", me.actorId)
		LoadControl.set_view_model(2000)
		return
	if map.get_blockCN_by_position(target) == "城墙":
		SceneManager.show_unconfirm_dialog("不能位移到城墙上", me.actorId)
		LoadControl.set_view_model(2000)
		return
	map.aStar.update_map_for_actor(me)
	var path = map.aStar.get_skill_path(me.position, target, 6)
	if path.size() <= 1:
		map.show_color_block_by_position([])
		SceneManager.show_unconfirm_dialog("存在阻碍，不能位移到此处!", me.actorId)
		LoadControl.set_view_model(2000)
		return
	map.show_color_block_by_position(path, Color(0.0, 0.0, 0.8, 0.3))
	set_env("龙胆目标", {"x":target.x, "y":target.y})
	var msg = "消耗{0}点机动力\n可否？".format([COST_AP])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20003_3():
	ske.cost_ap(COST_AP, true)
	var target = get_env_dict("龙胆目标")
	var pos = Vector2(int(target["x"]), int(target["y"]))
	ske.change_war_actor_position(me.actorId, pos)
	var msg = _try_recover_and_get_message()
	ske.war_report()
	play_dialog(actorId, msg, 0, 2999)
	return

func desperate_skill()->bool:
	return SkillHelper.actor_has_skills(actorId, ["绝境"])

func desperate_situation()->bool:
	if not desperate_skill():
		return false
	var teammates = get_teammate_targets(me, 999)
	if teammates.empty():
		return true
	if teammates.size() == 1 and teammates[0] == StaticManager.ACTOR_ID_LIUSHAN:
		return true
	return false

func _try_recover_and_get_message()->String:
	var recoveredHP = 0
	var noCD = desperate_situation()
	# 直接判断是否解锁【绝境】
	if desperate_skill():
		recoveredHP = ske.change_actor_hp(me.actorId, RECOVER_HP)
	if not noCD:
		ske.cost_war_cd(1)
	var msg = "能进能退\n乃真正法器！"
	if recoveredHP > 0 and noCD:
		msg = "能进能退，乃真正法器！\n【绝境】{1}体力恢复{2}\n本回合可继续发动龙胆"
	elif recoveredHP > 0:
		msg = "能进能退，乃真正法器！\n【绝境】{1}体力恢复{2}"
	elif noCD:
		msg = "能进能退，乃真正法器！\n【绝境】\n本回合可继续发动龙胆"
	msg = msg.format([
		ske.skill_name, me.get_name(), recoveredHP
	])
	return msg
