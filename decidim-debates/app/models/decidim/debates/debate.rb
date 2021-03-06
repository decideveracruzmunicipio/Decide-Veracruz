# frozen_string_literal: true

module Decidim
  module Debates
    # The data store for a Debate in the Decidim::Debates component. It stores a
    # title, description and any other useful information to render a custom
    # debate.
    class Debate < Debates::ApplicationRecord
      include Decidim::HasFeature
      include Decidim::HasCategory
      include Decidim::Resourceable
      include Decidim::Followable
      include Decidim::Comments::Commentable
      include Decidim::HasScope
      include Decidim::Authorable
      include Decidim::Reportable
      include Decidim::HasReference

      feature_manifest_name "debates"

      validates :title, presence: true

      # Public: Checks whether the debate is official or not.
      #
      # Returns a boolean.
      def official?
        author.blank?
      end

      # Public: Overrides the `reported_content_url` Reportable concern method.
      def reported_content_url
        ResourceLocatorPresenter.new(self).url
      end

      # Public: Calculates whether the current debate is an AMA-styled one or not.
      # AMA-styled debates are those that have a start and end time set, and comments
      # are only open during that timelapse. AMA stands for Ask Me Anything, a type
      # of debate inspired by Reddit.
      #
      # Returns a Boolean.
      def ama?
        start_time.present? && end_time.present?
      end

      # Public: Checks whether the debate is an AMA-styled one and is open.
      #
      # Returns a boolean.
      def open_ama?
        ama? && Time.current.between?(start_time, end_time)
      end

      # Public: Checks if the debate is open or not.
      #
      # Returns a boolean.
      def open?
        (ama? && open_ama?) || !ama?
      end

      # Public: Overrides the `commentable?` Commentable concern method.
      def commentable?
        feature.settings.comments_enabled?
      end

      # Public: Overrides the `accepts_new_comments?` Commentable concern method.
      def accepts_new_comments?
        return false unless open?
        commentable? && !comments_blocked?
      end

      # Public: Overrides the `comments_have_alignment?` Commentable concern method.
      def comments_have_alignment?
        true
      end

      # Public: Overrides the `comments_have_votes?` Commentable concern method.
      def comments_have_votes?
        true
      end

      # Public: Identifies the commentable type in the API.
      def commentable_type
        self.class.name
      end

      # Public: Overrides the `notifiable?` Notifiable concern method.
      def notifiable?(_context)
        false
      end

      # Public: Override Commentable concern method `users_to_notify_on_comment_created`
      def users_to_notify_on_comment_created
        return (followers | feature.participatory_space.admins).uniq if official?
        followers
      end

      private

      def comments_blocked?
        feature.current_settings.comments_blocked
      end
    end
  end
end
