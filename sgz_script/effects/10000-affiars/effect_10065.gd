extends "effect_10000.gd"

# 天威转换效果，其被动效果在诱发技机制中直接实现
#【天威】大战场，君主锁定技。只要你在战场，双方所有诱发技效果改为“恢复10点体力值”。你为非君主时，你失去本技能，并获得<毒逝>。

# 被动效果，检查是否转换技能
func check_trigger_correct()->bool:
	for vs in clVState.all_vstates():
		if vs.get_lord_id() == self.actorId:
			return false
	SkillHelper.remove_scene_actor_skill(10000, self.actorId, "天威")
	SkillHelper.clear_ban_actor_skill(10000, [self.actorId], ["毒逝"])
	return false
