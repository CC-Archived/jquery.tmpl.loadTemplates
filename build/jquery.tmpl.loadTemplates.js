/*
 * jquery.tmpl.loadTemplates v1.1.0
 * Copyright (c) 2011 CodeCatalyst, LLC.
 * Open source under the MIT License.
 */
(function() {
  var $, TEMPLATE_NAME_EXPRESSION;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  TEMPLATE_NAME_EXPRESSION = /\/*([\w]*).html$/;
  $ = jQuery;
  $.extend({
    loadTemplates: function(templates, templateProcessorCallback) {
      var deferred, loadedTemplates, templateCount;
      if (templateProcessorCallback == null) {
        templateProcessorCallback = null;
      }
      if (typeof templates === "string") {
        templates = [templates];
      }
      deferred = new jQuery.Deferred();
      templateCount = 0;
      loadedTemplates = [];
      $.each(templates, function(templateName, template) {
        templateCount++;
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
          if (loadedTemplates.length === templateCount) {
            return deferred.resolve();
          }
        }).error(function(error) {
          return deferred.reject(error);
        });
      });
      return deferred.promise();
    }
  });
  $.fn.loadTemplates = function(options) {
    var defaults, selectedElement;
    defaults = {
      templates: {},
      process: null,
      compile: false,
      done: null
    };
    options = $.extend({}, defaults, options);
    if (options.templates != null) {
      selectedElement = this;
      $.loadTemplates(options.templates, function(templateName, templateContent) {
        if (options.process != null) {
          templateContent = options.process(templateName, templateContent);
        }
        if (templateContent != null) {
          selectedElement.append("<script id=\"" + templateName + "\" type=\"text/x-jquery-tmpl\">" + templateContent + "</script>");
        }
        if (options.compile) {
          return templateContent;
        } else {
          return null;
        }
      }).done(__bind(function() {
        selectedElement.trigger($.Event("done"));
        return typeof options.done === "function" ? options.done() : void 0;
      }, this));
    }
    return this;
  };
}).call(this);
