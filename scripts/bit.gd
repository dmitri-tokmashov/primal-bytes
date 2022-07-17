extends Area2D
class_name Bit

var code: String = "0";
var byte: Byte;
var _timer: float;

func _ready():
	connect("body_entered", self, "body_entered");

func _physics_process(delta):
	if visible:
		if byte != null:
			position -= (Vector2.ONE * 512 * delta).rotated(rotation - PI / 4);
		_timer -= delta;
		if _timer < 0:
			termination();

func initialization():
	if code[0] == "0":
		$sprite.self_modulate = Color8(85, 255, 255);
	if code[0] == "2":
		$sprite.self_modulate = Color8(255, 85, 255);
	$sprite.rotation = 2 * PI - rotation;
	set_deferred("monitorable", true);
	visible = true;
	if byte == null:
		_timer = 8 + randi() % 8;
	else:
		_timer = 2;

func body_entered(body):
	if visible and body != byte:
		if code[0] == "0" and body.code[1] != code[1]:
			body.stamina -= 10;
			termination();
		elif code[0] == "1":
			if byte == null:
				body.stamina += 15;
			else:
				body.stamina += 10;
			if body.stamina > int(body.code[4]) * 5:
				body.stamina = int(body.code[4]) * 5;
			body.feeding();
			termination();
		elif code[0] == "2" and body.code[0] == "X" and body.age >= Byte.phases[1] and body.age < Byte.phases[3] and not body.timer != 0:
			body.timer = 8;
			body.get_node("sprite").self_modulate = Color8(255, 255, 255);
			body.seed_code = code.substr(1, 8);
			termination();

func termination():
	position = Vector2.ZERO;
	rotation = 0;
	visible = false;
	if byte == null:
		position = Vector2(0, get_parent().distance).rotated(deg2rad(22.5 + 45 * (randi() % 9))) + Vector2(rand_range(-1024, 1024), rand_range(-1024, 1024));
		initialization();
