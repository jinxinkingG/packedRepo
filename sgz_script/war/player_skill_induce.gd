extends "war_base.gd"

#诱发效果提示处

func _init() -> void:
	FlowManager.bind_import_flow("induce_start",self,"induce_start");
	FlowManager.bind_import_flow("induce_ready",self,"induce_ready");
	FlowManager.bind_import_flow("induce_player_ask",self,"induce_player_ask");
	FlowManager.bind_import_flow("induce_player_choose",self,"induce_player_choose")
	FlowManager.bind_import_flow("induce_player_effect",self,"induce_player_effect")
	FlowManager.bind_import_flow("induce_AI_choose",self,"induce_AI_choose")
	return

#按键操控
func _input_key(delta: float):
	var scene_war:Control = SceneManager.current_scene();
	var war_map = scene_war.war_map;
	var bottom = SceneManager.lsc_menu;
	var top = SceneManager.lsc_menu_top;
	var view_model = LoadControl.get_view_model();
	var actorId = int(DataManager.player_choose_actor);
	match view_model:
		602:
			if Input.is_action_just_pressed("ANALOG_LEFT"):
				SceneManager.actor_dialog.move_left()
			if Input.is_action_just_pressed("ANALOG_RIGHT"):
				SceneManager.actor_dialog.move_right()
			if Input.is_action_just_pressed("ANALOG_UP"):
				SceneManager.actor_dialog.move_up()
			if Input.is_action_just_pressed("ANALOG_DOWN"):
				SceneManager.actor_dialog.move_down()
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				var curindex = int(SceneManager.actor_dialog.lsc.cursor_index)
				DataManager.set_env("战争.诱发选择", curindex)
				match curindex:
					0:
						FlowManager.add_flow("induce_player_choose");
					1:
						FlowManager.add_flow("induce_ready");
#		603:
#			var array = PoolIntArray(DataManager.common_variable["可选目标"]);
#			var current = int(DataManager.common_variable["诱发武将"]);#目标
#			var index = array.find(current);
#			if(Input.is_action_just_pressed("ANALOG_UP")):
#				index = ActorHelper.find_next_war_actor(array, index, Vector2.UP)
#				if(array[index]==current):
#					return;
#				var war_actor = DataManager.get_war_actor(array[index]);
#				war_map.set_cursor_location(war_actor.position,true);
#				DataManager.common_variable["诱发武将"] = array[index];
#				SceneManager.show_actor_info(war_actor.actorId,false);
#				war_map.next_shrink_actors = [war_actor.actorId];
#
#			if(Input.is_action_just_pressed("ANALOG_DOWN")):
#				index = ActorHelper.find_next_war_actor(array, index, Vector2.DOWN)
#				if(array[index]==current):
#					return;
#				var war_actor = DataManager.get_war_actor(array[index]);
#				war_map.set_cursor_location(war_actor.position,true);
#				DataManager.common_variable["诱发武将"] = array[index];
#				SceneManager.show_actor_info(war_actor.actorId,false);
#				war_map.next_shrink_actors = [war_actor.actorId];
#
#			if(Input.is_action_just_pressed("ANALOG_LEFT")):
#				index = ActorHelper.find_next_war_actor(array, index, Vector2.LEFT)
#				if(array[index]==current):
#					return;
#				var war_actor = DataManager.get_war_actor(array[index]);
#				war_map.set_cursor_location(war_actor.position,true);
#				DataManager.common_variable["诱发武将"] = array[index];
#				SceneManager.show_actor_info(war_actor.actorId,false);
#				war_map.next_shrink_actors = [war_actor.actorId];
#
#			if(Input.is_action_just_pressed("ANALOG_RIGHT")):
#				index = ActorHelper.find_next_war_actor(array, index, Vector2.RIGHT)
#				if(array[index]==current):
#					return;
#				var war_actor = DataManager.get_war_actor(array[index]);
#				war_map.set_cursor_location(war_actor.position,true);
#				DataManager.common_variable["诱发武将"] = array[index];
#				SceneManager.show_actor_info(war_actor.actorId,false);
#				war_map.next_shrink_actors = [war_actor.actorId];
#
#			if(Global.is_action_pressed_AX()):
#				if(!SceneManager.actor_info.is_msg_complete()):
#					SceneManager.actor_info.show_all_msg();
#					return;
#				var skill_actorId = int(array[index]);
#				DataManager.common_variable["诱发武将"]=skill_actorId;
#				var current_controlNo = int(DataManager.common_variable["诱发控制"]);
#				var player_effect:Dictionary = DataManager.common_variable["诱发分组-效果"];
#				var induce_effects:Array = player_effect[str(current_controlNo)];
#				for dic in induce_effects:
#					var _skill_actorId = int(dic["skill_actor"])
#					if(skill_actorId == _skill_actorId):
#						print(DataManager.common_variable["诱发武将"]);
#						FlowManager.add_flow("induce_player_effect");
#						break;
#			if(Global.is_action_pressed_BY()):
#				if(!SceneManager.actor_info.is_msg_complete()):
#					return;
#				FlowManager.add_flow("induce_player_ask");
		607:
			var ret = Global.wait_for_choose_skill("", "induce_player_ask")
			var lsc = SceneManager.lsc_menu_top.lsc
			var options = DataManager.get_env_array("列表值")
			if lsc.cursor_index >= 0 and lsc.cursor_index < options.size():
				var current = options[lsc.cursor_index]
				var currentActorId = Global.dic_val(current, "skill_actorId", -1)
				if currentActorId >= 0:
					SceneManager.show_simply_actor_info(currentActorId, "", true)
			if not ret:
				return
			var selected = DataManager.get_env_dict("目标项")
			var skill = Global.strval(selected["skill_name"])
			var targetId = Global.intval(selected["skill_actorId"])
			if skill == "" or targetId < 0:
				return
			DataManager.set_env("战争.玩家选定诱发技", skill)
			DataManager.set_env("诱发武将", targetId)
			FlowManager.add_flow("induce_player_effect")
		699: # 特殊对话确认，目前由天威驱动
			if not Global.is_action_pressed_AX():
				return
			if not SceneManager.dialog_msg_complete(true):
				return
			LoadControl.end_script()
	return

func induce_start():
	LoadControl.set_view_model(600);
	var st_info = SkillHelper.get_current_skill_trigger();
	var induce_effects = Array(st_info.induce_effects);
	if(induce_effects.empty()):
		st_info.wait = false;
		return;
	SceneManager.hide_all_tool();
	print("诱发技触发开始----");
	var player_effect ={};
	var player_controls = [];
	for dic in induce_effects:
		var skill_actorId = int(dic["skill_actor"]);
		var war_actor = DataManager.get_war_actor(skill_actorId);
		var controlNo:int = war_actor.get_controlNo();
		var key = str(controlNo);
		if !player_effect.has(key):
			player_effect[key] = [];
			player_controls.append(controlNo);
		player_effect[key].append(dic);
	player_controls.sort();
	DataManager.common_variable["诱发控制分组"]=player_controls;
	DataManager.common_variable["诱发分组-效果"]=player_effect;
	FlowManager.add_flow("induce_ready");


func induce_ready():
	LoadControl.set_view_model(601);
	var map = SceneManager.current_scene().war_map
	map.cursor.hide()
	map.clear_can_choose_actors()
	map.show_color_block_by_position([])
	var st_info = SkillHelper.get_current_skill_trigger();
	var induce_effects = Array(st_info.induce_effects);
	DataManager.common_variable.erase("战争.玩家选定诱发技");
	var player_control = Array(DataManager.common_variable["诱发控制分组"]);
	var player_effect:Dictionary = DataManager.common_variable["诱发分组-效果"];
	if player_control.empty():
		st_info.wait = false
		st_info.induce_effects.clear()
		return
	var current_controlNo = player_control.pop_front();
	DataManager.common_variable["诱发控制"]=current_controlNo;
	if current_controlNo >= 0:
		FlowManager.add_flow("induce_player_ask");
	else:
		#AI暂时发动诱发技
		FlowManager.add_flow("induce_AI_choose");
	return

func induce_player_ask():
	LoadControl.set_view_model(602);
	var current_controlNo = DataManager.get_env_int("诱发控制")
	var player_effect:Dictionary = DataManager.get_env_dict("诱发分组-效果")
	var induce_effects:Array = player_effect[str(current_controlNo)];
	var st_info = SkillHelper.get_current_skill_trigger();
	var msg = st_info.induce_dialog;
	if msg != "":
		msg += "\n"
	msg += "是否发动诱发技能？"
	SceneManager.show_yn_dialog(msg)
	var lastOption = DataManager.get_env_int("战争.诱发选择")
	lastOption = max(0, lastOption)
	lastOption = min(1, lastOption)
	SceneManager.actor_dialog.lsc.set_cursor(lastOption)
	return

#func induce_player_choose_1():
#	LoadControl.set_view_model(603);
#	var current_controlNo = int(DataManager.common_variable["诱发控制"]);
#	var player_effect:Dictionary = DataManager.common_variable["诱发分组-效果"];
#	var induce_effects:Array = player_effect[str(current_controlNo)];
#
#	var array = [];#目标列表
#	for dic in induce_effects:
#		var skill_actorId = int(dic["skill_actor"])
#		if(!array.has(skill_actorId)):
#			array.append(skill_actorId);
#	if array.empty():
#		FlowManager.add_flow("induce_ready");
#		return;
#	wait_choose_actors(array,"发动何人之 诱发技能?");

func induce_AI_choose():
	LoadControl.set_view_model(-1);
	var current_controlNo = int(DataManager.common_variable["诱发控制"]);
	var player_effect:Dictionary = DataManager.common_variable["诱发分组-效果"];
	var induce_effects:Array = player_effect[str(current_controlNo)];
	
	var array = [];#目标列表
	for dic in induce_effects:
		var skill_actorId = int(dic["skill_actor"])
		if(!array.has(skill_actorId)):
			array.append(skill_actorId);
	if array.empty():
		FlowManager.add_flow("induce_ready");
		return;
	array.shuffle();
	
	set_env("诱发武将", array[0])
	FlowManager.add_flow("induce_player_effect");

# 诱发技发动
func induce_player_effect():
	LoadControl.set_view_model(604);
	var st_info = SkillHelper.get_current_skill_trigger();
	var current_controlNo = int(DataManager.common_variable["诱发控制"]);
	var player_effect:Dictionary = DataManager.common_variable["诱发分组-效果"];
	var effect_name = "";
	if DataManager.common_variable.has("战争.玩家选定诱发技"):
		effect_name = DataManager.common_variable["战争.玩家选定诱发技"];
	var induce_effects:Array = player_effect[str(current_controlNo)];
	var dic = {};
	for _dic in induce_effects:
		var _skill_actorId = int(_dic["skill_actor"])
		if(int(DataManager.common_variable["诱发武将"]) != _skill_actorId):
			continue;
		if(effect_name!="" && effect_name!=_dic["skill_name"]):
			continue;
		dic = _dic;
		break;
	var scene_id = DataManager.get_current_scene_id()
	# 加入特殊技能「天威」的判断
	if scene_id >= 20000:
		var wf = DataManager.get_current_war_fight()
		for wa in wf.get_war_actors(false):
			if SkillHelper.actor_has_skills(wa.actorId, ["天威"]):
				induce_emperor_power(int(dic["skill_actor"]), wa.actorId, st_info)
				return
	var ske = SkillEffectInfo.new();
	ske.actorId = int(dic["current_actor"]);
	ske.effect_Id = int(dic["effect_id"]);
	ske.trigger_Id = int(dic["triggerId"]);
	ske.effect_type = "诱发"
	ske.skill_name = dic["skill_name"];
	ske.skill_actorId = int(dic["skill_actor"])

	var path = ske.skill_effect_path()
	if path == "":
		FlowManager.add_flow("induce_ready")
		return
	SkillHelper.save_skill_effectinfo(ske)
	st_info.induce_effects.clear();
	var effect_method = "effect_{0}_start".format([ske.effect_Id])
	var gd = Global.load_script(path)
	if DataManager.get_scene_actor_control(ske.skill_actorId)<0:
		induce_effects.pop_front();
		player_effect[str(current_controlNo)] = induce_effects;
		DataManager.common_variable["诱发分组-效果"] = player_effect;
		effect_method = "effect_{0}_AI_start".format([ske.effect_Id]);
	
	if gd.has_method(effect_method):
		DataManager.player_choose_skill = ske.skill_name
		SceneManager.hide_all_tool()
		# 此处检查一次性技能并移除之
		SkillHelper.check_and_remove_once_skill(ske)
		# 触发诱发技的回调，不支持 flow，推荐行为是仅记录
		DataManager.set_env("战争.诱发技能", ske.output_data())
		SkillHelper.auto_trigger_skill(ske.skill_actorId, 20041)
		DataManager.unset_env("战争.诱发技能")
		# 恢复 ske 现场
		SkillHelper.save_skill_effectinfo(ske)
		LoadControl.load_script(path)
		FlowManager.add_flow(effect_method)
	else:
		FlowManager.add_flow("induce_ready")
	return

#选择目标时都用此方法
func wait_choose_actors(array:PoolIntArray,msg):
	var scene_war = SceneManager.current_scene();
	var war_map = scene_war.war_map;
	war_map.cursor.show();
	DataManager.common_variable["可选目标"] = array;
	var war_actor = DataManager.get_war_actor(array[0]);
	war_map.set_cursor_location(war_actor.position,true);
	DataManager.common_variable["诱发武将"] = array[0];
	war_map.show_can_choose_actors(array);#大地图显示可选目标
	SceneManager.show_actor_info(war_actor.actorId,true,msg);
	war_map.next_shrink_actors = [array[0]];

func induce_player_choose():
	var show_array = [];
	var value_array = [];
	
	var current_controlNo = int(DataManager.common_variable["诱发控制"]);
	var player_effect:Dictionary = DataManager.common_variable["诱发分组-效果"];
	var induce_effects:Array = player_effect[str(current_controlNo)];
	var dic = {}
	var wf = DataManager.get_current_war_fight()
	for _dic in induce_effects:
		var _skill_actorId = int(_dic["skill_actor"])
		var skill_name = _dic["skill_name"]
		var wa = DataManager.get_war_actor(_skill_actorId)
		var k = "-"
		var v = 0
		var skill = StaticManager.get_skill(skill_name)
		var effect = skill.get_effect(int(_dic["effect_id"]))
		var msg = effect.get_war_status(wf, wa.actorId)[1]
		var text = "{0} [{1}]".format([
			skill_name, wa.actor().get_name()
		])
		if msg != "":
			text += "  （{0}）".format([msg])
		show_array.append(text)
		value_array.append({"skill_actorId":_skill_actorId,"skill_name":skill_name});
	
	SceneManager.lsc_menu_top.set_lsc()
	SceneManager.lsc_menu_top.lsc.columns = 1;
	SceneManager.lsc_menu_top.lsc.items = show_array;
	SceneManager.lsc_menu_top.lsc._set_data();
	if value_array.empty():
		SceneManager.show_unconfirm_dialog("没有可以发动的诱发技")
	else:
		var p:Player = DataManager.players[int(FlowManager.controlNo)];
		var p_actor = ActorHelper.actor(p.actorId)
		var msg = "{0}大人，发动何人之诱发技?".format([p_actor.get_name()])
		SceneManager.show_simply_actor_info(value_array[0]["skill_actorId"], msg, true)
	SceneManager.lsc_menu_top.show();
	DataManager.set_env("列表值", value_array)
	LoadControl.set_view_model(607)
	return

# 天威覆盖诱发技效果
func induce_emperor_power(targetId:int, fromId:int, st:SkillTriggerInfo):
	st.induce_effects.clear()
	var msg = "因{0}【天威】效果\n诱发技失效".format([
		ActorHelper.actor(fromId).get_name()
	])
	var target = ActorHelper.actor(targetId)
	if target.is_injured():
		target.recover_hp(10)
		msg += "\n{0}体力恢复至{1}".format([
			target.get_name(), target.get_hp()
		])
	SceneManager.show_confirm_dialog(msg)
	LoadControl.set_view_model(699)
	return
