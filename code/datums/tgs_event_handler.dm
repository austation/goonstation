/datum/tgs_event_handler/impl
	var/attached = TRUE

/datum/tgs_event_handler/impl/HandleEvent(event_code, ...)
	switch(event_code)
		if(TGS_EVENT_REBOOT_MODE_CHANGE)
			var/list/reboot_mode_lookup = list ("[TGS_REBOOT_MODE_NORMAL]" = "be normal", "[TGS_REBOOT_MODE_SHUTDOWN]" = "shutdown the server", "[TGS_REBOOT_MODE_RESTART]" = "hard restart the server")
			var old_reboot_mode = args[2]
			var new_reboot_mode = args[3]
			message_admins("TGS: Reboot will no longer [reboot_mode_lookup["[old_reboot_mode]"]], it will instead [reboot_mode_lookup["[new_reboot_mode]"]]")
		if(TGS_EVENT_PORT_SWAP)
			message_admins("TGS: Changing port from [world.port] to [args[2]]")
		if(TGS_EVENT_INSTANCE_RENAMED)
			message_admins("TGS: Instance renamed to from [world.TgsInstanceName()] to [args[2]]")
		if(TGS_EVENT_COMPILE_START)
			message_admins("TGS: Deployment started, new game version incoming...")
		if(TGS_EVENT_COMPILE_CANCELLED)
			message_admins("TGS: Deployment cancelled!")
			if(mapSwitcher.locked)
				var/attemptedMap = mapSwitcher.next ? mapSwitcher.next : mapSwitcher.current
				var/msg = "Compilation of [attemptedMap] aborted! Falling back to previous setting of [mapSwitcher.nextPrior ? mapSwitcher.nextPrior : mapSwitcher.current]"
				logTheThing("admin", null, null, msg)
				logTheThing("diary", null, null, msg, "admin")
				message_admins(msg)
				// Fall back!
				mapSwitcher.unlock("FAILED")
		if(TGS_EVENT_COMPILE_FAILURE)
			message_admins("TGS: Deployment failed!")
			// Map switcher TGS integration
			if(mapSwitcher.locked) // we're waiting on the results from a map switch
				var/attemptedMap = mapSwitcher.next ? mapSwitcher.next : mapSwitcher.current
				var/msg = "Compilation of [attemptedMap] failed! Falling back to previous setting of [mapSwitcher.nextPrior ? mapSwitcher.nextPrior : mapSwitcher.current]"
				logTheThing("admin", null, null, msg)
				logTheThing("diary", null, null, msg, "admin")
				message_admins(msg)
				// Fall back!
				mapSwitcher.unlock("FAILED")
		if(TGS_EVENT_DEPLOYMENT_COMPLETE)
			message_admins("TGS: Deployment complete!")
			boutput(world, "<B>Server updated, changes will be applied on the next round...</B>")
			// Map switcher TGS integration
			if(mapSwitcher.locked) // we're waiting on the results from a map switch
				var/attemptedMap = mapSwitcher.next ? mapSwitcher.next : mapSwitcher.current
				var/msg = "Compilation of [attemptedMap] succeeded!"
				logTheThing("admin", null, null, msg)
				logTheThing("diary", null, null, msg, "admin")
				message_admins(msg)
				// Tell the map switcher we're ready
				mapSwitcher.unlock(mapNames[attemptedMap]["id"])
		if(TGS_EVENT_WATCHDOG_DETACH)
			message_admins("TGS restarting...")
			attached = FALSE
			SPAWN_DBG(600)
				if(!attached)
					message_admins("Warning: TGS hasn't notified us of it coming back for a full minute! Is there a problem?")
		if(TGS_EVENT_WATCHDOG_REATTACH)
			var/datum/tgs_version/old_version = world.TgsVersion()
			var/datum/tgs_version/new_version = args[2]
			if(!old_version.Equals(new_version))
				boutput(world, "<B>TGS updated to v[new_version.deprefixed_parameter]</B>")
			else
				message_admins("TGS: Back online")
			attached = TRUE
