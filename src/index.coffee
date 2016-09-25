window.keystack = new Set()
window.register = ""
window.globalMap = {
	IMP: 'import'
}
window.stateMachine = {
	isRecording: false
	isDeleting: false
}
window.statusColor = "white"
window.status = ""

draw_keymaps = -> 
	content = ''
	keystack.forEach (i) ->
		content = content + i
	$('span.keymap').text content
	$('span.keystr').text register
	$('span.status').text window.status
	console.log window.statusColor
	$('span.status').css 'background-color', window.statusColor

process_keymap = (charStr) ->
	s = new Set(charStr.toUpperCase().split('').sort())
	res = ''
	s.forEach (i) ->
		res += i
	if (not window.stateMachine.isRecording) and (not window.stateMachine.isDeleting)
		if res is "CER"
			stateMachine.isRecording = true
			window.status = 'RECORDING CHORD'
			window.statusColor = 'yellow'
		else if res is "DEL"
			stateMachine.isDeleting = true
			window.status = 'DELETING CHORD'
			window.statusColor = 'sky'
		else
			if globalMap[res]
				window.status = res+' = '+globalMap[res]
				window.statusColor = 'lime'
				codeMirror.replaceSelection globalMap[res]
			else
				window.status = 'No such chord: '+res
				window.statusColor = 'orange'
	else if window.stateMachine.isRecording
		if res is "CER"
			stateMachine.isRecording = false
			window.status = ''
			window.statusColor = 'white'
		else if res is "DEL"
			stateMachine.isRecording = false
			stateMachine.isDeleting = true
			window.status = 'DELETING CHORD'
			window.statusColor = 'lime'
		else
			sel = codeMirror.getSelection()
			if sel
				word = sel
			else
				A1 = codeMirror.getCursor().line
				A2 = codeMirror.getCursor().ch
				B1 = codeMirror.findWordAt({line: A1, ch: A2}).anchor.ch
				B2 = codeMirror.findWordAt({line: A1, ch: A2}).head.ch
				word = codeMirror.getRange {line: A1,ch: B1}, {line: A1,ch: B2}
			globalMap[res] = word
			window.status = 'SET '+res+' = '+word
			stateMachine.isRecording = false
			window.statusColor = 'lime'
	else if window.stateMachine.isDeleting
		if res is "CER"
			stateMachine.isRecording = true
			stateMachine.isDeleting = false
			window.status = 'RECORDING CHORD'
			window.statusColor = 'yellow'
		else if res is 'DEL'
			stateMachine.isDeleting = false
			window.status = ''
			window.statusColor = 'white'
		else
			globalMap[res] = undefined
			stateMachine.isDeleting = false
			window.status = 'Deleted Map for '+res
			window.statusColor = 'lime'
	draw_keymaps()

$(document).ready ->
	window.codeMirror = CodeMirror.fromTextArea document.getElementById 'main-editor'
	codeMirror.on 'keydown', (m, e) ->
		keycode = e.keyCode or e.which
		if keycode==32 or keycode <=90 and keycode >= 65 and not (e.ctrlKey or e.metaKey)
			e.preventDefault()
			window.keystack.add e.key
			window.register += e.key
			draw_keymaps()

	codeMirror.on 'keyup', (m, e) ->
		keycode = e.keyCode or e.which
		if keycode==32 or keycode <=90 and keycode >= 65 and not (e.ctrlKey or e.metaKey)
			e.preventDefault()
			window.keystack.delete e.key.toLowerCase()
			window.keystack.delete e.key.toUpperCase()
			if window.keystack.size is 0
				if window.register.length <= 2
					codeMirror.replaceSelection window.register
					window.register = ""
				else
					process_keymap register
					console.log register
					window.register = ""
			draw_keymaps()