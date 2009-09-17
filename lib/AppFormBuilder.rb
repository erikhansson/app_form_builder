# encoding: utf-8

class AppFormBuilder < ActionView::Helpers::FormBuilder

  %w[text_field collection_select password_field text_area file_field].each do |method_name|
    define_method method_name do |field, *args|
      options = args.extract_options!
      label_text = options.delete :label
      error_text = options.delete :error
      label_text += "<span class=\"error_text\">"+ (error_text ?  error_text : getError(field)) +"</span>" if getError(field)
      @template.content_tag('div', label(field, label_text) + super(field, *args, options), :class => 'field')
    end
  end
  
  define_method :check_box do |field, *args|
    options = args.extract_options!
    label_text = options.delete :label
    @template.content_tag('div', %Q[
        #{super(field, options)}
        #{label(field, label_text)}
      ], :class => 'field checkbox')
  end
  
  define_method :radio_button do |field, value, *args|
    options = args.extract_options!
    label_text = options.delete :label
    @template.content_tag('div', %Q[
        #{super(field, value, options)}
        #{label(field, label_text)}
      ], :class => 'field checkbox')
  end
  
  def submit(text, options = {})
    @template.content_tag('button', text, 
      options.merge(:type => 'submit')
    )
  end
  
  def label(field, text)
    super(field, text, label_options(field))
  end
  
  def label_options(field)
    getError(field) ? { :class => 'error' } : {}
  end
  
  def getError(field)
    return nil if object.nil? || !object.respond_to?(:errors)
    object.errors[field]
  end
  
  def checkbox_set(field, values, options = {})
    current = object.send(field)
    ix = 0;
    values.map do |value|
      attrs = {
        :type => 'checkbox',
        :name => "#{@object_name}[#{field}][]",
        :id => "#{@object_name}_#{field}_#{ix += 1}",
        :value => value
      }
      attrs[:checked] = 'checked' if current.nil? || current.include?(value)
      
      %Q{
        <div class="checkbox field">
          <input #{format_attrs attrs} />
          <label for="#{@object_name}_#{field}_#{ix}">#{value}</label>
        </div>
      }
    end.join("\n")
  end
  
  def format_attrs(attrs)
    attrs.map do |key, value|
      "#{key}=\"#{value}\""
    end.join " "
  end
  
end


# Monkey-patch to force all input elements to include a value attribute,
# even when the model value is nil. Ugly but effective (I think). Use at
# your own risk.
raise 'Ouch' unless ActionView && ActionView::Helpers && ActionView::Helpers::InstanceTag

module ActionView
  module Helpers
    class InstanceTag #:nodoc:
      
      def value_before_type_cast(object)
        self.class.value_before_type_cast(object, @method_name) || ''
      end
      
    end
  end
end
