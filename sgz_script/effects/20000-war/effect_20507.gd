extends "effect_20000.gd"

#沙暴主动技
#【沙暴】大战场，限定技。你发动黄巾军秘术：所有平地，2天内变为沙漠地形，且所有敌方随机获得1回合 {定止} 、 {迟滞} 、 {疲兵} 、 {伤神} 之一。

const EFFECT_ID = 20507
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20507_start()->void:
	var msg = "发动【{0}】\n平地起沙，袭扰敌军\n可否？".format([ske.skill_name])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000()->void:
	wait_for_yesno(FLOW_BASE + "_go")
	return

func effect_20507_go()->void:
	var wf = DataManager.get_current_war_fight()
	ske.cost_war_cd(99999)
	for x in map.cell_columns:
		for y in map.cell_rows - 1:
			var pos = Vector2(x, y)
			if map.get_blockCN_by_position(pos) == "平原":
				map.set_temp_block(pos, "desert_1", 2)

	var buffs = ["定止", "迟滞", "疲兵", "伤神"]
	for wa in wf.get_war_actors(false, true):
		if not me.is_enemy(wa):
			continue
		buffs.shuffle()
		ske.set_war_buff(wa.actorId, buffs[0], 1)
	var msg = "太清在上，如律令敕！"

	map.draw_actors()
	ske.war_report()
	play_dialog(actorId, msg, 0, 2999)
	return

func on_view_model_2999()->void:
	wait_for_skill_result_confirmation()
	return
