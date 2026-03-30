extends Resource

#获取布阵
func _init() -> void:
	return

#切换阵型
func set_formation(actorId:int, formation:int):
	var scene_battle = SceneManager.current_scene()
	var formationSetting = StaticManager.get_formation_setting(formation)
	clear_formation(actorId)
	var index = 0
	for unit in DataManager.battle_units:
		if unit.leaderId != actorId:
			continue
		if unit.dic_combat["不布阵"]:
			continue
		var location = [-1, -1]
		if index < formationSetting["positions"].size():
			location = formationSetting["positions"][index].duplicate()
		
		if unit.get_side() == Vector2.RIGHT:
			#如果在右边，坐标镜像处理
			location[0] = scene_battle.cell_columns - location[0] - 1

		index += 1
		unit.unit_position = Vector2(location[0], location[1])

	return

func clear_formation(actorId:int):
	for unit in DataManager.battle_units:
		if(unit.leaderId!=actorId):
			continue;
		if unit.dic_combat["不布阵"]:
			continue;
		unit.unit_position=Vector2(-1,-1)
	return

#随机选择阵型
func _get_random_auto_formation(actorId:int)->int:
	var bf = DataManager.get_current_battle_fight()
	var formations = bf.get_possible_formations(actorId)
	return formations[randi() % formations.size()]
