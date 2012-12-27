require 'spec_helper'

include ActionView::Helpers::FormOptionsHelper

class MockTemplate
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormHelper

  attr_accessor :output_buffer
end

describe BootstrapFormBuilder::FormBuilder do
  before do
    @object = mock_model("Profile", 
      username: 'big love', 
      gender: 'transman', 
      password: 'password', 
      age: 42, 
      email: 'foo@bar.com', 
      awesome: true,
      content: 'This is some content.')
    @builder = BootstrapFormBuilder::FormBuilder.new(:profile, @object, MockTemplate.new, {}, nil)
  end

  let(:object_name) { "profile" }
  let(:content) { "" }
  let(:node) { Capybara.string(content) }

  let(:scopes) do
    []
  end

  let(:scope) do
    scopes.last || node
  end

  def within(what, &block)
    begin
      scopes.push(scope.find(what))
      yield
    ensure
      scopes.pop
    end
  end

  shared_examples("a control group") do
    it "has a control group div" do
      expect(scope).to have_selector("div.control-group")
    end
  end

  shared_examples("a control group with a control") do
    it_behaves_like("a control group")

    it "has a controls div" do
      within("div.control-group") do
        expect(scope).to have_selector("div.controls")
      end
    end

    it "has a control element matching specified selector" do
      within("div.control-group") do
        within("div.controls") do
          expect(scope).to have_selector(control_selector)
        end
      end
    end

    it "has the right name attribute" do
      within("div.control-group div.controls") do
        expect(scope).to have_selector("#{control_selector}[name=\"#{object_name}[#{attribute_name.to_s}]\"]")
      end
    end

    it "has the right id attribute" do
      within("div.control-group div.controls") do
        expect(scope).to have_selector("#{control_selector}[id=\"#{object_name}_#{attribute_name.to_s}\"]")
      end
    end
  end

  shared_examples("a label with content") do
    it "has the right content" do
      expect(scope).to have_selector("label", text: label_text)
    end
  end

  shared_examples("a control group with a label") do
    let(:label_text) do
      attribute_name.to_s.humanize
    end

    it_behaves_like("a label with content")

    it "has the right classes" do 
      expect(scope).to have_selector("label.control-label")
    end

    it "has the right for attribute" do
      expect(scope).to have_selector("label[for=\"profile_#{attribute_name.to_s}\"]")
    end

    it "is properly nested in a control group" do
      within("div.control-group") do
        expect(scope).to have_selector("label")
      end
    end
  end

  shared_examples("a control with a tooltip icon") do
    it "has the right tooltip text" do
      expect(scope).to have_selector("[rel=\"tooltip\"][data-original-title=\"#{tooltip_text}\"]")
    end

    it "has a blue question mark icon" do
      within("[rel=\"tooltip\"]") do
        expect(scope).to have_selector("i.icon-question-sign.icon-blue.help-hover-over")
      end
    end
  end

  shared_examples("an input with a default value") do
    it "has the correct default value" do
      expect(scope).to have_selector("input[value=\"#{default_value}\"]")
    end
  end

  describe "#text_field" do
    let(:content) { @builder.text_field(:username) }
    let(:attribute_name) { :username }
    let(:control_selector) { "input[type=text]" }
    let(:default_value) { "big love" }

    it_behaves_like("a control group with a control")
    it_behaves_like("a control group with a label")
    it_behaves_like("an input with a default value")
  end

  describe "#text_area" do
    let(:content) { @builder.text_area(:content) }
    let(:attribute_name) { :content }
    let(:control_selector) { "textarea" }
    let(:default_value) { "This is some content" }

    it_behaves_like("a control group with a control")
    it_behaves_like("a control group with a label")
    it "should have the default value as content" do
      within(control_selector) do
        expect(scope).to have_content(default_value)
      end
    end
  end

  describe "#select" do
    let(:gender_texts) {[ "(unspecified)", "Male", "Female", "TransMan", "TransWoman" ]}
    let(:gender_values) {[ nil, "male", "female", "transman", "transwoman" ]}
    let(:genders) {gender_texts.zip(gender_values)}
      
    let(:content) do
      @builder.select :gender, options_for_select(genders, @object.gender), tooltip: 'What gender do you consider yourself?'
    end

    let(:attribute_name) { :gender }
    let(:control_selector) { "select" }
    let(:tooltip_text) { 'What gender do you consider yourself?' }

    it_behaves_like("a control group with a control")
    it_behaves_like("a control group with a label")
    it_behaves_like("a control with a tooltip icon")

    it "should have the right option selected" do
      expect(scope).to have_select('Gender', selected: 'TransMan', options: gender_texts)
    end
  end

  describe "#number_field" do
    let(:content) { @builder.number_field(:age, tooltip: tooltip_text) }
    let(:attribute_name) { :age }
    let(:control_selector) { "input[type=number]" }
    let(:tooltip_text) { 'What age would you like to say you are?' }
    let(:default_value) { 42 }

    it_behaves_like("a control group with a control")
    it_behaves_like("a control group with a label")
    it_behaves_like("a control with a tooltip icon")
    it_behaves_like("an input with a default value")
  end

  describe "#check_box" do
    let(:content) { @builder.check_box(:awesome, tooltip: tooltip_text) }
    let(:attribute_name) { :awesome }
    let(:control_selector) { "input[type=checkbox]" }
    let(:tooltip_text) { "Are you AWESEOME?" }
    let(:default_value) { "1" }
    let(:label_text) { "Awesome" }

    it_behaves_like("a control group with a control")
    it_behaves_like("a label with content")
    it_behaves_like("a control with a tooltip icon")
  end

  describe "#password_field" do
    let(:content) { @builder.password_field(:password, tooltip: tooltip_text) }
    let(:attribute_name) { :password }
    let(:control_selector) { "input[type=password]" }
    let(:tooltip_text) { "What's yer password?" }

    it_behaves_like("a control group with a control")
    it_behaves_like("a control group with a label")
    it_behaves_like("a control with a tooltip icon")
  end

  describe "#email_field" do
    let(:content) { @builder.email_field(:email, tooltip: tooltip_text) }
    let(:attribute_name) { :email }
    let(:control_selector) { "input[type=email]" }
    let(:tooltip_text) { "What's yer email, bub?" }
    let(:default_value) { "foo@bar.com" }

    it_behaves_like("a control group with a control")
    it_behaves_like("a control group with a label")
    it_behaves_like("a control with a tooltip icon")  
    it_behaves_like("an input with a default value")
  end
  
  describe "#actions" do
    let(:content) { @builder.actions { "foo" } }
    
    it "has the correct classes" do
      expect(scope).to have_selector(".form-actions")
    end

    it "has the correct content" do
      expect(scope).to have_content("foo")
    end
  end
  
  describe "#submit" do
    let(:content) { @builder.submit }

    it "has the correct field" do
      expect(scope).to have_selector("input[type=submit]")
    end

    it "has the correct classes" do
      expect(scope).to have_selector(".btn.btn-primary")
    end

    it "has the correct name" do
      expect(scope).to have_selector("[name=commit]")
    end

    it "has the correct type" do
      expect(scope).to have_selector("[type=submit]")
    end

    it "has the correct text" do
      expect(scope).to have_selector("[value=\"Update Profile\"]")
    end
  end
end
