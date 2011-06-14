# [jquery.tmpl.loadTemplates](http://github.com/CodeCatalyst/jquery.tmpl.loadTemplates) v1.1.0  
# Copyright (c) 2011 [CodeCatalyst, LLC](http://www.codecatalyst.com/).  
# Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).

# A jQuery 1.5+ plugin that simplifies batch loading of external templates, for use with [jquery.tmpl](http://api.jquery.com/jquery.tmpl/).

# Written in [CoffeeScript](http://coffeescript.com/)

# Inspired by a [blog article](http://www.knockmeout.net/2011/03/using-external-jquery-template-files.html) written by Ryan Neimeyer.

# Regular expression for parsing the template name from a template url.
TEMPLATE_NAME_EXPRESSION = ///
	/*          # optional path
	([\w]*)     # template name
	.html       # file extension
	$           # end of line
///

# Local shorthand reference to jQuery.
$ = jQuery

# *Load external template(s).*
$.extend(
	loadTemplates: ( templates, templateProcessorCallback = null ) ->
		# Convert `templates` to an Array if a String was specified.
		templates = [ templates ] if typeof templates is "string"
		
		# Create a Deferred to track progress and relay success or failure state.
		deferred = new jQuery.Deferred()
		
		# Create a template count and an empty Array to track the loaded templates.
		templateCount = 0
		loadedTemplates = []
		
		# Load each external template in the specified Array of external templates.
		$.each( templates, ( templateName, template ) ->
			# Increment template count.
			templateCount++
			
			# Parse the template name from the external template URL if an Array was specified.
			templateName = TEMPLATE_NAME_EXPRESSION.exec( template )[ 1 ] if typeof templateName is "number"
			
			# Get the external template as HTML.
			$.get( 
				template
				( templateContent ) ->
					# Process the template content, if applicable.
					templateContent = templateProcessorCallback( templateName, templateContent ) if templateProcessorCallback?
					
					# Create a reusable named template (compiled from the template content).
					if templateContent?
						$.template( templateName, templateContent )
				"html"
			).success( ->
				# Resolve this Deferred when all of the external templates have been loaded.
				loadedTemplates.push( template )
				if ( loadedTemplates.length == templateCount )
					deferred.resolve()
			).error( ( error ) ->
				# Reject this Deferred if an error occurs while attempting to load an external template.
				deferred.reject( error )
			)
		)
		
		# Return the promise to allow callers to register callbacks.
		return deferred.promise()
)

# *Load external template(s) as template `<script/>` children of the selected element.*
$.fn.loadTemplates = ( options ) ->
	# Default options.
	defaults =
		templates: {}
		process: null
		compile: false
		done: null
		
	# Merge default and specified options.
	options = $.extend( {}, defaults, options )
	
	if options.templates?
		# Selected element.
		selectedElement = this
		
		# Load the external template(s).
		$.loadTemplates(
			options.templates,
			( templateName, templateContent ) ->
				# Process the template content via the `options.process` callback, if applicable.
				templateContent = options.process( templateName, templateContent ) if options.process?
			
				# Create a template `<script/>` from the loaded template content, identified by the template name, and append it to the selected element.
				if templateContent?
					selectedElement.append( "<script id=\"#{ templateName }\" type=\"text/x-jquery-tmpl\">#{ templateContent }</script>" )
			
				# Return the processed template content to be compiled, if `options.compile` is true.
				if options.compile then return templateContent else null
		)
		.done( =>
			# Dispatch a "done" event.
			selectedElement.trigger( $.Event("done") );
			
			# Call the `options.done` callback.
			options.done?() 
		)
		
	return this
	
