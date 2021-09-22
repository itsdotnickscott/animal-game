class_name MoveType


enum {
	DAMAGE,		# single-target damage
	AOE,		# multi-target damage
	STATUS,		# apply status effect
	HEAL,		# single-target HP restored
	AOE_HEAL,	# multi-target HP restored
	SHIELD,		# temporary damage blocked
	MOVE,		# this is reserved for the move buttons in AbilityHUD, not for heroes
}