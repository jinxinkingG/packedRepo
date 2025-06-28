extends Resource
const view_model_name = "单挑-玩家-步骤";

#撤退
func _init() -> void:
	LoadControl.view_model_name = view_model_name
	FlowManager.bind_import_flow("solo_retreat", self)
	FlowManager.bind_import_flow("solo_retreat_1", self)
	FlowManager.bind_import_flow("solo_retreat_2", self)
	FlowManager.bind_import_flow("solo_retreat_3_chase", self)
	FlowManager.bind_import_flow("solo_retreat_4_chase", self)
	FlowManager.bind_import_flow("solo_retreat_5_chase", self)
	FlowManager.bind_import_flow("solo_retreat_6", self)
	FlowManager.bind_import_flow("solo_retreat_6_trigger", self)
	return

func _input_key(delta: float):
	match LoadControl.get_view_model():
		110:#撤退
			Global.wait_for_confirmation("solo_retreat_1")
		112:#对方对白
			Global.wait_for_confirmation("solo_retreat_6")
		114:#追击掉血
			Global.wait_for_confirmation("solo_retreat_5_chase")
		116:#不追击：确认已经逃掉了
			Global.wait_for_confirmation("solo_retreat_6_trigger")
	return

#撤退
func solo_retreat():
	LoadControl.set_view_model(110)
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no]
	var actorId = DataManager.solo_actor_by_side(side)
	SceneManager.dialog_msg_complete(true)
	SceneManager.show_confirm_dialog("下次再分胜负", actorId)
	return

#撤退：播放动画
func solo_retreat_1():
	LoadControl.set_view_model(111)
	var scene_solo = SceneManager.current_scene();
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no];
	var actorId = DataManager.solo_actor_by_side(side);
	var node = scene_solo.get_actor_node(actorId);
	var bf = DataManager.get_current_battle_fight()
	SceneManager.show_unconfirm_dialog(" ")

	var enemyId = bf.get_attacker_id()
	if actorId == enemyId:
		enemyId = bf.get_defender_id()
	bf.set_unit_state(actorId, {"将": "后退"})
	if bf.get_units_state(enemyId, "将") == "后退":
		bf.set_unit_state(enemyId, {"将": "待机"})

	node.action_retreat("solo_retreat_2")
	return

#撤退追击：对白
func solo_retreat_2():
	LoadControl.set_view_model(112);
	var scene_solo = SceneManager.current_scene();
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no];
	var actorId = DataManager.solo_actor_by_side(side);
	var node = scene_solo.get_actor_node(actorId);
	var enemy_node = node.get_enemy_actor_node();
	SceneManager.show_confirm_dialog("无耻之徒！休走！",enemy_node.actorId,0);
	
#撤退追击：动画
func solo_retreat_3_chase():
	LoadControl.set_view_model(113);
	var scene_solo = SceneManager.current_scene();
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no];
	var actorId = DataManager.solo_actor_by_side(side);
	var node = scene_solo.get_actor_node(actorId);
	var enemy_node = node.get_enemy_actor_node();
	SceneManager.show_unconfirm_dialog(" ");
	enemy_node.action_chase("solo_retreat_4_chase");
	
#撤退追击：扣血
func solo_retreat_4_chase():
	LoadControl.set_view_model(114);
	var scene_solo = SceneManager.current_scene();
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no];
	var actorId = DataManager.solo_actor_by_side(side);
	var actor = ActorHelper.actor(actorId)
	var node = scene_solo.get_actor_node(actorId);
	var enemy_node = node.get_enemy_actor_node();
	var self_damage = Global.get_random(0,9)+5;
	DataManager.set_env("单挑.伤害数值", self_damage)
	var msg = "{0}于被追击之时\n受到{1}点伤害".format([actor.get_name(), self_damage])
	SceneManager.show_confirm_dialog(msg);

func solo_retreat_5_chase():
	LoadControl.set_view_model(115)
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no]
	var actorId = DataManager.solo_actor_by_side(side)
	var actor = ActorHelper.actor(actorId)
	var wa = DataManager.get_war_actor(actorId)
	var enemy = wa.get_battle_enemy_war_actor()
	var self_damage = DataManager.get_env_int("单挑.伤害数值")
	actor.set_hp(actor.get_hp() - self_damage)
	if actor.get_hp() <= 0:
		var msg = wa.actor_capture_to(enemy.wvId, "单挑", enemy.actorId)
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("solo_say_dead_2")
		return;
	SkillHelper.auto_trigger_skill(actorId, 40006, "")
	LoadControl.set_view_model(-1)
	FlowManager.add_flow("solo_run_end")
	return

#撤退不追击：对白
func solo_retreat_6():
	if Global.get_rate_result(50):
		FlowManager.add_flow("solo_retreat_3_chase")
		return
	LoadControl.set_view_model(116);
	var scene_solo = SceneManager.current_scene();
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no];
	var actorId = DataManager.solo_actor_by_side(side);
	var node = scene_solo.get_actor_node(actorId);
	var enemy_node = node.get_enemy_actor_node();
	SceneManager.show_confirm_dialog("跑得倒是挺快!",enemy_node.actorId,0);

func solo_retreat_6_trigger():
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no]
	var actorId = DataManager.solo_actor_by_side(side)
	SkillHelper.auto_trigger_skill(actorId, 40006, "")
	FlowManager.add_flow("solo_run_end")
	return
