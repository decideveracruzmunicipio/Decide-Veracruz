# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ParticipatoryProcesses::ParticipatoryProcessStatsPresenter do
    subject { described_class.new(participatory_process: process) }

    let!(:organization) { create(:organization) }
    let!(:user) { create(:user, :confirmed, organization: organization) }
    let!(:process) { create(:participatory_process, organization: organization) }
    let!(:feature) { create(:feature, participatory_space: process) }

    let(:manifest) do
      Decidim::FeatureManifest.new.tap do |manifest|
        manifest.name = "Test"
      end
    end

    before do
      manifest.stats.register :foo, priority: StatsRegistry::HIGH_PRIORITY, &proc { 10 }

      I18n.backend.store_translations(
        :en,
        decidim: {
          participatory_processes: {
            statistics: {
              foo: "Foo"
            }
          }
        }
      )

      allow(Decidim).to receive(:feature_manifests).and_return([manifest])
    end

    describe "#highlighted" do
      it "renders a collection of stats including users and proceses" do
        expect(subject.highlighted).to include("10 Foo")
      end
    end
  end
end
