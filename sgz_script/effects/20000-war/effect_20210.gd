extends "effect_20000.gd"

#守业锁定技
#【守业】大战场,主将锁定技。若你为守方，你方武将每回合机动力恢复满值。

# 锁定技部分
func check_trigger_correct() -> bool:
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	var me = DataManager.get_war_actor(self.actorId)
	if me == null or me.disabled:
		return false
	if me.get_main_actor_id() != self.actorId:
		# 不是主将
		return false
	var wv = me.war_vstate()
	if wv == null or wv.side != "防守方":
		return false
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null or wa.disabled:
		return false
	wa.action_point = max(wa.get_max_action_ap(), wa.action_point)
	return false
