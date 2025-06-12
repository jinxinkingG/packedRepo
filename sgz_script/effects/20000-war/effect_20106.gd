extends "effect_20000.gd"

#无惧效果实现
#【无惧】大战场,诱发技。战争初始，若你方为守方，且对方总兵力多于你方的场合，可以发动：你方所有武将，无视兵力上限，依次自动将备用兵补充至2500，战争结束时，超过上限的兵力，重新转回备用兵处。

const EFFECT_ID = 20106
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20019()->bool:
	# 仅第一天允许发动
	var wf = DataManager.get_current_war_fight()
	if wf.date != 1:
		return false

	if me.side() != "防守方":
		return false

	# 计算双方兵力
	var wv = me.war_vstate()
	if wv == null:
		return false
	var enemyWV = wv.get_enemy_vstate()
	if enemyWV == null:
		return false
	var enemyTroops = 0
	var ourTroops = 0
	for wa in wv.get_war_actors(false):
		ourTroops += wa.get_soldiers()
	for wa in enemyWV.get_war_actors(false):
		enemyTroops += wa.get_soldiers()
	if enemyTroops <= ourTroops:
		# 敌方兵力不占优势
		return false

	var currentCity = clCity.city(wv.from_cityId)
	return currentCity.get_backup_soldiers() > 0

func effect_20106_start()->void:
	var msg = "此战男子当战，女子当运\n敌势虽众，又何惧哉！"
	play_dialog(me.actorId, msg, 0, 2000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_20106_2()->void:
	ske.cost_war_cd(99999)

	var currentCityId = me.war_vstate().from_cityId
	var currentCity = clCity.city(currentCityId)
	var availableTroops = currentCity.get_backup_soldiers()

	for wa in me.war_vstate().get_war_actors(false):
		if availableTroops <= 0:
			break
		var actor = ActorHelper.actor(wa.actorId)
		var currentTroops = actor.get_soldiers()
		if currentTroops >= 2500:
			continue
		if currentTroops + availableTroops >= 2500:
			actor.set_soldiers(2500)
			availableTroops -= 2500 - currentTroops
		else:
			actor.set_soldiers(currentTroops + availableTroops)
			availableTroops = 0
	currentCity.set_property("后备兵", availableTroops)
	SceneManager.current_scene().war_map.draw_actors()
	var msg = "已紧急征调后备兵\n补充部队"
	play_dialog(-1, msg, 2, 2999)
	return

func on_view_model_2999()->void:
	wait_for_skill_result_confirmation("")
	return
