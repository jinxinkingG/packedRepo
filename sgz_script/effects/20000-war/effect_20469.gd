extends "effect_20000.gd"

#翊赞主动技，突进技能
#【翊赞】大战场，主动技。你可从自己的计策列表选择一个未禁用的计策发动。将之永久禁用，之后你可选择一个X格内的空位，位移至目标位置。每2回合限1次。（X为所选计策的机动力值，但最大取5）

const EFFECT_ID = 20469
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20469_start():
	var items = []
	for scheme in me.get_stratagems():
		items.append("{0}({1})".format([scheme.name, scheme.get_cost_ap(actorId)]))
	if items.empty():
		var msg = "已无可禁用的计策"
		play_dialog(actorId, msg, 3, 2999)
		return
	var msg = "选择一个计策禁用\n以发动【{0}】".format([
		ske.skill_name,
	])
	SceneManager.show_unconfirm_dialog(msg, actorId, 2)
	bind_menu_items(items, items, 2)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_item(FLOW_BASE + "_2")
	return

func effect_20469_2():
	var item = DataManager.get_env_str("目标项")
	var schemeName = item.split("(")[0]
	var ap = int(item.split("(")[1].replace(")", ""))
	var rng = min(ap, 5)
	DataManager.set_env("翊赞范围", rng)
	map.show_color_block_by_position([])
	map.cursor.show()
	map.clear_can_choose_actors()
	var msg = "请指定{0}目标地点\n可在{1}格内移动".format([
		ske.skill_name, rng,
	])
	# 这一步目前是必要的，确保正确的技能范围定位
	get_skill_centers(me)
	play_dialog(actorId, msg, 2, 2001)
	return

func on_view_model_2001():
	var rng = DataManager.get_env_int("翊赞范围", 5)
	wait_for_free_position(FLOW_BASE + "_3", true, "", rng)
	return

func effect_20469_3():
	var item = DataManager.get_env_str("目标项")
	var schemeName = item.split("(")[0]
	var ap = int(item.split("(")[1].replace(")", ""))
	var rng = min(ap, 5)
	var target = map.cursor_position
	var disv = me.position - target
	var distance = max(abs(disv.x), abs(disv.y))
	if distance > rng:
		SceneManager.show_unconfirm_dialog("不能位移到{0}格以外范围".format([rng]), actorId)
		LoadControl.set_view_model(2001)
		return
	var wa = DataManager.get_war_actor_by_position(target)
	if wa != null and not wa.disabled:
		SceneManager.show_unconfirm_dialog("必须选择空位", me.actorId)
		LoadControl.set_view_model(2001)
		return
	if map.get_blockCN_by_position(target) == "城墙":
		SceneManager.show_unconfirm_dialog("不能位移到城墙上", me.actorId)
		LoadControl.set_view_model(2001)
		return
	map.aStar.update_map_for_actor(me)
	var path = map.aStar.get_clear_path(me.position, target, 6)
	if path.size() <= 1:
		map.show_color_block_by_position([])
		SceneManager.show_unconfirm_dialog("存在阻碍，不能位移到此处!", me.actorId)
		LoadControl.set_view_model(2001)
		return
	map.show_color_block_by_position(path, Color(0.0, 0.0, 0.8, 0.3))
	DataManager.set_env("翊赞目标", {"x":target.x, "y":target.y})
	var msg = "禁用{0}\n突进至指定位置\n可否？".format([schemeName])
	play_dialog(actorId, msg, 2, 2002, true)
	return

func on_view_model_2002():
	wait_for_yesno(FLOW_BASE + "_4")
	return

func effect_20469_4():
	var item = DataManager.get_env_str("目标项")
	var schemeName = item.split("(")[0]
	me.dic_skill_cd[schemeName] = 99999
	var target = DataManager.get_env_dict("翊赞目标")
	var pos = Vector2(int(target["x"]), int(target["y"]))
	ske.change_war_actor_position(actorId, pos)
	var msg = "某虽不才，不堕先父威名！"
	ske.cost_war_cd(2)
	ske.war_report()
	play_dialog(actorId, msg, 0, 2999)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return
