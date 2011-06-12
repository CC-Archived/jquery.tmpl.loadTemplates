(function() {
  var $, TEMPLATE_NAME_EXPRESSION;
  TEMPLATE_NAME_EXPRESSION = /\/*([\w]*).html$/;
  $ = jQuery;
  $.extend({
    loadTemplates: function(templates) {
      var deferred, loadedTemplates;
      if (typeof templates === "string") {
        templates = [templates];
      }
      deferred = new jQuery.Deferred();
      loadedTemplates = [];
      $.each(templates, function(templateName, template) {
        if (typeof templateName === "number") {
          templateName = TEMPLATE_NAME_EXPRESSION.exec(template)[1];
        }
        return $.get(template, function(content) {
          return $.template(templateName, content);
        }, "html").success(function() {
          loadedTemplates.push(template);
          if (loadedTemplates.length === templates.length) {
            return deferred.resolve($(templateName));
          }
        }).error(function(error) {
          return deferred.reject(error);
        });
      });
      return deferred.promise();
    }
  });
}).call(this);
