extends Resource

#获取布阵
func _init() -> void:
	return

#切换阵型
func set_formation(actorId:int,formation:int):
	var scene_battle = SceneManager.current_scene();
	var unit_locations_set = StaticManager.get_formation_setting()
	var unit_locations = unit_locations_set[formation].duplicate(true);
	clear_formation(actorId);
	var index = 0;
	for unit in DataManager.battle_units:
		if(unit.leaderId!=actorId):
			continue;
		if unit.dic_combat["不布阵"]:
			continue;
		var location_dic = {"x":-1,"y":-1};
		if(index<unit_locations.size()):
			location_dic = unit_locations[index].duplicate(true);
		var position_x = int(location_dic["x"]);
		var position_y = int(location_dic["y"]);
		
		if(unit.get_side()==Vector2.RIGHT):
			#如果在右边，坐标镜像处理
			position_x = scene_battle.cell_columns-position_x-1;
			
		index+=1;
		unit.unit_position = Vector2(position_x,position_y);

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
	if actorId == bf.get_attacker_id():
		if bf.get_terrian() in ["walldoor","wall"]:
			#电脑攻城强制1或2阵
			return Global.get_random(0,1)
	else:
		match bf.get_terrian():
			"walldoor":#守城门，固定阵型4
				return 4
			"wallcity":#守太守府，固定阵型7
				return 7
	# 其他情况，随机阵型
	return Global.get_random(0,3)
