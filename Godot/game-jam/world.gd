extends Node3D

var portals: Array[NodePath] = [] # drag your Portal3D nodes here in inspector


func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	show_or_hide_all(1)
	await load_all_scenes()
	await warmup_all_doors()
	show_or_hide_all(0)
	$loading.hide()

var nb_rooms = 7 # without starting hallway
func load_all_scenes():
	$Camera3D.current = true
	for i in range(nb_rooms):
		if i < nb_rooms:
			var room =  get_child(2+i)
			print(room.name)
			$Camera3D.global_position = room.global_position
			i+=1
			await get_tree().process_frame
			#room.hide()
	$Player.camera.current = true



	

#var i = 0
func warmup_all_doors():
	for door_id in global.id_to_node.keys():
		#i+=1
		#$loading/Label.text = "Loading doors (" + str(i) + "/" + str(global.id_to_node.keys().size()) + ")"
		var door = global.id_to_node[door_id]
		if door == null:
			continue

		var front_id = global.map[door_id][0]
		var back_id = global.map[door_id][1]

		var exit_front = global.id_to_node.get(front_id, null)
		var exit_back = global.id_to_node.get(back_id, null)

		# Make both rooms visible so shaders + meshes get uploaded
		door.get_parent().show()
		if exit_front:
			exit_front.get_parent().show()
		if exit_back:
			exit_back.get_parent().show()

		# Warm both directions if possible
		if exit_back:
			_warm_one_link(door.PortalExit, exit_back.PortalEnter)

		if exit_front:
			_warm_one_link(door.PortalEnter, exit_front.PortalExit)

	# Let renderer actually draw once
	await get_tree().process_frame
	await get_tree().process_frame

	# Turn everything back off
	for door in global.id_to_node.values():
		if door == null:
			continue

		if door.PortalEnter.has_method("deactivate"):
			door.PortalEnter.deactivate()

		if door.PortalExit.has_method("deactivate"):
			door.PortalExit.deactivate()

		door.PortalEnter.hide()
		door.PortalExit.hide()

	print("Warmup done.")
	show_or_hide_all(0)

func _warm_one_link(portal: Node, linked: Node):
	portal.exit_portal = linked
	portal.show()

	if portal.has_method("activate"):
		portal.activate()

	var sv = portal.get_node_or_null("SubViewport")
	if sv and sv is SubViewport:
		sv.render_target_update_mode = SubViewport.UPDATE_ONCE

func show_or_hide_all(show: bool):
	$BoringRoom.visible = show
	$KeyRoom.visible = show
	$LeverRoom.visible = show
	$GoatRoom.visible = show
	$ScaleRoom.visible = show
	$SkullRoom.visible = show
	$TrainRoom.visible = show
