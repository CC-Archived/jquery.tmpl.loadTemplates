/*
 * jquery.tmpl.loadTemplates v1.0.3
 * Copyright (c) 2011 CodeCatalyst, LLC.
 * Open source under the MIT License.
 */
(function() {
  var $, TEMPLATE_NAME_EXPRESSION;
  TEMPLATE_NAME_EXPRESSION = /\/*([\w]*).html$/;
  $ = jQuery;
  $.extend({
    loadTemplates: function(templates, templateProcessorCallback) {
      var deferred, loadedTemplates;
      if (templateProcessorCallback == null) {
        templateProcessorCallback = null;
      }
      if (typeof templates === "string") {
        templates = [templates];
      }
      deferred = new jQuery.Deferred();
      loadedTemplates = [];
      $.each(templates, function(templateName, template) {
        if (typeof templateName === "number") {
          templateName = TEMPLATE_NAME_EXPRESSION.exec(template)[1];
        }
        return $.get(template, function(templateContent) {
          if (templateProcessorCallback != null) {
            templateContent = templateProcessorCallback(templateName, templateContent);
          }
          if (templateContent != null) {
            return $.template(templateName, templateContent);
          }
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
  $.fn.extend({
    loadTemplates: function(templates, templateProcessorCallback, compile) {
      var promise, selectedElement;
      if (templateProcessorCallback == null) {
        templateProcessorCallback = null;
      }
      if (compile == null) {
        compile = false;
      }
      selectedElement = this;
      promise = $.loadTemplates(templates, function(templateName, templateContent) {
        var templateTag;
        if (templateProcessorCallback != null) {
          templateContent = templateProcessorCallback(templateName, templateContent);
        }
        if (templateContent != null) {
          templateTag = $("<script id=\"" + templateName + "\" type=\"text/html\"></script>").append($(templateContent).clone());
          $(selectedElement).append(templateTag);
        }
        if (compile) {
          return templateContent;
        } else {
          return false;
        }
      });
      return promise;
    }
  });
}).call(this);
