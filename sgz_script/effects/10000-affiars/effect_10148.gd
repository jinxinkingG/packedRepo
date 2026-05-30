extends "effect_10000.gd"

#巡野主动技
#【巡野】内政，主动技。消耗1枚命令书发动。你进入本城的战争地图，持续10天。选择撤退可提前离开战场。每月限1次。

const EFFECT_ID = 10148
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const CD = 1
const DAY_LIMIT = 10

# 开始：确认是否消耗命令书
func effect_10148_start() -> void:
	if DataManager.orderbook <= 0:
		play_dialog(actorId, "没有命令书，无法发动", 2, 2999)
		return
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var msg = "消耗1枚命令书\n巡察{0}战场地形，可否？".format([city.get_full_name()])
	SceneManager.show_yn_dialog(msg, actorId)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

# 确认：播放命令书消耗动画
func effect_10148_confirmed() -> void:
	SceneManager.dialog_use_orderbook_animation(FLOW_BASE + "_go")
	LoadControl.set_view_model(2001)
	return

# 进入战争地图
func effect_10148_go() -> void:
	var cityId = get_working_city_id()
	var vstateId = clCity.city(cityId).get_vstate_id()

	var wf = DataManager.new_war_fight(cityId, cityId)
	wf.source = "巡野"

	# 守方（玩家）
	var defenderWV = War_Vstate.new(vstateId, false, false)
	defenderWV.from_cityId = cityId
	defenderWV.init_actors = [actorId]
	defenderWV.main_actorId = actorId
	var city = clCity.city(cityId)
	defenderWV.money = city.get_gold()
	defenderWV.rice = city.get_rice()
	wf.defenderWV = defenderWV

	# 城市金米已全部带入战场，清零
	city.add_gold(-city.get_gold())
	city.add_rice(-city.get_rice())

	# 攻方（空 dummy，永远未就绪）
	# 手动设置不同 id，避免与守方相同导致 get_war_vstate 查找冲突
	var attackerWV = War_Vstate.new(vstateId, false, true)
	attackerWV.id = vstateId * 100 + 99
	attackerWV.from_cityId = cityId
	attackerWV.init_actors = []
	attackerWV.main_actorId = -1
	attackerWV.money = 0
	attackerWV.rice = 99999
	attackerWV.pendingDates = 999
	wf.attackerWV = attackerWV

	# 天数上限
	wf.set_env("天数上限", DAY_LIMIT)

	# 设置冷却
	ske.affair_cd(CD)

	# 初始化并进入战争场景
	wf.init_war()
	LoadControl.end_script()
	FlowManager.clear_bind_method()
	FlowManager.add_flow("go_to_scene|res://scene/scene_war/scene_war.tscn")
	FlowManager.add_flow("war_patrol_start")
	return
