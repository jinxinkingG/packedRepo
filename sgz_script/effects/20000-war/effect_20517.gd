extends "effect_20270.gd"

#虎啸被动触发判断
#【虎啸】大战场，锁定技。你非主将时：①于大战场/小战场/单挑中体力变为0的场合，你可选择“防具”或“道具”栏中的1个禁用，才能发动：你免疫那次死亡/俘虏，体力恢复满值，并直接回营。②你每禁用1个装备栏，攻击所需的机动力减少1点(至少为1)。

const EFFECT_ID = 20517
const FLOW_BASE = "effect_" + str(EFFECT_ID)

# 覆写诈取的复活效果，其他逻辑继承自诈取
func check_defeated()->bool:
	if not me.disabled:
		return false
	# 战败了
	var dic = _get_recorded_status()
	if dic.empty():
		# 没有记录，无法发动
		return false
	var suit = actor.get_suit()
	var jewelry = actor.get_jewelry()
	if suit.disabled and jewelry.disabled:
		# 没得可禁了，认了吧
		return false

	# 如果是计策引发的，禁止计策的连策
	var se = DataManager.get_current_stratagem_execution()
	se.skip_redo = 1

	return true

func effect_20517_AI_start() -> void:
	# AI 总是先禁道具
	var equip = actor.get_jewelry()
	var type = "道具"
	if equip.type_disabled():
		equip = actor.get_suit()
		type = "防具"
	DataManager.set_env("技能.虎啸.禁用类型", type)
	goto_step("2")
	return

func effect_20517_start() -> void:
	var suit = actor.get_suit()
	var jewelry = actor.get_jewelry()
	if suit.disabled:
		DataManager.set_env("技能.虎啸.禁用类型", "道具")
		goto_step("2")
		return
	if jewelry.disabled:
		DataManager.set_env("技能.虎啸.禁用类型", "防具")
		goto_step("2")
		return
	# 两个都可用，选一个
	var items = [
		"防具：" + suit.name(),
		"道具：" + jewelry.name(),
	]
	var values = ["防具", "道具"]
	SceneManager.show_unconfirm_dialog("禁用哪个装备？")
	SceneManager.bind_top_menu(items, values, 1)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_item(FLOW_BASE + "_2")
	DataManager.set_env("技能.虎啸.禁用类型", DataManager.get_env_str("目标项"))
	return

func effect_20517_2() -> void:
	var dic = _get_recorded_status()
	var type = DataManager.get_env_str("技能.虎啸.禁用类型")
	# 处理技能效果
	ske.set_war_skill_val({}, 0)
	DataManager.disable_actor_equip_type(20000, actorId, type)

	# 恢复状态
	actor.set_status_officed()
	var loyalty = int(dic["l"])
	for vs in clVState.all_vstates():
		if vs.is_alive() and vs.get_lord_id() == actor.actorId:
			loyalty = 100
	actor.set_loyalty(loyalty)
	actor.set_soldiers(dic["s"])

	# 恢复归属
	var wvId = int(dic["wv"])
	var wv = wf.get_war_vstate(wvId)
	if wv != null:
		wv.add_war_actor(me)
		me.disabled = false

	# 恢复满体
	actor.set_hp(actor.get_max_hp())
	ske.append_message("免于战败", actorId)

	# 恢复位置
	var pos = Vector2(dic["x"], dic["y"])
	var existed = DataManager.get_war_actor_by_position(pos)
	if existed == null:
		me.position = pos
	else:
		# 设为待布阵
		me.position = Vector2(-1, -1)

	# 台词
	var msg = "此物碍事！回营换了再战！\n（【{0}】避免战败\n（已禁用{1}".format([
		ske.skill_name, actor.get_equip(type).name(),
	])
	play_dialog(actorId, msg, 0, 2001)
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_20517_3() -> void:
	ske.war_camp_in(actorId)
	ske.war_report()
	skill_end_clear()
	return
