# [jquery.tmpl.loadTemplates](http://github.com/CodeCatalyst/jquery.tmpl.loadTemplates) v1.0.1  
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
	loadTemplates: ( templates ) ->
		# Convert `templates` to an Array if a String was specified.
		templates = [ templates ] if typeof templates is "string"
		
		# Create a Deferred to track progress and relay success or failure state.
		deferred = new jQuery.Deferred()
		
		# Create an empty Array to track the loaded templates.
		loadedTemplates = []
		
		# Load each external template in the specified Array of external templates.
		$.each( templates, ( templateName, template ) ->
			# Parse the template name from the external template URL if an Array was specified.
			templateName = TEMPLATE_NAME_EXPRESSION.exec( template )[ 1 ] if typeof templateName is "number"
			
			# Get the external template as HTML.
			$.get( 
				template
				( content ) ->
					$.template( templateName, content )
				"html"
			).success( ->
				# Resolve this Deferred when all of the external templates have been loaded.
				loadedTemplates.push( template )
				if ( loadedTemplates.length == templates.length )
					deferred.resolve( $( templateName ) )
			).error( ( error ) ->
				# Reject this Deferred if an error occurs while attempting to load an external template.
				deferred.reject( error )
			)
		)
		
		# Return the promise to allow callers to register callbacks.
		return deferred.promise()
)
