extends "effect_20000.gd"

#龙乡诱发技
#【龙乡】大战场，诱发技。己方其他武将执行了距离>1的位移效果时才能发动。你可指定1个空位位移至目标位置。

const EFFECT_ID = 20480
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20040()->bool:
	if me == null or me.disabled or not me.has_position():
		return false
	if me.get_controlNo() < 0:
		# 暂不支持 AI 发动
		return false
	var prevSkeData = DataManager.get_env_dict("战争.完成技能")
	if prevSkeData.empty():
		return false
	var prevSke = SkillEffectInfo.new()
	prevSke.input_data(prevSkeData)
	var triggered = false
	for r in prevSke.results:
		if r.type != "移动" or r.actorId < 0 or r.actorId == actorId:
			continue
		var wa = DataManager.get_war_actor(r.actorId)
		if wa == null or wa.disabled or not wa.has_position():
			continue
		if not me.is_teammate(wa):
			continue
		var from = Vector2(int((r.initial - r.initial % 100) / 100), r.initial % 100)
		var to = Vector2(int((r.change - r.change % 100) / 100), r.change % 100)
		if Global.get_distance(from, to) <= 1:
			continue
		triggered = true
		break
	return triggered

func effect_20480_start()->void:
	map.show_color_block_by_position([])
	map.cursor.show()
	var msg = "【{0}】发动\n请指定跃进地点".format([ske.skill_name])
	# 这一步目前是必要的，确保正确的技能范围定位
	get_skill_centers(me)
	map.clear_can_choose_actors()
	map.set_cursor_location(me.position, true)
	map.next_shrink_actors = [actorId]
	SceneManager.show_unconfirm_dialog(msg, actorId, 2)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_free_position(FLOW_BASE + "_2", false, "player_ready")
	return

func effect_20480_2()->void:
	var target = map.cursor_position
	var distance = Global.get_range_distance(me.position, target)
	var maxDistance = get_choose_distance()
	if distance > maxDistance:
		SceneManager.show_unconfirm_dialog("位移距离不能超过{0}".format([maxDistance]), me.actorId)
		LoadControl.set_view_model(2000)
		return
	var wa = DataManager.get_war_actor_by_position(target)
	if wa != null and not wa.disabled:
		SceneManager.show_unconfirm_dialog("必须选择空位", me.actorId)
		LoadControl.set_view_model(2000)
		return
	if map.get_blockCN_by_position(target) == "城墙":
		SceneManager.show_unconfirm_dialog("不能位移到城墙上", me.actorId)
		LoadControl.set_view_model(2000)
		return
	map.aStar.update_map_for_actor(me)
	var path = map.aStar.get_clear_path(me.position, target, maxDistance)
	if path.size() <= 1:
		map.show_color_block_by_position([])
		SceneManager.show_unconfirm_dialog("存在阻碍，不能位移到此处!", me.actorId)
		LoadControl.set_view_model(2000)
		return
	map.show_color_block_by_position(path, Color(0.0, 0.0, 0.8, 0.3))
	DataManager.set_env("龙乡目标", {"x":target.x, "y":target.y})
	var msg = "移动到指定位置（<{0},{1}>）\n可否？".format([target.x, target.y])
	play_dialog(me.actorId, msg, 2, 2001)
	return

func on_view_model_2001()->void:
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20480_3()->void:
	var target = DataManager.get_env_dict("龙乡目标")
	var pos = Vector2(int(target["x"]), int(target["y"]))
	ske.change_war_actor_position(actorId, pos)
	var msg = "我亦可往！"
	ske.war_report()
	play_dialog(actorId, msg, 0, 2002)
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation()
	return
