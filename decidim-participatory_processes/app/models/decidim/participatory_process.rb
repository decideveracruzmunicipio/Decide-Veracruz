# frozen_string_literal: true

module Decidim
  # Interaction between a user and an organization is done via a
  # ParticipatoryProcess. It's a unit of action from the Organization point of
  # view that groups several features (proposals, debates...) distributed in
  # steps that get enabled or disabled depending on which step is currently
  # active.
  class ParticipatoryProcess < ApplicationRecord
    include Decidim::HasAttachments
    include Decidim::Participable
    include Decidim::Publicable
    include Decidim::Scopable
    include Decidim::Followable

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"
    belongs_to :participatory_process_group,
               foreign_key: "decidim_participatory_process_group_id",
               class_name: "Decidim::ParticipatoryProcessGroup",
               inverse_of: :participatory_processes,
               optional: true
    has_many :steps,
             -> { order(position: :asc) },
             foreign_key: "decidim_participatory_process_id",
             class_name: "Decidim::ParticipatoryProcessStep",
             dependent: :destroy,
             inverse_of: :participatory_process
    has_one :active_step,
            -> { where(active: true) },
            foreign_key: "decidim_participatory_process_id",
            class_name: "Decidim::ParticipatoryProcessStep",
            dependent: :destroy,
            inverse_of: :participatory_process
    has_many :categories,
             foreign_key: "decidim_participatory_space_id",
             foreign_type: "decidim_participatory_space_type",
             dependent: :destroy,
             as: :participatory_space

    has_many :features, as: :participatory_space, dependent: :destroy

    attr_readonly :active_step

    validates :slug, uniqueness: { scope: :organization }
    validates :slug, presence: true, format: { with: Decidim::ParticipatoryProcess.slug_format }

    mount_uploader :hero_image, Decidim::HeroImageUploader
    mount_uploader :banner_image, Decidim::BannerImageUploader

    scope :past, -> { where(arel_table[:end_date].lteq(Time.current)) }
    scope :upcoming, -> { where(arel_table[:start_date].gt(Time.current)) }
    scope :active, -> { where(arel_table[:start_date].lteq(Time.current).and(arel_table[:end_date].gt(Time.current).or(arel_table[:end_date].eq(nil)))) }

    # Scope to return only the promoted processes.
    #
    # Returns an ActiveRecord::Relation.
    def self.promoted
      where(promoted: true)
    end

    def hashtag
      attributes["hashtag"].to_s.delete("#")
    end

    def to_param
      slug
    end
  end
end
