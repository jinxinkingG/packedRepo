extends Resource
const view_model_name = "单挑-玩家-步骤";

#牵制攻击
func _init() -> void:
	LoadControl.view_model_name = view_model_name;
	FlowManager.bind_import_flow("solo_light_attack",self,"solo_light_attack");

func _input_key(delta: float):
	var scene_solo:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var view_model = LoadControl.get_view_model();
	match view_model:
		100:
			pass


#牵制
func solo_light_attack():
	var scene_solo = SceneManager.current_scene()
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no]
	var actorId = DataManager.solo_actor_by_side(side)
	var actor = ActorHelper.actor(actorId)
	var actor_name = actor.get_name()
	var node = scene_solo.get_actor_node(actorId)

	var wa = DataManager.get_war_actor(actorId)
	var rate = 100
	DataManager.set_env("单挑.是否命中", 1)
	if not Global.get_rate_result(rate):
		DataManager.set_env("单挑.是否命中", 0)
	var baseDamage = wa.get_solo_base_damege()
	var damage = int(baseDamage/3)
	DataManager.set_env("单挑.伤害数值", damage)
	# 在 get_solo_base_damage 时计算
	var criticalChance = DataManager.get_env_int("单挑.暴击率")
	DataManager.set_env("单挑.反伤", 0)

	SceneManager.show_unconfirm_dialog("{0}之牵制攻击\n命中率：{1}%\n暴击率：{2}%".format([
		wa.get_name(), rate, criticalChance,
	]))
	SceneManager.dialog_msg_complete(true)
	node.action_light_attack("solo_before_say_hurt")
	LoadControl.set_view_model(100)
	return
