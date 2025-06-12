extends "effect_20000.gd"

#武令主动技实现
#【武令】大战场,主动技。你可以消耗5点机动值，将装备库里的一件装备交予一名在场的武将，每回合限1次。

const EFFECT_ID = 20256
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 5

const DIALOG_IMPROVED = {
	"武器": "此{类型}趁手，看我斩将夺旗！",
	"防具": "甲坚兵利，千万人亦可往！",
	"道具": "此物甚好，非吾不能善用之",
	"坐骑": "宝驹配良将，如虎添翼也",
}
const DIALOG_SPECIAL = {
	"道具" + str(StaticManager.JEWELRY_ID_JIEZISHU): ["明志、致远，君子之道也", 2],
	"道具" + str(StaticManager.JEWELRY_ID_QINGGANGJIAN): ["战阵之内，谁能近我？", 0],
	"道具" + str(StaticManager.JEWELRY_ID_JIANGYIN): ["印绶在此，三军听我号令", 2],
}

func effect_20256_start():
	if not assert_action_point(me.actorId, COST_AP):
		return
	var targets = get_teammate_targets(me)
	targets.append(me.actorId)
	if not wait_choose_actors(targets, "选择我方武将发动【{0}】"):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20256_2():
	var targetId = get_env_int("目标")
	var msg = "{0}若需趁手装备\n可开武库挑选".format([
		DataManager.get_actor_honored_title(targetId, me.actorId),
	])
	if targetId == me.actorId:
		goto_step("3")
		return
	set_env("列表页码", 0)
	play_dialog(me.actorId, msg, 2, 2001)
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_20256_3():
	var targetId = get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var targetWA = DataManager.get_war_actor(targetId)
	# 排除当前已装备
	var excepted = []
	for type in StaticManager.EQUIPMENT_TYPES:
		var cur = targetActor.get_equip(type)
		excepted.append("{0}.{1}".format([cur.id, cur.type]))
	var availableItems = []
	# 装备库库存
	var vs = me.vstate()
	for stored in vs.list_stored_equipments(excepted):
		availableItems.append({
			"ID": stored[0].id,
			"类型": stored[0].type,
			"装备库数量": stored[1],
		})
	# 队友装备
	for teammateId in get_teammate_targets(targetWA, 9999):
		var tmActor = ActorHelper.actor(teammateId)
		for type in StaticManager.EQUIPMENT_TYPES:
			var equip = tmActor.get_equip(type)
			if equip.id == targetActor.get_equip(type).id:
				continue
			var found = false
			for item in availableItems:
				if item.has("actorId"):
					continue
				if item["ID"] != equip.id:
					continue
				if item["类型"] != equip.type:
					continue
				found = true
				break
			if found:
				continue
			availableItems.append({
				"ID": equip.id,
				"类型": equip.type,
				"actorId": teammateId,
			})
	var page = get_env_int("列表页码")
	var pageSize = 12
	var maxPage = int(ceil((availableItems.size() - 1) / pageSize))
	if page > maxPage:
		page = 0
	if page < 0:
		page = maxPage
	set_env("列表页码", page)

	var items = []
	var values = []
	var from = pageSize * page
	var to = min(availableItems.size(), from + pageSize) - 1
	availableItems = availableItems.slice(from, to)
	for item in availableItems:
		var equipType = item["类型"]
		var equipId = item["ID"]
		var equip = clEquip.equip(equipId, equipType)
		var info = ""
		if item.has("actorId"):
			info = "{0} ({1})".format([equip.name(), ActorHelper.actor(item["actorId"]).get_name()])
		else:
			info = "{0} x{1}".format([equip.name(), item["装备库数量"]])
			if item["装备库数量"] == 1:
				info = equip.name()
		if equip.level() == "S":
			info += "#C212,32,32"
		items.append(info)
		values.append(item.duplicate())
	for i in range(items.size(), 14):
		items.append("")
		values.append("")
	if maxPage > 0:
		items.append("下一页")
		values.append({"ID": -1, "类型":"下一页"})
		items.append("上一页")
		values.append({"ID": -1, "类型":"上一页"})

	var msg = "请选择装备"
	SceneManager.show_unconfirm_dialog(msg, targetId)
	bind_menu_items(items, values)
	if maxPage > 0:
		SceneManager.lsc_menu_top.lsc.set_pager(page, maxPage)
	# 配合列表翻页，临时方案
	DataManager.set_env("CURRENT_FLOW", FLOW_BASE + "_3")
	LoadControl.set_view_model(2002)
	return

func on_view_model_2002():
	Global.wait_for_choose_equip(FLOW_BASE + "_4", FLOW_BASE + "_start")
	return

func effect_20256_4():
	var targetId = DataManager.get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var item = DataManager.get_env_dict("目标项")
	var equipId = int(item["ID"])
	var equipType = str(item["类型"])
	var equip = clEquip.equip(equipId, equipType)
	if not equip.actor_can_use(targetId):
		var msg = "无论如何\n亦无法掌握这等宝物"
		play_dialog(targetId, msg, 3, 2009)
		return
	var currentEquip = targetActor.get_equip(equipType)
	var msg = "将{0}替换为{1}可否？\n（现装备：{2}".format([
		equip.type, equip.name(), currentEquip.name(),
	])
	play_dialog(targetId, msg, 2, 2003, true)
	return

func on_view_model_2003():
	wait_for_yesno(FLOW_BASE + "_5")
	return

func effect_20256_5():
	var targetId = get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var item = get_env_dict("目标项")
	var equipId = int(item["ID"])
	var equipType = str(item["类型"])
	var equip = clEquip.equip(equipId, equipType)
	var currentEquip = targetActor.get_equip(equipType)
	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)
	ske.war_report()
	var mood = 3
	var msgs = ["…… 也罢，凑合用吧", "", ""]
	var specialKey = "{0}{1}".format([equip.type, equip.id])
	if DIALOG_SPECIAL.has(specialKey):
		msgs[0] = DIALOG_SPECIAL[specialKey][0]
		mood = DIALOG_SPECIAL[specialKey][1]
	elif equip.level_score() > currentEquip.level_score():
		msgs[0] = DIALOG_IMPROVED[equipType].format(equip.as_dict())
		mood = 1
	elif equip.level_score() == currentEquip.level_score():
		msgs[0] = "嗯 …… 换手试试也不错"
		mood = 2
	msgs[1] = "（{0}换装{1}".format([
		targetActor.get_name(), equip.name(),
	])
	if not targetActor.set_equip(equip):
		var msg = "无法装备此物"
		play_dialog(targetId, msg, 3, 2009)
		return
	if item.has("actorId") and int(item["actorId"]) >= 0:
		var exchangeActor = ActorHelper.actor(int(item["actorId"]))
		if exchangeActor.get_equip(equipType).id == equipId:
			msgs[2] = "{0}换装{1}".format([
				exchangeActor.get_name(), currentEquip.name(),
			])
			if not exchangeActor.set_equip(currentEquip):
				# 无法换装，换回来
				targetActor.set_equip(currentEquip)
				var msg = "{0}无法换装{1}".format([
					exchangeActor.get_name(), currentEquip.name()
				])
				play_dialog(targetId, msg, 3, 2009)
				return
			play_dialog(targetId, "\n".join(msgs), mood, 2009)
			return
	msgs[2] = "{0}已置入仓库".format([
		currentEquip.name()
	])
	var vs = me.vstate()
	vs.remove_stored_equipment(equip)
	vs.add_stored_equipment(currentEquip)
	play_dialog(targetId, "\n".join(msgs), mood, 2009)
	return

func on_view_model_2009():
	wait_for_skill_result_confirmation()
	return
