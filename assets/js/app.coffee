url = location.protocol + "//"+ location.host + "/datastore"

consoleCallback = (err, resp) ->
	console.log resp

allDocsCallback = (err, resp) ->
	console.log item.id, item.doc.title, item.doc.content for item in resp.rows
	table = $('#table')
	table.append(item.id) for item in resp.rows

$(document).ready ()->
	window.pouch = new PouchCore url, (change)=>
		if change.id[0] isnt "_" and (change.doc.type is 'note' or change.doc.type is 'page')
			unless change.doc._deleted
				obj[change.id] = change.doc
				update()
			else if change.doc._deleted and change.id of obj
				delete obj[change.id]
				update()
	, false

	$('#replication-start').click (item) ->
		pouch.start()
	$('#replication-stop').click (item) ->
		pouch.stop()

	$('#add').click (item) ->
		newPost = {
			title: $('#title').val(),
			content: $('#content').val(),
			date: new Date()
		}

		if newPost.title isnt '' or newPost.content isnt ''
			pouch.add(newPost, consoleCallback)
			pouch.db.allDocs({include_docs: true}, allDocsCallback)
		else
			$('#message').html('Title and Content are required')
