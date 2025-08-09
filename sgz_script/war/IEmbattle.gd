extends Resource

var war_actor_location_system:Dictionary

#获取布阵
func _init() -> void:
	war_actor_location_system = StaticManager.war_actor_location_system.duplicate(true)
	return

func get_all_valid_positions(wa:War_Actor)->PoolVector2Array:
	var wf = DataManager.get_current_war_fight()
	var wv = wa.war_vstate()
	if wv == null:
		return PoolVector2Array([])
	var ret = []
	var setting = get_embattle_setting(wv)
	if setting.empty():
		return ret
	if "布阵坐标" in setting and typeof(setting["布阵坐标"]) == TYPE_VECTOR2_ARRAY:
		var positions = PoolVector2Array(setting["布阵坐标"])
		ret.append_array(positions)
	if "布阵范围" in setting and typeof(setting["布阵范围"]) == TYPE_RECT2:
		var area = Rect2(setting["布阵范围"])
		var minX = area.position.x
		var maxX = area.size.x
		var minY = area.position.y
		var maxY = area.size.y
		for x in range(minX, maxX + 1):
			for y in range(minY, maxY + 1):
				ret.erase(Vector2(x, y))
				ret.append(Vector2(x, y))
	return ret

#获取军势布阵范围和可选位置
func get_embattle_setting(wv:War_Vstate)->Dictionary:
	var wf = DataManager.get_current_war_fight()
	if wv == null:
		return {}
	if wv.is_defender() and not wv.is_reinforcement():
		return get_defender_embattle_setting()

	var type = "攻"
	var ret:Dictionary = {};
	
	var positions:PoolVector2Array = []
	var locationArea = Rect2()
	var dir = get_attacking_direction(wv)
	if dir < 0:
		# 强制设定
		dir = 90
	
	if war_actor_location_system.has(str(dir)):
		var dic = war_actor_location_system[str(dir)]
		for v in dic[type]:
			positions.append(Vector2(int(v["x"]), int(v["y"])))
		var area = dic[type + "范围"]
		locationArea = Rect2(int(area["minX"]), int(area["minY"]), int(area["maxX"]), int(area["maxY"]))

	return {
		"布阵坐标": positions,
		"布阵范围": locationArea
	}

# 所有可布阵范围
func get_embattle_all_area(wv:War_Vstate)->Array:
	var setting = get_embattle_setting(wv)
	if not wv.is_attacker():
		return [setting["布阵范围"]]
	if SkillRangeBuff.max_val_for_war_vstate("全方向布阵", wv.id) <= 0:
		return [setting["布阵范围"]]
	var ret = []
	for dir in war_actor_location_system:
		var dic = war_actor_location_system[dir]
		var area = dic["攻范围"]
		var r = Rect2(int(area["minX"]), int(area["minY"]), int(area["maxX"]), int(area["maxY"]))
		ret.append(r)
	return ret

#获取守方阵型
func get_defender_embattle_setting()->Dictionary:
	var type = "守"
	
	var positions:PoolVector2Array = []
	var locationArea = Rect2()

	var map = SceneManager.current_scene().war_map
	var center = map.get_position_by_buildCN("太守府")
	var mainCityPosition = map.get_position_by_buildCN("太守府")

	var attackingDir = get_attacking_direction()
	if attackingDir < 0:
		attackingDir = 0
	if war_actor_location_system.has(str(attackingDir)):
		var dic = war_actor_location_system[str(attackingDir)]
		for v in dic[type]:
			positions.append(mainCityPosition + Vector2(int(v["x"]), int(v["y"])))
		var area = dic[type + "范围"]
		var min_v = mainCityPosition + Vector2(int(area["minX"]), int(area["minY"]))
		var max_v = mainCityPosition + Vector2(int(area["maxX"]), int(area["maxY"]))
		locationArea = Rect2(min_v,max_v);
	#添加所有城门坐标
	var doorPostions = Array(map.door_position).duplicate()
	#记录未正位加入的城门数
	var doorsLeft = []
	var added = 0
	while not doorPostions.empty():
		var doorPos = doorPostions.pop_front()
		var dis_v = mainCityPosition - doorPos
		var dis_v_x = dis_v.x/max(1, abs(dis_v.x))
		var dis_v_y = dis_v.y/max(1, abs(dis_v.y))
		if dis_v_x > 0 && dis_v_y == 0 && attackingDir == 0:
			positions.insert(1, doorPos)
			added += 1
			continue
		if dis_v_x < 0 && dis_v_y == 0 && attackingDir == 180:
			positions.insert(1, doorPos)
			added += 1
			continue
		if dis_v_x == 0 && dis_v_y < 0 && attackingDir == 90:
			positions.insert(1, doorPos)
			added += 1
			continue
		if dis_v_x == 0 && dis_v_y > 0 && attackingDir == 270:
			positions.insert(1, doorPos)
			added += 1
			continue
		var dist = abs(dis_v.x) + abs(dis_v.y)
		var i = 0
		while i < doorsLeft.size() and doorsLeft[i][1] < dist:
			i += 1
		doorsLeft.insert(i, [doorPos, dist])
	#未正位加入的城门, 按距离由近到远加入布阵位置
	doorsLeft.invert()
	for doorPos in doorsLeft:
		positions.insert(1 + added, doorPos[0])

	return {
		"布阵坐标": positions,
		"布阵范围": locationArea
	}

#获取攻击队往防守方的角度
func get_attacking_direction(wv:War_Vstate=null)->int:
	var wf = DataManager.get_current_war_fight()
	if wv == null:
		wv = wf.attackerWV
	var specified = wf.get_war_direction(wv.id)
	if specified > 0:
		return specified

	#获取攻击方->防守方角度
	var deg:float = DataManager.get_direction_by_city_AtoB(wv.from_cityId, wf.targetCityId)
	var ret = 0
	#不同角度，方向就有差别
	if 0 < deg && deg <= 90:
		ret = 45
	elif 90 < deg && deg <= 180:
		ret = 135
	elif 180 < deg && deg <= 270:
		ret = 225
	elif deg > 270:
		ret = 315
	else:
		ret = int(deg)
	# 仅针对主攻方设定当前方向
	if wv.is_attacker() and not wv.is_reinforcement():
		wf.warDirection = ret
	return ret

#设置默认武将所在的坐标
func set_default_actor_embattle(wa:War_Actor)->void:
	var wf = DataManager.get_current_war_fight()
	var wv = wa.war_vstate()
	if wv == null:
		return
	var embattleSetting = get_embattle_setting(wv)
	if embattleSetting.empty():
		return
	var positions = PoolVector2Array(embattleSetting["布阵坐标"])
	var locationArea = Rect2(embattleSetting["布阵范围"])
	# 安全位置（通常是防守方的城内）
	# 同时作为后续的排除位置
	# 避免城里挤人太多，引发劫火或其他危机
	# 也避免兵力无用
	var safePositions = []
	# 挑战难度下，防守方尽量利用城墙保护弱者
	if DataManager.diffculities >= 4 and wa.is_defender() and not wa.is_reinforcement():
		# 优先寻找靠近太守府的位置
		safePositions = _get_safe_positions(wa)
		_set_protective_actor_embattle(wa, safePositions)
		# 在回到默认逻辑之前，先把城内的位置标记去除
	# 回到默认逻辑
	# 是否存在坐标
	if not wa.has_position():
		for pos in positions:
			if pos in safePositions:
				continue
			#已被武将占用坐标时跳过
			if not wa.can_move_to_position(pos):
				continue
			#坐标未被占用时，在该坐标布阵
			wa.position = pos
			break
	if not wa.has_position():
		#还是没有分配坐标，则在范围内随机设置武将坐标
		var minX = locationArea.position.x
		var maxX = locationArea.size.x
		var minY = locationArea.position.y
		var maxY = locationArea.size.y
		var retries = 10
		while true:
			var x = Global.get_random(minX, maxX)
			var y = Global.get_random(minY, maxY)
			var pos = Vector2(x, y)
			# 有限次地排除指定位置，避免无限循环
			if retries >= 0 and pos in safePositions:
				retries -= 1
				continue
			if not wa.can_move_to_position(pos):
				continue
			wa.position = pos
			break
	return

#判断武将是否能在指定位置上布阵
func check_actor_location_is_in_area(actorId:int, position:Vector2)->bool:
	var wa = DataManager.get_war_actor(actorId)
	if wa == null:
		return false
	var wv = wa.war_vstate()
	if wv == null:
		return false
	var embattleSetting = get_embattle_setting(wv)
	if embattleSetting.empty():
		return false;
	if position in embattleSetting["布阵坐标"]:
		return true
	for r in get_embattle_all_area(wv):
		if position.x >= r.position.x\
			and position.x <= r.size.x\
			and position.y >= r.position.y\
			and position.y <= r.size.y:
			return true
	return false

# 目标位置不在合法布阵位置，三种情况：
# 一是普通的移出了范围，那么当前位置在合法范围中，什么都不做
# 二是一开始出现的位置就不在合法范围内，这时候允许移动到合法布阵范围内（大城市布阵远城门的情况）
# 三是之前因为二的情况，从合法范围外移动到合法范围内，但是又想回去
func reset_actor_location(actorId:int, dir:Vector2)->void:
	var wf = DataManager.get_current_war_fight()
	var wa = DataManager.get_war_actor(actorId)
	if wa == null or wa.disabled:
		return

	if wa.is_reinforcement():
		return

	# 防守方
	if wa.is_defender():
		reset_defender_location(wa, dir)

	# 进攻方
	if wa.is_attacker():
		reset_attacker_location(wa, dir)

	return

func reset_defender_location(wa:War_Actor, dir:Vector2)->void:
	# 在所有可用位置里找最近的
	var nearest = null
	var minDistance = 9999
	for pos in get_all_valid_positions(wa):
		var disv = pos - wa.position
		if dir.x > 0 and disv.x <= 0:
			continue
		if dir.x < 0 and disv.x >= 0:
			continue
		if dir.y > 0 and disv.y <= 0:
			continue
		if dir.y < 0 and disv.y >= 0:
			continue
		var distance = abs(disv.x) + abs(disv.y)
		if distance < minDistance:
			minDistance = distance
			nearest = pos
	if nearest != null:
		wa.move(nearest)
	return

func reset_attacker_location(wa:War_Actor, dir:Vector2)->void:
	# 在所有可用范围里找最近的
	var nearest = null
	var minDistance = 9999
	for r in get_embattle_all_area(wa.war_vstate()):
		for x in range(r.position.x, r.size.x + 1):
			for y in range(r.position.y, r.size.y + 1):
				var pos = Vector2(x, y)
				var disv = pos - wa.position
				if dir.x > 0 and disv.x <= 0:
					continue
				if dir.x < 0 and disv.x >= 0:
					continue
				if dir.y > 0 and disv.y <= 0:
					continue
				if dir.y < 0 and disv.y >= 0:
					continue
				var distance = abs(disv.x) * abs(disv.y) + abs(disv.x) + abs(disv.y)
				if distance < minDistance:
					minDistance = distance
					nearest = pos
	if nearest != null:
		wa.move(nearest)
	return

# 内部方法，寻找安全位置，对防守方来说就是主城周围的非城墙位置
func _get_safe_positions(wa:War_Actor)->PoolVector2Array:
	var map = SceneManager.current_scene().war_map
	if not "太守府" in map.builds_position:
		return PoolVector2Array([])
	var center = map.builds_position["太守府"]
	var checked = []
	var checkings = [center]
	var ret = []
	# 从太守府开始，寻找每个位置的周边平原地形
	while not checkings.empty():
		var from = checkings.pop_front()
		for dir in StaticManager.NEARBY_DIRECTIONS:
			var pos = from + dir
			if pos in checked:
				continue
			checked.append(pos)
			var terrian = map.get_blockCN_by_position(pos)
			if terrian != "平原":
				continue
			if not wa.can_move_to_position(pos):
				continue
			checkings.append(pos)
			ret.append(pos)
	return ret

#设置尽可能安全的武将位置
func _set_protective_actor_embattle(wa:War_Actor, safePositions:PoolVector2Array)->void:
	var map = SceneManager.current_scene().war_map
	for door in map.door_position:
		if wa.can_move_to_position(door):
			# 有空城门，忽略此逻辑
			return
	var a = wa.actor()
	if a.get_wisdom() < 80 and max(a.get_leadership(), a.get_power()) >= 70 \
		or a.get_power() * a.get_leadership() >= 2500 \
		or a.get_soldiers() < 500:
		return
	var optionals = Array(safePositions)
	optionals.shuffle()
	for pos in optionals:
		if wa.can_move_to_position(pos):
			wa.position = pos
			break
	return
