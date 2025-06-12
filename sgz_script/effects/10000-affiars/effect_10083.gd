extends "effect_10000.gd"

#屯田锁定技
#【屯田】内政，锁定技。结束阶段，若你所在城本月未开发过土地：自动提升X点土地值（X=40+你的等级*5）。

func on_trigger_10012() -> bool:
	if get_env_str("内政.命令") != "开发":
		return false
	var cmd = DataManager.get_current_develop_command()
	if cmd.type != "土地":
		return false
	# 禁用效果
	ske.affair_cd(1)
	return false

func on_trigger_10099() -> bool:
	ske.affair_cd(1)
	var cityId = get_working_city_id()
	if cityId < 0:
		return false
	var city = clCity.city(cityId)
	var val = 40 + actor.get_level() * 5
	val = city.add_city_property("土地", val)
	if val <= 0:
		return false
	if DataManager.get_scene_actor_control(actorId) >= 0:
		var msg = "且屯且战，军民两利\n{0}土地上升{1}，现为{2}".format([
			city.get_full_name(), val, city.get_land(),
		])
		city.attach_free_dialog(msg, actorId, 1)
	return false
