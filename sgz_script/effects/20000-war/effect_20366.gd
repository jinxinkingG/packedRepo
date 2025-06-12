extends "effect_20000.gd"

#联商主动技实现
#【联商】大战场，主动技。指定一名队友进入内政装备店。以此法购买装备后，同1回合内不能再次发动。

const EFFECT_ID = 20366
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func on_view_model_2007():
	goto_step("done")

func on_view_model_2008():
	wait_for_skill_result_confirmation(FLOW_BASE + "_finish")

func on_view_model_2009():
	goto_step("finish")
	return

func effect_20366_start():
	var targets = get_teammate_targets(me)
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20366_2():
	var wf = DataManager.get_current_war_fight()
	var targetId = DataManager.get_env_int("目标")
	var msg = "{0}坊市已联络就绪\n{1}可选取所需".format([
		wf.target_city().get_full_name(),
		DataManager.get_actor_honored_title(targetId, actorId),
	])
	play_dialog(actorId, msg, 1, 2001)
	return

func effect_20366_3():
	var wf = DataManager.get_current_war_fight()
	DataManager.player_choose_city = wf.target_city().ID
	DataManager.player_choose_actor = DataManager.get_env_int("目标")
	FlowManager.add_flow("load_script|affiars/fair_equipshop.gd")
	FlowManager.add_flow("equip_menu")
	return

# 无购物结束
func effect_20366_finish():
	SceneManager.hide_all_tool()
	DataManager.player_choose_actor = me.actorId
	FlowManager.add_flow("player_skill_end_trigger")
	return

# 有购物结束
func effect_20366_done():
	var targetId = DataManager.get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var cnt = DataManager.get_env_int("装备数量")
	var equipId = DataManager.get_env_int("购买装备")
	var equipType = DataManager.get_env_str("大类型")
	var equip = clEquip.equip(equipId, equipType)
	var cost = cnt * equip.price()
	equip.dec_count(cnt)
	ske.cost_war_cd(1)
	ske.cost_wv_gold(cost)
	var current = targetActor.get_equip(equip.type)
	var mood = 2
	var msg = "无法装备此物\n{1}件{2}已置入装备库"
	var vs = me.vstate()
	# 第一件装备上身
	var weared = 0
	if targetActor.set_equip(equip):
		weared = 1
		# 身上装备入库
		vs.add_stored_equipment(current)
		msg = "已买入新装备\n{0}和{1}件{2}已置入装备库"
		mood = 1
	# 多余装备入库
	for i in range(weared, cnt):
		vs.add_stored_equipment(equip)
	msg = msg.format([
		current.name(), cnt - weared, equip.name(),
	])
	ske.war_report()

	SceneManager.play_affiars_animation("Fair_EquipShop", "")
	play_dialog(targetId, msg, mood, 2008)
	return
