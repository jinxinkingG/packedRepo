extends AStar2D

var w:int
var h:int
var map
var blockById:Dictionary = {}
var blockCNById:Dictionary = {}
var idsByBlockCN:Dictionary = {}
var idsByBlock:Dictionary = {}

var currentWarActor = null
var currentTroopsType = "平"
var currentTroopsIndex = 0

var brothersByBlock:Dictionary = {}
var enemiesByBlock:Dictionary = {}
var enemiesDisabled:bool = false
var brothersDisabled:bool = false

func init_with_war_map(war_map):
	self.map = war_map
	self.w = war_map.cell_columns
	self.h = war_map.cell_rows - 1
	# 保留空间
	if get_point_count() < w * h:
		reserve_space(w * h)
	# 添加所有节点
	for y in range(h):
		for x in range(w):
			var pos = Vector2(x, y)
			var id = _get_rect_id(pos)
			# 注册地形
			self.register_block_data(id, war_map.map_data[id])
			self.add_point(id, pos)
			# 默认设定与左侧、上方节点的双向连接
			if x > 0:
				self.connect_points(id, id - 1, true)
			if y > 0:
				self.connect_points(id, id - w, true)

	return

func get_path(from:Vector2, to:Vector2)->PoolVector2Array:
	if not map.is_valid_position(from):
		return PoolVector2Array([])
	if not map.is_valid_position(to):
		return PoolVector2Array([])
	return get_point_path(_get_rect_id(from), _get_rect_id(to))

# 寻找无任何阻挡的路径
# 过程中暂时标注敌军单位为阻挡块
func get_clear_path(from:Vector2, to:Vector2, limitedDistance = -1)->PoolVector2Array:
	var disabledByDistance = []
	if limitedDistance > 0:
		for x in range(0, map.cell_columns):
			for y in range(0, map.cell_rows - 1):
				if max(abs(x - from.x), abs(y - from.y)) > limitedDistance:
					var id = _get_rect_id(Vector2(x, y))
					if self.is_point_disabled(id):
						continue
					self.set_point_disabled(id, true)
					disabledByDistance.append(id)
	# 禁用敌军节点，以绕过敌军单位
	disable_enemies()
	# 如果目标位置也被禁用了，需要解除
	set_point_disabled(_get_rect_id(to), false)
	var ret = get_path(from, to)
	# 解除禁用
	enable_enemies()
	for id in disabledByDistance:
		set_point_disabled(id, false)
	return ret

# 寻找技能可触及的路径
# 规则：城墙阻断、途中敌军阻断、队友不阻断
# 但不可通过强制禁用的位置
func get_skill_path(from:Vector2, to:Vector2, limitedDistance:int=-1)->PoolVector2Array:
	# 范围外禁用
	var disabledByDistance = []
	if limitedDistance > 0:
		for x in range(0, map.cell_columns):
			for y in range(0, map.cell_rows - 1):
				if max(abs(x - from.x), abs(y - from.y)) > limitedDistance:
					var id = _get_rect_id(Vector2(x, y))
					if self.is_point_disabled(id):
						continue
					self.set_point_disabled(id, true)
					disabledByDistance.append(id)
	# 非终点的敌军禁用
	var disabled = []
	for k in enemiesByBlock.keys():
		var id = int(k)
		var pos = _get_id_vector(id)
		if pos == to:
			continue
		disabled.append(int(k))
	for id in disabled:
		set_point_disabled(id, true)
	# 队友临时解禁
	enable_brothers()
	# 获取路径
	var ret = get_path(from, to)
	# 范围外解禁
	for id in disabledByDistance:
		set_point_disabled(id, false)
	# 解除临时禁用
	for id in disabled:
		set_point_disabled(id, false)
	# 队友恢复禁用
	disable_brothers()
	return ret

# 寻找攻击可触及的路径
# 规则：城墙阻断、途中敌军阻断、队友不阻断
# 但不可通过强制禁用的位置
func get_attack_path(from:Vector2, to:Vector2)->PoolVector2Array:
	# 非终点的敌军禁用
	var disabled = []
	for k in enemiesByBlock.keys():
		var id = int(k)
		var pos = _get_id_vector(id)
		if pos == to:
			continue
		disabled.append(int(k))
	for id in disabled:
		set_point_disabled(id, true)
	# 队友临时解禁
	enable_brothers()
	# 获取路径
	var ret = get_path(from, to)
	# 解除临时禁用
	for id in disabled:
		set_point_disabled(id, false)
	# 队友恢复禁用
	disable_brothers()
	return ret

# 寻找突击路径
# 规则：无视队友和敌军的阻挡
# 但不可通过强制禁用的位置
func get_assault_path(from:Vector2, to:Vector2)->PoolVector2Array:
	# 队友临时解禁
	enable_brothers()
	var ret = get_path(from, to)
	# 队友恢复禁用
	disable_brothers()
	return ret

func get_assault_path_with_weight(from:Vector2, to:Vector2)->Array:
	var ret = []
	var route = get_assault_path(from, to)
	for pos in route:
		var id = _get_rect_id(pos)
		var weight = int(round(get_point_weight_scale(id)))
		ret.append([pos, weight])
	return ret

func get_clear_path_with_weight(from:Vector2, to:Vector2, limitedDistance = -1)->Array:
	var ret = []
	var route = get_clear_path(from, to, limitedDistance)
	for pos in route:
		var id = _get_rect_id(pos)
		var weight = int(round(get_point_weight_scale(id)))
		ret.append([pos, weight])
	return ret

func get_path_with_weight(from:Vector2, to:Vector2)->Array:
	var ret = []
	var route = get_path(from, to)
	for pos in route:
		var id = _get_rect_id(pos)
		var weight = int(round(get_point_weight_scale(id)))
		ret.append([pos, weight])
	return ret

func _get_rect_id(pos:Vector2)->int:
	return int(pos.x) + int(pos.y) * w

func _get_id_vector(id:int)->Vector2:
	return Vector2(id % w, int(id / w))

func register_block_data(id:int, block_data:String):
	block_data = block_data.split("_")[0]
	var block_CN = StaticManager.BLOCKS_EN_CN[block_data]

	self.blockById[str(id)] = block_data
	self.blockCNById[str(id)] = block_CN

	if not self.idsByBlock.has(block_data):
		self.idsByBlock[block_data] = []
	self.idsByBlock[block_data].append(id)
	if not self.idsByBlockCN.has(block_CN):
		self.idsByBlockCN[block_CN] = []
	self.idsByBlockCN[block_CN].append(id)

func update_map_for_actor(me:War_Actor)->void:
	if not me.has_position():
		return
	currentWarActor = me
	currentTroopsType = me.actor().get_troops_type()
	currentTroopsIndex = 0
	if me.actor().get_soldiers() <= 500:
		currentTroopsIndex = 1
	var cur = blockById[str(_get_rect_id(me.position))]
	brothersByBlock = {}
	enemiesByBlock = {}

	# 遍历所有城墙
	if idsByBlockCN.has("城墙"):
		for id in idsByBlockCN["城墙"]:
			var pos = _get_id_vector(id)
			for dir in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
				var _id = str(_get_rect_id(pos + dir))
				if not blockCNById.has(_id):
					continue
				if not blockCNById[_id] in StaticManager.CITY_BLOCKS_CN:
					# 非城门、城墙地形，断开平地到城墙的单向连接
					# 仙兵种除外
					disconnect_points(int(_id), id, false)
					if currentTroopsType == "仙":
						connect_points(int(_id), id, false)
					elif me.side() == "防守方":
						if SkillRangeBuff.max_val_for_actor("逾墙", me.actorId) > 0:
							connect_points(int(_id), id, false)

	# 遍历所有节点，根据节点类型设置权重
	var costSetting = StaticManager.get_move_ap_setting()
	for key in blockCNById.keys():
		set_point_disabled(int(key), false)
		var blockCN = blockCNById[key]
		if not costSetting.has(blockCN):
			set_point_weight_scale(int(key), 100)
		else:
			set_point_weight_scale(int(key), costSetting[blockCN][currentTroopsType][currentTroopsIndex])

	# 根据双方位置更新权重
	var wf = DataManager.get_current_war_fight()
	for wa in wf.get_war_actors(false, true):
		if wa.actorId == me.actorId:
			# 别把自己堵上了
			continue
		var key = str(_get_rect_id(wa.position))
		if wa.is_enemy(me):
			self.enemiesByBlock[key] = wa
			self.set_point_weight_scale(int(key), 10)
		else:
			# 是队友
			self.brothersByBlock[key] = wa
			self.set_point_disabled(int(key), true)
	enemiesDisabled = false
	brothersDisabled = true
	return

func disable_enemies():
	for id in enemiesByBlock.keys():
		set_point_disabled(int(id), true)
	enemiesDisabled = true
	return

func enable_enemies():
	for id in enemiesByBlock.keys():
		if "强制禁用" in idsByBlockCN and int(id) in idsByBlockCN["强制禁用"]:
			continue
		set_point_disabled(int(id), false)
	enemiesDisabled = false
	return

func disable_brothers():
	for id in brothersByBlock.keys():
		set_point_disabled(int(id), true)
	brothersDisabled = true
	return

func enable_brothers():
	for id in brothersByBlock.keys():
		if "强制禁用" in idsByBlockCN and int(id) in idsByBlockCN["强制禁用"]:
			continue
		set_point_disabled(int(id), false)
	brothersDisabled = false
	return

func set_position_disabled(pos:Vector2)->void:
	if not "强制禁用" in idsByBlockCN:
		idsByBlockCN["强制禁用"] = []
	var id = _get_rect_id(pos)
	idsByBlockCN["强制禁用"].append(id)
	set_point_disabled(id, true)
	return
