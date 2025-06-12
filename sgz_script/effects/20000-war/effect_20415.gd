extends "effect_20000.gd"

#强记主动技 #附加装备
#【强记】大战场，主动技。你的道具栏始终视为装备“XXX”（书名）。你有相邻武将时，你发动后，选择相邻武将之一，将其道具栏的书，默背强记到你的心中；你没有相邻武将时，你发动后，可以选择你背过的一本书，你视为装备它。

const EFFECT_ID = 20415
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20415_start()->void:
	var had = Global.intarrval(ske.get_skill_val(10000))
	var targets = []
	var nearbys = 0
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var wa = DataManager.get_war_actor_by_position(me.position + dir)
		if wa == null or wa.disabled:
			continue
		nearbys += 1
		var book = wa.actor().get_jewelry()
		if book.subtype() != "书":
			continue
		if book.id in had:
			continue
		targets.append(wa.actorId)
	if nearbys == 0:
		goto_step("recall")
		return
	if targets.empty():
		play_dialog(me.actorId, "没有值得默背的目标", 3, 2999)
		return
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_choose_actor(FLOW_BASE + "_copy")
	return

func effect_20415_copy()->void:
	var targetId = get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)
	var book = wa.actor().get_jewelry()

	var had = Global.intarrval(ske.get_skill_val(10000))
	while book.id in had:
		had.erase(book.id)
	had.append(book.id)
	ske.set_skill_val(had, 99999, -1, 10000)
	var skillInfo = "已默背{0}的「{1}」".format([
		wa.get_name(), book.name(), 
	])
	ske.append_message(skillInfo)
	ske.war_report()
	var msg = "博闻强识，一目十行\n" + skillInfo
	if book.id == had[0]:
		msg += "\n并设定为当前配装"
	else:
		msg += "\n当前配装：「{0}」".format([clEquip.equip(had[0], "道具").name()])
	play_dialog(me.actorId, msg, 1, 2999)
	return

func effect_20415_recall()->void:
	var had = Global.intarrval(ske.get_skill_val(10000))
	if had.empty():
		play_dialog(me.actorId, "尚未默背任何典籍", 3, 2999)
		return
	var items = []
	var values = []
	for id in had:
		var book = clEquip.equip(id, "道具")
		if book.subtype() != "书":
			continue
		items.append(book.name())
		values.append(book.id)
	SceneManager.show_unconfirm_dialog("选择已默背的书籍\n作为额外「装备」", me.actorId)
	bind_menu_items(items, values, 2)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001()->void:
	SceneManager.lsc_menu_top.lsc.set_selected_by_array([0])
	wait_for_choose_item(FLOW_BASE + "_selected")
	return

func effect_20415_selected()->void:
	var had = Global.intarrval(ske.get_skill_val(10000))
	var selected = DataManager.get_env_int("目标项")
	if not selected in had:
		play_dialog(-1, "未选择有效目标", 2, 2999)
		return
	while selected in had:
		had.erase(selected)
	had.insert(0, selected)
	ske.set_skill_val(had, 99999, -1, 10000)
	var book = clEquip.equip(selected, "道具")
	var msg = "已选择「{0}」\n视为配装".format([book.name()])
	play_dialog(me.actorId, msg, 2, 2999)
	return

func on_view_model_2999()->void:
	wait_for_skill_result_confirmation()
	return
