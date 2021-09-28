extends Node2D


var rng = RandomNumberGenerator.new()

var mass = 200
var velocity
var gravity = Vector2(0, 1)


func show_value(value, duration, heal=false, crit=false):
	rng.randomize()

	velocity = Vector2(rng.randf_range(25, 75), rng.randf_range(-125, -75))

	z_index = 1
	$Label.text = value

	$Tween.interpolate_property(self, "modulate:a",
		1.0, 0.0, duration,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

	# Change color for crit
	if heal:
		modulate = Color("3eff33")
	if crit:
		modulate = Color(1, 0, 0)

	# Start animation and wait to finish
	$Tween.start()
	yield($Tween, "tween_all_completed")
	queue_free()


func _process(delta):
	velocity += gravity * mass * delta
	position += velocity * delta