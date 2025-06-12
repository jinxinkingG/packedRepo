extends "effect_20000.gd"

#急出大战场效果
#【急出】大战场,锁定技。若你开始移动前处于城地形，本次移动，在除城地形之外的每一步，消耗最多为2点机动力。

const EFFECT_ID = 20247

func check_trigger_correct()->bool:
	match self.triggerId:
		20003: # 移动动作
			self._on_movement()
		20007: # 移动机动力计算
			self._move_cost_ap()
	return false

func _on_movement():
	if not DataManager.common_variable.has("移动"):
		return false
	if int(DataManager.common_variable["移动"]) != 0:
		return false
	# 至此，为开始或停止移动，无条件清除标记
	SkillHelper.set_skill_variable(20000, EFFECT_ID, self.actorId, 0, 0)
	if DataManager.common_variable.has("停止移动"):
		return false
	var me = DataManager.get_war_actor(self.actorId)
	if me == null or me.disabled:
		return false
	var map = SceneManager.current_scene().war_map
	var blockCN = map.get_blockCN_by_position(me.position)
	if not blockCN in StaticManager.CITY_BLOCKS_CN:
		return false
	# 至此，为开始移动，并且当前位置为城地形，加标记
	SkillHelper.set_skill_variable(20000, EFFECT_ID, self.actorId, 1, 1)
	return false

func _move_cost_ap():
	# 先检查标记
	var skv = SkillHelper.get_skill_variable(20000, EFFECT_ID, self.actorId)
	if skv["turn"] <= 0 or skv["value"] != 1:
		return false
	# 除城地形外，都优惠
	set_max_move_ap_cost([], 2, StaticManager.CITY_BLOCKS_CN)
	return false
