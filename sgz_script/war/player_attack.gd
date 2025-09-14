extends Resource

var iwa;


#武将攻击
func _init() -> void:
	iwa = Global.load_script(DataManager.mod_path+"sgz_script/war/IWar_Attack.gd")
	LoadControl.view_model_name = "战争-玩家-步骤"
	FlowManager.bind_signal_method("attack_anyway", self)
	FlowManager.bind_signal_method("attack_start", self)
	FlowManager.bind_signal_method("before_battle_1", self)
	FlowManager.bind_signal_method("before_battle_2", self)
	FlowManager.bind_signal_method("run_battle", self)

	FlowManager.bind_import_flow("attack_cancelled", self)
	return

#按键操控
func _input_key(delta: float):
	var scene_war:Control = SceneManager.current_scene();
	var war_map = scene_war.war_map;
	var bottom = SceneManager.lsc_menu;
	var bf = DataManager.get_current_battle_fight()
	match LoadControl.get_view_model():
		121:#攻击
			var array = PoolIntArray(DataManager.common_variable["可选目标"]);
			var current = int(DataManager.common_variable["武将"]);
			var index = array.find(current);
			var war_actor = DataManager.get_war_actor(array[index]);
			war_map.set_cursor_location(war_actor.position,true);
			SceneManager.show_actor_info(war_actor.actorId,false);
			war_map.next_shrink_actors = [war_actor.actorId];
			if(Input.is_action_just_pressed("ANALOG_UP")):
				index = ActorHelper.find_next_war_actor(array, index, Vector2.UP)
				if(array[index]==current):
					return;
				DataManager.common_variable["武将"] = array[index];

			if(Input.is_action_just_pressed("ANALOG_DOWN")):
				index = ActorHelper.find_next_war_actor(array, index, Vector2.DOWN)
				if(array[index]==current):
					return;
				DataManager.common_variable["武将"] = array[index];

			if(Input.is_action_just_pressed("ANALOG_LEFT")):
				index = ActorHelper.find_next_war_actor(array, index, Vector2.LEFT)
				if(array[index]==current):
					return;
				DataManager.common_variable["武将"] = array[index];

			if(Input.is_action_just_pressed("ANALOG_RIGHT")):
				index = ActorHelper.find_next_war_actor(array, index, Vector2.RIGHT)
				if(array[index]==current):
					return;
				DataManager.common_variable["武将"] = array[index];

			if(Global.is_action_pressed_AX()):
				if(!SceneManager.actor_info.is_msg_complete()):
					SceneManager.actor_info.show_all_msg();
					return;
				var cost_ap = iwa.get_attack_ap(DataManager.player_choose_actor,current);
				var war_from = DataManager.get_war_actor(DataManager.player_choose_actor);
				if(war_from.action_point<cost_ap):
					LoadControl._error("机动力不足",DataManager.player_choose_actor,3);
					return;
				#进入白兵战
				SkillHelper.remove_all_skill_trigger();
				_go_to_battle();
			if(Global.is_action_pressed_BY()):
				if(!SceneManager.actor_info.is_msg_complete()):
					return;
				FlowManager.add_flow("player_ready");
	return

func attack_anyway() -> void:
	attack_start(true)
	return

func attack_start(evenForbidden:bool=false):
	var map = SceneManager.current_scene().war_map
	var me = DataManager.get_war_actor(DataManager.player_choose_actor)
	var res = iwa.get_can_attack_actors(me.actorId, false, evenForbidden)
	var targets = res[0]
	var reason = res[1]
	if targets.empty():
		map.cursor.hide();
		LoadControl._error(reason, me.actorId)
		return
	# 显示攻击范围的逻辑暂不成熟
	# 比如旋风等技能机制未包括进来
	# 涉险等技能机制暂时无法体现
	# TODO 未来再考虑
	if false:
		var rng = me.get_attack_distance()
		if rng > 1:
			map.draw_outline_by_range(me.position, rng, map.GRID_COLOR, false, false)
	map.cursor.show()
	DataManager.set_env("可选目标", targets)
	var wa = DataManager.get_war_actor(targets[0])
	map.set_cursor_location(wa.position, true)
	DataManager.set_env("武将", wa.actorId)
	map.show_can_choose_actors(targets)
	var msg = "攻击敌方哪支部队？";
	SceneManager.show_actor_info(wa.actorId, true, msg)
	map.next_shrink_actors = [wa.actorId]
	LoadControl.set_view_model(121)
	return

# 发起白刃战
# @param callAttack: 攻击宣言参数，false表示没有攻击宣言直接白兵战，默认true。
# @param source: 攻击来源，通常是技能，默认空
# @param autoFinishTurn：战斗结束后是否自动结束回合，通常配合技能
func _go_to_battle(callAttack:bool=true, source:String="", autoFinishTurn:bool=false)->void:
	LoadControl.set_view_model(-1)
	LoadControl.end_script()

	var fromId = DataManager.player_choose_actor
	var targetId = DataManager.get_env_int("武将")
	var bf = DataManager.get_current_battle_fight()
	# 如果还没汇报，补充汇报
	bf.war_report()
	bf = DataManager.new_battle_fight(fromId)
	if autoFinishTurn:
		bf.mark_auto_finish_turn()
	var forcedTerrian = DataManager.get_env_str("战斗.强制地形")
	if forcedTerrian != "":
		bf.terrian = forcedTerrian
	DataManager.unset_env("战斗.强制地形")
	bf.set_target(targetId)
	bf.source = source

	_init()
	if callAttack:
		bf.cost_ap()
		FlowManager.add_flow("before_battle_1")
	else:
		FlowManager.add_flow("run_battle")
	return

#先攻方诱发
func before_battle_1():
	LoadControl.set_view_model(-1)
	var bf = DataManager.get_current_battle_fight()
	var msg = "{0}对{1}发起攻击".format([
		bf.get_from().get_name(), bf.get_target().get_name()
	])
	# 触发攻方技能
	if SkillHelper.auto_trigger_skill(bf.fromId, 20015, "before_battle_2", msg):
		return
	# 守方「缩地」判断
	var attacker = bf.get_attacker()
	var target = bf.get_target()
	if Global.get_distance(attacker.position, target.position) == 1:
		var suodiLimit = target.actor().get_equip_feature_max("大战场缩地")
		var suodiTimes = Global.intval(target.get_tmp_variable("大战场缩地", 0))
		if suodiLimit > suodiTimes:
			var map = SceneManager.current_scene().war_map
			target.set_tmp_variable("大战场缩地", suodiTimes + 1)
			var moved = false
			var terrian = map.get_blockCN_by_position(attacker.position)
			if not terrian in StaticManager.CITY_BLOCKS_CN:
				var directions = StaticManager.NEARBY_DIRECTIONS.duplicate(true)
				directions.erase(target.position - attacker.position)
				directions.erase(attacker.position - target.position)
				directions.insert(0, attacker.position - target.position)
				for dir in directions:
					var pos = attacker.position + dir
					if not attacker.can_move_to_position(pos):
						continue
					terrian = map.get_blockCN_by_position(pos)
					if terrian in StaticManager.CITY_BLOCKS_CN:
						continue
					attacker.position = pos
					map.draw_actors()
					moved = true
					break
			# 暂时固定认为来源是坐骑
			var source = target.actor().get_steed().name()
			var avoidMessage = "何以追之不及？！\n（{0}「{1}」规避攻击".format([
				target.get_name(), source
			])
			if moved:
				avoidMessage += "\n（{0}被摈退".format([
					attacker.get_name()
				])
			attacker.attach_free_dialog(avoidMessage, 0)
			bf.skip_execution(target.actorId, source)
			FlowManager.add_flow("attack_cancelled")
			return
	# 守方「避免白刃战」判断
	# 士兵为零直接击败
	if target.actor().get_soldiers() == 0:
		if target.actor().get_equip_feature_max("避免白刃战") > 0:
			# 暂时固定认为来源是坐骑
			var source = target.actor().get_steed().name()
			target.actor_capture_to(attacker.wvId, "白兵", attacker.actorId)
			var lastMsg = "气数已尽 …"
			var defeatMsg = "{0}技穷矣！".format([target.get_name()])
			if target.actor().is_status_dead():
				defeatMsg += "\n已阵斩之！"
			else:
				defeatMsg += "\n已生擒之！"
			attacker.attach_free_dialog(lastMsg, 3, 20000, target.actorId)
			attacker.attach_free_dialog(defeatMsg, 1)
			bf.skip_execution(target.actorId, source)
			FlowManager.add_flow("attack_cancelled")
			return
	# 攻方不诱发就触发守方
	if SkillHelper.auto_trigger_skill(bf.targetId, 20015, "run_battle", msg):
		return
	FlowManager.add_flow("run_battle")
	return

#再被攻击方诱发
func before_battle_2():
	LoadControl.set_view_model(-1);
	var bf = DataManager.get_current_battle_fight()
	var msg = "{0}对{1}发起攻击".format([
		bf.get_from().get_name(), bf.get_target().get_name()
	])
	if SkillHelper.auto_trigger_skill(bf.targetId, 20015, "run_battle", msg):
		return
	FlowManager.add_flow("run_battle")
	return

func run_battle():
	var bf = DataManager.get_current_battle_fight()
	for wa in [bf.get_from(), bf.get_target(), bf.get_attacker(), bf.get_defender()]:
		if not wa.wait_dialogs.empty():
			var d = wa.wait_dialogs.pop_front()
			DataManager.set_env("战争.玩家.等待对白", d.output())
			DataManager.set_env("战争.玩家.等待对白来源", wa.actorId)
			FlowManager.add_flow("player_turn_dialog|run_battle")
			return
	var wf = DataManager.get_current_war_fight()
	wf.battle_start()
	var attacker = bf.get_attacker()
	var defender = bf.get_defender()
	# 相互记录攻防对象，技能判断可用
	attacker.add_day_attacked_actor(defender.actorId)
	defender.add_day_defended_actor(attacker.actorId)

	DataManager.battle_run = true;
	SkillHelper.remove_all_skill_trigger();
	
	SceneManager.hide_all_tool();
	LoadControl.end_script();
	DataManager.battle_units = [];
	DataManager.battle_actors = [];
	FlowManager.add_flow("go_to_scene|res://scene/scene_battle/scene_battle.tscn");
	FlowManager.add_flow("battle_run_start");
	return

func attack_cancelled():
	DataManager.battle_units = []
	DataManager.battle_actors = []
	LoadControl.end_script()
	FlowManager.add_flow("player_ready")
	return
