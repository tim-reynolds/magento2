startup = function(event)

	local config   = event.config
	local inlet    = event.inlet
	local excludes = inlet.getExcludes( )
	local delete   = nil
	local target   = config.target

	if not target then
		if not config.host then
			error('Internal fail, Neither target nor host is configured')
		end

		target = config.host .. ':' .. config.targetdir
	end

	if config.delete == true or config.delete == 'startup' then
		delete = { '--delete', '--ignore-errors' }
	end

	if #excludes == 0 then
		-- start rsync without any excludes
		log(
			'Normal',
			'limited recursive startup rsync: ',
			config.source,
			' -> ',
			target
		)

		spawn(
			event,
			config.rsync.binary,
			delete,
			config.rsync._computed,
			'-r',
			'/tmp/ignore1',
			'/tmp/ignore2'
		)

	else
		-- start rsync providing an exclude list
		-- on stdin
		local exS = table.concat( excludes, '\n' )

		log(
			'Normal',
			'recursive startup rsync: ',
			config.source,
			' -> ',
			target,
			' excluding\n',
			exS
		)

		spawn(
			event,
			config.rsync.binary,
			'<', exS,
			'--exclude-from=-',
			delete,
			config.rsync._computed,
			'-r',
			config.source,
			target
		)
	end
end

default.rsync.init = startup
settings {
    nodaemon = true
}
sync {
        default.rsync,
        source = "/var/www/html/magento2/pub/static",
        target = "/vagrant/pub_static"
}
