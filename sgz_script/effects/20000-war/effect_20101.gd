extends "effect_20000.gd"

#闭月效果实现
#【闭月】大战场,锁定技。你不在城地形的场合，你方结束阶段，若你的相邻存在敌将，你朝远离敌将的方向随机移动1格。

func on_trigger_20016()->bool:
	var checkPositions = [me.position]
	for dir in StaticManager.NEARBY_DIRECTIONS:
		checkPositions.append(me.position + dir)
	var positionStatus = {}
	# 检查附近敌军
	for targetId in get_enemy_targets(me, true, 2):
		var wa = DataManager.get_war_actor(targetId)
		# 有部队
		for pos in checkPositions:
			if wa.position == pos:
				positionStatus[pos] = 10000 # 此处有部队，不可进入
				continue
			var block = map.get_blockCN_by_position(pos)
			if block == "城墙":
				positionStatus[pos] = 10000 # 此处是城墙，不可进入
				continue
			if Global.get_distance(wa.position, pos) == 1:
				# 如果我撤到这里，还是会有敌军，谨慎
				if not positionStatus.has(pos):
					positionStatus[pos] = 0
				positionStatus[pos] += 100
				continue

	if positionStatus.has(me.position):
		# 周围有敌军
		var minThreat = 10000
		var minThreatPos = me.position # 默认不走
		for dir in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
			var checkPos = me.position + dir
			if not me.can_move_to_position(checkPos):
				continue
			if not positionStatus.has(checkPos):
				# 这个方向既没有敌军，也没有敌军相邻
				minThreat = 0
				minThreatPos = checkPos
				break
			if positionStatus[checkPos] < minThreat:
				minThreat = positionStatus[checkPos]
				minThreatPos = checkPos
		# 去相对安全的地方
		if minThreatPos != me.position:
			me.position = minThreatPos
			me.attach_free_dialog("兵凶战危，闭月待时...", 2)
			return false

	return false
