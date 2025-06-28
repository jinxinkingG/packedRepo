extends Resource


func check_action(unit:Battle_Unit)->Dictionary:
	DataManager.common_variable["白兵.刀类影响目标"]=[];
	DataManager.common_variable["白兵.枪类影响目标"]=[];
	#被嘲讽的效果
	var taunt:Array = _get_taunt_by_enemy(unit)
	# 先获取近身可攻击的单位
	var directTargets = unit.get_unit_attack_area()
	#射箭攻击
	var shoot_atk = _action_shoot(unit, taunt, directTargets)
	#近身攻击
	var attack = _action_attack(unit, taunt, directTargets)
	#暗器攻击
	var throw_atk = _action_throw(unit,taunt);
	#攻击行为优先级数组（默认按近身>投掷暗器>射箭）
	var actions = [attack,throw_atk,shoot_atk];
	var taunt_actions = [];
	for taunt_action in actions:
		if not taunt_action.has("目标坐标"):
			continue;
		var pos_array = str(taunt_action["目标坐标"]).split(",");
		var pos_vect2 = Vector2(pos_array[0],pos_array[1]);
		var tar = DataManager.get_battle_unit_by_position(pos_vect2);
		if tar != null and tar.Type in taunt:
			taunt_actions.append(taunt_action);
	#嘲讽数组不为空，则将嘲讽数组置入攻击优先级数组
	if !taunt_actions.empty():
		actions = taunt_actions;
	
	match unit.get_unit_type():
		"弓": # 弓箭手优先射击
			#攻击优先级：射箭>暗器>近身攻击
			actions.invert()#弓箭行为逆转
			for action in actions:
				if(!action.empty()):
					DataManager.set_env("白兵.攻击目标", action["攻击目标"])
					DataManager.set_env("白兵.攻击来源", unit.unitId)
					return action;
		_:#攻击优先级：近身攻击>暗器>射箭
			for action in actions:
				if(!action.empty()):
					DataManager.set_env("白兵.攻击目标", action["攻击目标"])
					DataManager.set_env("白兵.攻击来源", unit.unitId)
					return action;

	#移动
	var action = _action_move(unit);
	if(!action.empty()):
		return action;

	#默认行为改为待机
	return {
		"单位ID":unit.unitId,
		"行为方式":"待机",
		"目标坐标":"{0},{1}".format([unit.unit_position.x,unit.unit_position.y])
	}

#射箭逻辑
func _action_shoot(unit:Battle_Unit, taunt:Array, directTargets:Dictionary)->Dictionary:
	var bf = DataManager.get_current_battle_fight()
	var scene_battle = SceneManager.current_scene();
	#读取全兵种的行军状态
	#当前兵种的状态
	var state = unit.get_state();

	#后退状态，无法射箭
	if (state in ["后退"]):
		return {};

	#武将和骑兵包围状态不射箭
	if (unit.get_unit_type() in ["将","骑"] && state in ["包围"]):
		return {};

	#不会射箭直接返回
	var shoot_distance = unit.get_shoot_distance()
	if shoot_distance <= 0:
		return {}
	
	var shoot_rate = 70;#默认70%射箭	
	
	if unit.is_fire_shooting() or unit.is_far_shooting():
		#强弩/火矢发动过程中，必定射箭
		shoot_rate = 100;
	elif(unit.get_side() == Vector2.RIGHT || state in ["待机"]):
		#待机状态必射，守城必射
		shoot_rate = 100;
	#不射箭，跳出
	if(!Global.get_rate_result(shoot_rate)):
		return {};

	#寻找射箭目标unit
	var dic_direct_enemys = {
		"left":[],
		"right":[],
		"up":[],
		"down":[]
	};
	var dic_direct_position = {
		"left":Vector2(-1,0),
		"right":Vector2(1,0),
		"up":Vector2(0,-1),
		"down":Vector2(0,1)
	};
	var set_ignore_block = StaticManager.get_battle_ignore_block_setting()
	var is_ignore_block = false;
	var war_actor = DataManager.get_war_actor(unit.leaderId)
	if(set_ignore_block.has(war_actor.get_troops_type())):
		var block_type_array = set_ignore_block[war_actor.get_troops_type()];
		is_ignore_block = (bf.get_terrian() in block_type_array);
	#从身边一个个往外找目标
	for dir in dic_direct_position:
		for i in shoot_distance:
			var real_distance = i+1;
			var add:Vector2 = dic_direct_position[dir]*real_distance;
			#目标坐标
			var pos:Vector2 = unit.unit_position + add
			#先检查目标有没有人，有就写入目标数组
			var target = DataManager.get_battle_unit_by_position(pos)
			if target == null:
				# 没有单位，检测是否是射击障碍
				if not is_ignore_block:
					#仅检测非优势地形的军种
					if scene_battle.get_position_is_arrowblock(pos):
						break
				continue
			# 跳过己方单位和中立单位
			if target.leaderId in [unit.leaderId, -1]:
				continue
			# 跳过同列城门单位
			if int(dic_direct_position[dir].x) == 0 && target.Type == "城门":
				continue
			# 若在近身攻击范围内，break 跳过这个方向
			var melee = false
			if dir in directTargets:
				for bu in directTargets[dir]:
					if target.unitId == bu.unitId:
						melee = true
						break
			if melee:
				# 只要有目标，不论近远程都算是阻碍
				break
			# 判断武将目标
			if target.get_unit_type() in ["将"]:
				#目标为武将时
				if state in ["包围"]:
					break;#自己是包围状态，不射
				if unit.get_unit_type() in ["将"]:
					#是否允许射武将（0：不允许，>0：对方体力大于设定值则可射）
					if not unit.shootable(target):
						# 没有设定，或对面体<设定值，不射
						break
			# 写入射箭目标
			dic_direct_enemys[dir].append(target)
			# 只要有目标，不论近远程都算是阻碍
			break

	var dir_has_enemy = [];
	for dir in dic_direct_enemys:
		if(dic_direct_enemys[dir].size()>0):
			dir_has_enemy.append(dir);

	#不存在可射击的目标时，直接退出
	if(dir_has_enemy.size()==0):
		return {};
	
	var dic_direct_value = {
		"down":0,
		"left":1,
		"right":2,
		"up":3
	};
	
	var target_unit;#攻击谁
	var shoot_to_position;#射箭目标点位
	var shoot_dir;#射箭方向
	
	#判断是否存在被嘲讽优先攻击的对象
	var new_dic_direct_enemys={};
	var new_dir_has_enemy = [];
	if not taunt.empty():
		for dir in dir_has_enemy:
			var tu = dic_direct_enemys[dir][0];
			if tu.Type in taunt:
				new_dic_direct_enemys[dir] = [tu];
				new_dir_has_enemy.append(dir);
	
	if not new_dic_direct_enemys.empty():
		dic_direct_enemys = new_dic_direct_enemys;
		dir_has_enemy = new_dir_has_enemy;

	#打乱顺序
	dir_has_enemy.shuffle();
	#射击方向
	shoot_dir = dir_has_enemy[0];
	#获取射击目标
	target_unit = dic_direct_enemys[shoot_dir][0];
	shoot_to_position = target_unit.unit_position;
	
	var targets = [target_unit.unitId]
	
	var dic = {
		"单位ID":unit.unitId,
		"行为方式":"射箭",
		"攻击目标":targets,
		"目标坐标":"{0},{1}".format([shoot_to_position.x,shoot_to_position.y])
	}
	
	return dic;

#投掷逻辑
func _action_throw(unit:Battle_Unit,taunt:Array=[])->Dictionary:
	var bf = DataManager.get_current_battle_fight()
	var scene_battle = SceneManager.current_scene();
	#读取全兵种的行军状态
	#当前兵种的状态
	var state = unit.get_state();

	#后退状态，无法射箭
	if state in ["后退"]:
		return {}

	#武将和骑兵包围状态不投掷
	if unit.get_unit_type() in ["将","骑"] && state in ["包围"]:
		return {};

	#获取攻击和投掷距离
	var meleeDistance = unit.get_attack_distance()
	var throwDistance = unit.get_throw_distance()
	var throwType = unit.get_throw_type()
	var throwTargetTypes = unit.get_throw_target_types()

	if throwDistance <= 0 or throwDistance < meleeDistance:
		return {}

	#默认70%投掷
	var throwRate = 70
	if state in ["待机"]:
		throwRate = 100

	#不投掷，跳出
	if not Global.get_rate_result(throwRate):
		return {}

	#寻找投掷目标unit
	var targetsInDirections = {
		"left":[],
		"right":[],
		"up":[],
		"down":[]
	};
	var directions = {
		"left": Vector2.LEFT,
		"right": Vector2.RIGHT,
		"up": Vector2.UP,
		"down": Vector2.DOWN
	};
	var blockIgnoreSetting = StaticManager.get_battle_ignore_block_setting()
	var blockIgnored = false
	var leader = unit.leader()
	if blockIgnoreSetting.has(leader.get_troops_type()):
		blockIgnored = bf.get_terrian() in blockIgnoreSetting[leader.get_troops_type()]
	# 从身边一格一格检查
	for dir in directions:
		for i in throwDistance:
			var disv:Vector2 = directions[dir] * (i + 1)
			#目标坐标
			var targetPos:Vector2 = unit.unit_position + disv
			#先检查目标有没有人，有就写入目标数组
			var target = DataManager.get_battle_unit_by_position(targetPos)
			if target == null:
				# 没有单位，再检测是否是射击障碍
				if not blockIgnored:#仅检测非优势地形的军种
					if scene_battle.get_position_is_arrowblock(targetPos):
						break
				continue
			# 跳过己方单位和中立单位
			if target.leaderId in [-1, unit.leaderId]:
				continue
			# 跳过纵向的城门单位
			if int(directions[dir].x) == 0 and target.Type == "城门":
				continue
			if i < meleeDistance:
				# 目标在近身攻击范围内
				# 注意这里的检查不能提前，因为要判断障碍物
				continue
			if state in ["包围"] and target.get_unit_type() in ["将"]:
				#状态为包围，且目标是主将时，不做考虑，并且当做障碍
				break
			if not throwTargetTypes.empty() and not target.get_unit_type() in throwTargetTypes:
				# 判断类型是否允许
				continue
			if unit.get_unit_type() == "将" and target.get_unit_type() == "将":
				if target.get_hp() < 50:
					# 武将不能对 hp 50 以下的武将投掷
					continue
			# 找到目标，跳出
			targetsInDirections[dir].append(target)
			break

	var possibleDirections = []
	for dir in targetsInDirections:
		if targetsInDirections[dir].size() > 0:
			possibleDirections.append(dir)

	# 不存在可投掷的目标时，直接退出
	if possibleDirections.empty():
		return {};

	var dic_direct_value = {
		"down":0,
		"left":1,
		"right":2,
		"up":3
	};
	
	#判断是否存在被嘲讽优先攻击的对象
	var prioredTargets = {}
	var prioredDirections = []
	if not taunt.empty():
		for dir in possibleDirections:
			var target = targetsInDirections[dir][0]
			if target.Type in taunt:
				prioredTargets[dir] = [target]
				prioredDirections.append(dir)

	if not prioredTargets.empty():
		targetsInDirections = prioredTargets
		possibleDirections = prioredDirections

	# 随机选择方向
	possibleDirections.shuffle()
	var finalDirection:String = possibleDirections[0]

	# 决定投掷目标
	var target = targetsInDirections[finalDirection][0]

	# 类似攻击，增加投掷的波及范围，支持分散多掷
	var targets = [target.unitId]

	var dic = {
		"单位ID": unit.unitId,
		"行为方式": "投掷",
		"目标坐标": "{0},{1}".format([target.unit_position.x, target.unit_position.y]),
		"攻击目标": targets,
		"附加信息": throwType,
	}

	return dic

#进入近身攻击逻辑
func _action_attack(unit:Battle_Unit, taunt:Array, directTargets:Dictionary)->Dictionary:
	var scene_battle = SceneManager.current_scene();

	#当前兵种的状态
	var state = unit.get_state();

	#后退状态，无法近身攻击
	if (state in ["后退"]):
		return {};

	var dir_has_enemy = [];
	for dir in directTargets:
		if directTargets[dir].size() > 0:
			dir_has_enemy.append(dir)

	var targets = []
	
	if dir_has_enemy.empty():
		#不存在可近身战斗的目标时，直接退出
		return {};

	var dic_direct_value = {
		"down":0,
		"left":1,
		"right":2,
		"up":3
	}

	#判断是否存在被嘲讽优先攻击的对象
	var new_dic_direct_enemys={};
	var new_dir_has_enemy = [];
	if not taunt.empty():
		for dir in dir_has_enemy:
			var tu = directTargets[dir][0]
			if tu.Type in taunt:
				new_dic_direct_enemys[dir] = [tu]
				new_dir_has_enemy.append(dir)
	
	if not new_dic_direct_enemys.empty():
		directTargets = new_dic_direct_enemys;
		dir_has_enemy = new_dir_has_enemy;
	
	dir_has_enemy.shuffle();
	var attack_dir:String = dir_has_enemy[0];
	
	#获取近身攻击的目标
	var target_unit:Battle_Unit = directTargets[attack_dir][0];
	# 用单位单挑逻辑替代身份判断，未来扩展
	if unit.accept_solo() and target_unit.accept_solo():
		return {
			"单位ID":unit.unitId,
			"行为方式":"单挑",
			"攻击目标":[target_unit.unitId],
		}
		
	targets.append(target_unit.unitId);

	var equip_targets = unit.get_unit_equip_effect_area(target_unit,attack_dir);
	if(!equip_targets.empty()):
		targets.append_array(equip_targets);
	
	
	var dic = {
		"单位ID":unit.unitId,
		"行为方式":"攻击",
		"目标坐标":"{0},{1}".format([target_unit.unit_position.x,target_unit.unit_position.y]),
		"攻击目标":targets,
	}
	
	return dic;

#进入移动逻辑
func _action_move(unit:Battle_Unit,state_like = "")->Dictionary:
	var bf = DataManager.get_current_battle_fight()
	var extra_action_times_required:int = 0
	if unit.dic_combat.has("移动所需行动次数"):
		extra_action_times_required = int(unit.dic_combat["移动所需行动次数"]) - 1
	if unit.wait_action_times < extra_action_times_required:
		return {}
	var scene_battle = SceneManager.current_scene();
	#仅在包围和射箭状态下可以
	var state = unit.get_state();
	if state_like!="":
		state = state_like;
	#待机状态，无法移动
	if (state in ["待机"]):
		return {};
	var wa = DataManager.get_war_actor(unit.leaderId);
	var enemy = wa.get_battle_enemy_war_actor();

	#判断敌将有无使用咒缚
	if unit.get_unit_type() == "将":
		if enemy.get_buff("咒缚")["回合数"] > 0:
			return {}

	# 敌方主将单位所在位置
	var enemyLeaderPosition:Vector2
	var enemyLeaderUnit = enemy.battle_actor_unit()
	if enemyLeaderUnit == null:
		# 特殊情况，敌方主将不在战场
		# 如【化身】
		# 此时选择敌主将默认位置
		if unit.get_side() == Vector2.LEFT:
			enemyLeaderPosition = Vector2(14, 5)
		else:
			enemyLeaderPosition = Vector2(1, 5)
	else:
		enemyLeaderPosition = enemyLeaderUnit.unit_position

	# 可否无视障碍
	var blockingIgnored = false
	if unit.get_combat_val_max("仙兵") > 0:
		blockingIgnored = true
	else:
		var ignoreBlockingSetting = StaticManager.get_battle_ignore_block_setting()
		if wa.get_troops_type() in ignoreBlockingSetting:
			var ignoreBlockingTerrians = ignoreBlockingSetting[wa.get_troops_type()]
			blockingIgnored = bf.get_terrian() in ignoreBlockingTerrians

	# 三线规则
	var directions = []
	if int(unit.dic_combat["移动规则"]) == 0:
		directions = get_move_directions_line3Y(unit, enemyLeaderPosition)
	else:
		directions = get_move_directions_line3X(unit, enemyLeaderPosition)

	for dir in directions:
		var pos:Vector2 = unit.unit_position + dir
		# 不允许纵向出界
		if pos.y < 0 or pos.y >= scene_battle.cell_rows:
			continue
		# 非后退时，不允许横向出界
		if pos.x < 0 or pos.x >= scene_battle.cell_columns:
			if not state in ["后退"]:
				continue
		# 检查障碍阻挡
		if not blockingIgnored:
			if scene_battle.get_position_is_roadblock(pos):
				continue
		# 检查单位阻挡
		var blockingUnit = DataManager.get_battle_unit_by_position(pos)
		if blockingUnit != null and not blockingUnit.disabled:
			# 只有守方可以主动开门
			if unit.get_side() != Vector2.RIGHT or blockingUnit.get_unit_type() != "城门":
				continue
		return {
			"单位ID": unit.unitId,
			"行为方式": "移动",
			"目标坐标": "{0},{1}".format([int(pos.x), int(pos.y)])
		}

	return {}

#添加近程攻击行为
func create_attack_action(unitId:int, target_unitId:int):
	var other_unit = DataManager.battle_units[target_unitId];
	var dic = {
		"单位ID":unitId,
		"行为方式":"攻击",
		"目标坐标":"{0},{1}".format([other_unit.unit_position.x,other_unit.unit_position.y]),
		"攻击目标":[target_unitId],
	}
	DataManager.common_variable["白兵.攻击目标"]=[target_unitId];
	DataManager.common_variable["白兵.攻击来源"]=unitId;

	return dic;

#获取敌对的嘲讽种类效果（没有具体到某个单位，只是到兵种类别）
func _get_taunt_by_enemy(unit:Battle_Unit)->Array:
	if unit.get_unit_type() == "将":
		return []
	#判断对方装备效果是否带嘲讽
	if unit.actor().get_equip_feature_max("步兵嘲讽") > 0:
		return ["步"]
	return []

# 移动的首选和次选方向
# X三线原则（优先进入敌主将的X三轴）(原版步、骑、将)
# @return [dir], 依次尝试的行动方向
func get_move_directions_line3X(unit:Battle_Unit, enemyLeaderPosition)->PoolVector2Array:
	var ret = []
	var xDiff = int(unit.unit_position.x - enemyLeaderPosition.x)
	var yDiff = int(unit.unit_position.y - enemyLeaderPosition.y)
	var inRange = abs(xDiff) <= 1
	var side = unit.get_side()

	if unit.get_state() in ["后退"]:
		# 总是优先后撤
		ret.append(side)
		# 若无法水平移动，向Y三线靠拢
		if yDiff < 0:
			ret.append(Vector2.DOWN)
		elif yDiff > 0:
			ret.append(Vector2.UP)
		elif randi() % 2 == 0:
			ret.append(Vector2.UP)
			ret.append(Vector2.DOWN)
		else:
			ret.append(Vector2.DOWN)
			ret.append(Vector2.UP)
		return ret

	if not inRange:
		#在X三线外，优先水平移动
		if xDiff > 0:
			ret.append(Vector2.LEFT)
		else:
			ret.append(Vector2.RIGHT)
		# 若无法水平移动，向Y三线靠拢
		if yDiff > 0:
			ret.append(Vector2.UP)
		elif yDiff < 0:
			ret.append(Vector2.DOWN)
		elif randi() % 2 == 0:
			ret.append(Vector2.UP)
			ret.append(Vector2.DOWN)
		else:
			ret.append(Vector2.DOWN)
			ret.append(Vector2.UP)
		return ret

	# 在X三线内
	if yDiff == 0:
		# 已经同行，肯定无法水平移动了
		if randi() % 2 == 0:
			ret.append(Vector2.UP)
			ret.append(Vector2.DOWN)
		else:
			ret.append(Vector2.DOWN)
			ret.append(Vector2.UP)
		return ret

	# 其他情况，垂直移动优先
	if yDiff > 0:
		ret.append(Vector2.UP)
	else:
		ret.append(Vector2.DOWN)
	# 无法垂直移动时，向X三线靠拢
	if xDiff > 0:
		ret.append(Vector2.LEFT)
	elif xDiff < 0:
		ret.append(Vector2.RIGHT)
	elif randi() % 2 == 0:
		ret.append(Vector2.LEFT)
		ret.append(Vector2.RIGHT)
	else:
		ret.append(Vector2.RIGHT)
		ret.append(Vector2.LEFT)
	return ret

# 移动的首选和次选方向
# Y三线原则（优先进入敌主将的Y三轴）(原版弓兵)
# @return [dir], 依次尝试的行动方向
func get_move_directions_line3Y(unit:Battle_Unit, enemyLeaderPosition)->PoolVector2Array:
	var ret = []
	var xDiff = int(unit.unit_position.x - enemyLeaderPosition.x)
	var yDiff = int(unit.unit_position.y - enemyLeaderPosition.y)
	var inRange = abs(yDiff) <= 1
	var side = unit.get_side()

	if not inRange:
		# 在Y三线外
		# 优先垂直移动，即使撤退也要先进三线
		if yDiff > 0:
			ret.append(Vector2.UP)
		else:
			ret.append(Vector2.DOWN)
		# 若无法垂直移动，可以后退
		if unit.get_state() in ["后退"]:
			ret.append(side)
			return ret
		# 其他情况，向X三线靠拢
		if xDiff > 0:
			ret.append(Vector2.LEFT)
		elif xDiff < 0:
			ret.append(Vector2.RIGHT)
		elif randi() % 2 == 0:
			ret.append(Vector2.LEFT)
			ret.append(Vector2.RIGHT)
		else:
			ret.append(Vector2.RIGHT)
			ret.append(Vector2.LEFT)
		return ret

	# 在Y三线内
	# 可以直线撤退
	if unit.get_state() in ["后退"]:
		ret.append(side)
		# 若无法直接撤退，向Y三线靠拢
		if yDiff > 0:
			ret.append(Vector2.UP)
		elif yDiff < 0:
			ret.append(Vector2.DOWN)
		elif randi() % 2 == 0:
			ret.append(Vector2.UP)
			ret.append(Vector2.DOWN)
		else:
			ret.append(Vector2.UP)
			ret.append(Vector2.DOWN)
		return ret

	if xDiff == 0:
		# 已经同列，肯定无法垂直移动了
		if randi() % 2 == 0:
			ret.append(Vector2.LEFT)
			ret.append(Vector2.RIGHT)
		else:
			ret.append(Vector2.RIGHT)
			ret.append(Vector2.LEFT)
		return ret

	if xDiff + side.x == 0:
		# 特殊情况，已经绕到武将的侧后方，优先包抄后路
		ret.append(Vector2(0, -yDiff))
		# 无法包抄时，直接后退
		ret.append(side)
		return ret

	# 其他情况，水平移动优先
	if xDiff > 0:
		ret.append(Vector2.LEFT)
	else:
		ret.append(Vector2.RIGHT)
	# 无法水平移动时，向Y三线靠拢
	if yDiff > 0:
		ret.append(Vector2.UP)
	elif yDiff < 0:
		ret.append(Vector2.DOWN)
	elif randi() % 2 == 0:
		ret.append(Vector2.UP)
		ret.append(Vector2.DOWN)
	else:
		ret.append(Vector2.DOWN)
		ret.append(Vector2.UP)
	return ret
