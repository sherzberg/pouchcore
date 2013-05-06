
class PouchCore
	constructor: (@remoteUrl, @onChange, start_replication=true) ->
		if @remoteUrl.slice(0,4)=='http'
			parts = @remoteUrl.split('/')
			@_dbName = parts.pop()
			while @_dbName == ""
				@_dbName = parts.pop()
		else
			@_dbName = @remote_url
		self = @
		Pouch @_dbName, (e, db) =>
			unless e
				self.db = db
				self.db.changes(
					continuous : true
					include_docs : true
					onChange : @onChange
				)
				if start_replication
					self.start()
			else
				Pouch @remoteUrl, (e, db) =>
					unless e
						self.db = db
						self.db.changes(
							continuous : true,
							include_docs : true,
							onChange : @onChange
						)
						self
					else
						return "Something bad happend"
			self
	stop: ()=>
		unless not @up
			console.log "stopped"
			@up=false
			@_to.cancel()
			@_from.cancel()
		@
	start: () ->
		unless @up
			console.log "starting"
			@up=true
			@_to=@db.replicate.to @remoteUrl, {continuous: true}
			@_from=@db.replicate.from @remoteUrl, {continuous: true}
		@

	add: (doc, cb = ()-> true) ->
		unless "_id" of doc
			@db.post doc, cb
		else if "_id" of doc and doc._id.slice(0,9) != "_design/"
			@db.put doc, cb
		else if doc.length
			@db.bulkDocs doc, cb
		@
	get: (id, cb = ()-> true) ->
		@db.get id, cb
		@
	remove: (id, cb = ()-> true) ->
		@db.get id, (err, doc) =>
			@db.remove doc, cb unless err
			cb("err") if err
		@

window.PouchCore = PouchCore
