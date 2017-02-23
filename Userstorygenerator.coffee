class Userstorygenerator
	constructor: (@inputSelector, @outputSelector, @story)->
		$("body").on "keyup", ".template", (e)=>
			@updateStoryTemplate $(e.currentTarget).val()
		$("body").on "click", ".templateSetter", (e)=>
			@updateStoryTemplate $(e.currentTarget).data("template")


		$(@inputSelector).on "keyup", ".variable", ()=>
			@tellStory()
		$(".template").val(@story)
		@render @story

	updateStoryTemplate: (newTemplate)->
		@render(newTemplate)

	render: (story)->
		@story = story
		@generateView()
		@tellStory()



	escapeHtml: (text) ->
		return text
			.replace(/&/g, "&amp;")
			.replace(/</g, "&lt;")
			.replace(/>/g, "&gt;")
			.replace(/"/g, "&quot;")
			.replace(/'/g, "&#039;");

	getPlaceHolders: ()->
		@story = @story.split(",").join(" ,")
		@words = @story.split(" ");
		@placeholders = (@isPlaceholder word for word in @words)
		@story = @story.split(" ,").join(",")
		@placeholders = $.grep @placeholders, (value)-> return value != false
		@placeholders = @placeholders.filter (v, i, a) => a.indexOf(v) is i



	generateView: ()->
		@getPlaceHolders()
		$row = $("<tr>");
		$(@inputSelector).empty()
		for placeholder in @placeholders
			$col = $("<td>");
			$col.append $("<input>").addClass("variable").attr("placeholder", "<#{placeholder}>").attr("data-value", placeholder).val ""
			$row.append $col
		$(@inputSelector).append $("<table>").append($row);


	placeHolderToVariableName: (placeholder)->
		placeholder.substr(1, placeholder.length - 2)

	isPlaceholder: (word)->
		return @placeHolderToVariableName word if (word.substr(0, 1) is "{" and word.substr(-1) is "}")
		return false

	tellStory: ()->
		output = @story
		for placeholder in @placeholders
			value = $("[data-value='#{placeholder}']").val().trim()
			if value is ""
				value = "<#{placeholder}>"
			output = output.split("{#{placeholder}}").join "<span class='hilight'>#{@escapeHtml(value)}</span>";
		$(@outputSelector).html output
