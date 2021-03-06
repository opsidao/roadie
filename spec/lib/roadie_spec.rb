require 'spec_helper'

describe Roadie do
  describe ".inline_css" do
    it "creates an instance of Roadie::Inliner and execute it" do
      Roadie::Inliner.should_receive(:new).with('attri', 'butes').and_return(double('inliner', :execute => 'html'))
      Roadie.inline_css('attri', 'butes').should == 'html'
    end
  end

  describe ".app" do
    it "delegates to Rails.application" do
      Rails.stub(:application => 'application')
      Roadie.app.should == 'application'
    end
  end

  describe ".providers" do
    it "returns an array of all provider classes" do
      Roadie.should have(2).providers
      Roadie.providers.should include(Roadie::AssetPipelineProvider, Roadie::FilesystemProvider)
    end
  end

  describe ".current_provider" do
    let(:provider) { double("provider instance") }
    let(:config) { Roadie.app.config }

    context "with a set provider in the config" do
      it "uses the set provider" do
        config.roadie.provider = provider
        Roadie.current_provider.should == provider
      end
    end

    context "when Rails' asset pipeline is not present" do
      before(:each) do
        # Turns out it's pretty much impossible to work with Rails.application.config
        # in a nice way; it changed quite a lot since 3.0. There's also no way of
        # removing a configuration key after it's set, we cannot remove the assets
        # config completely to trigger the normal error triggered in a 3.0 app (NoMethodError)
        # We'll simulate it by mutating it in an ugly way for this test
        config.stub(:assets).and_raise(NoMethodError)
        config.stub(:respond_to?).with(:assets) { false }
      end

      it "uses the FilesystemProvider" do
        Roadie::FilesystemProvider.should_receive(:new).and_return(provider)
        Roadie.current_provider.should == provider
      end
    end

    context "with rails' asset pipeline enabled" do
      before(:each) { config.assets.enabled = true }

      it "uses the AssetPipelineProvider" do
        Roadie::AssetPipelineProvider.should_receive(:new).and_return(provider)
        Roadie.current_provider.should == provider
      end
    end

    context "with rails' asset pipeline disabled" do
      before(:each) { config.assets.enabled = false }

      it "uses the FilesystemProvider" do
        Roadie::FilesystemProvider.should_receive(:new).and_return(provider)
        Roadie.current_provider.should == provider
      end
    end
  end
end
