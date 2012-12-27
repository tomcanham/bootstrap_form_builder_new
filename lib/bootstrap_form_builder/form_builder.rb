module BootstrapFormBuilder
  class StringList < Array
    def initialize(*args)
      super()

      args.each do |arg|
        if arg.is_a?(Array)
          concat(arg)
        else
          concat(Array((arg || '').to_s.split))
        end
      end
    end

    def sort(*args)
      StringList.new(super)
    end

    def &(other)
      case other
      when String
        StringList.new(super(other.split.flatten.compact.uniq))
      else
        StringList.new(super)
      end
    end

    def +(*args)
      StringList.new(super(Array(args)))
    end

    def -(*args)
      StringList.new(super(Array(args)))
    end

    def ==(other)
      case other
      when StringList, Array
        to_a.sort == normalize_array(other.to_a).sort
      else
        to_s == other.to_s
      end
    end

    def to_a
      normalize_array(super)
    end

    def to_s
      to_a.join(' ')
    end

    def normalize!
      flatten!
      compact!
      uniq!
      self
    end

    private
    def normalize_array(a)
      a.flatten.compact.uniq
    end
  end

  class ParsedArgs
    attr_accessor :classes

    def initialize(*args)
      @options = args.extract_options!
      @args = args
      @classes = StringList.new(@options.delete(:class))
    end

    def options
      if @classes.empty?
        @options
      else
        @options.merge(class: @classes.to_s)
      end
    end

    def shift
      @args.shift
    end

    def to_a
      if @classes.empty? && @options.empty?
        @args
      else
        @args + [options]
      end
    end
  end

  class FormBuilder < ActionView::Helpers::FormBuilder  
    cattr_accessor :default_layout
    attr_accessor :layout

    def initialize(object_name, object, template, options, proc)
      options[:html] ||= {}
      form_classes = StringList.new(options[:html][:class])

      unless form_classes.include?('form')
        form_classes += 'form'
        layout = options.delete(:layout).try(:to_sym) || BootstrapFormBuilder::FormBuilder.default_layout

        if layout.present?
          case layout
          when :horizontal
            form_classes -= 'form-inline'
            form_classes += 'form-horizontal'
          when :inline
            form_classes -= 'form-horizontal'
            form_classes += 'form-inline'
          end

          options[:html][:class] = form_classes.to_s
        end
      end

      super
    end

    def text_field(*args)
      control_group(*args) { super }
    end

    def select(*args)
      control_group(*args) { super }
    end

    def check_box(method, *args)
      args = ParsedArgs.new(*args)
      tooltip = args.options.delete(:tooltip)                  

      @template.content_tag(:div, class: "control-group") do
        @template.content_tag(:div, class: "controls") do
          @template.content_tag(:label, class: "checkbox") do            
            super + method.to_s.titleize +
            (tooltip.present? ? help_icon(tooltip) : ''.html_safe)
          end
        end
      end
    end

    def number_field(*args)
      control_group(*args) { super }
    end

    def password_field(*args)
      control_group(*args) { super }
    end

    def email_field(*args)
      control_group(*args) { super }
    end

    def text_area(*args)
      control_group(*args) { super }
    end

    def actions()
      @template.content_tag(:div, class: 'form-actions') do
        yield
      end
    end

    def submit(text=nil, *args)
      options = args.extract_options!
      super(text || options.delete(:submit_text), merge_classes(options, "btn btn-primary"))
    end

    private
    def control_group(*args)
      args = ParsedArgs.new(*args)
      
      method = args.shift
      tooltip = args.options.delete(:tooltip)
      label_text = args.options.delete(:label_text)
      
      args.classes << 'control-group'
      if @object.errors[method].any?
        args.classes << 'error'
      end

      @template.content_tag(:div, class: args.classes.to_s) do 
        label(method, label_text, *args) +
        controls(method, *args) do
          @template.capture { yield } +
          (tooltip.present? ? help_icon(tooltip) : ''.html_safe)
        end 
      end
    end

    def controls(*args)
      @template.content_tag(:div, class: 'controls') do
        yield
      end
    end

    def help_icon(text, placement = nil)
      @template.link_to('#', rel: 'tooltip', data: {:'original-title' => text}) do
        @template.content_tag(:i, ' ', class: classes('icon-question-sign', 'icon-blue', 'help-hover-over'))
      end
    end

    def merge_classes(options, *args)
      options.merge({class: classes(options[:class], *args)})
    end

    def classes(*args)
      result_parts = []
      args.each do |arg|
        unless arg.nil?
          if arg.is_a?(String)
            arg = arg.split
          end

          result_parts += arg.map{|a| a.to_s.strip}
        end
      end

      result_parts.join(' ')
    end

    def label(method, text=nil, *args)
      args = ParsedArgs.new(args)
      args.classes += 'control-label'
      super(method, text, args.options)
    end
  end
end