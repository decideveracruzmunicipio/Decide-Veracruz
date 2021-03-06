# frozen_string_literal: true

module Decidim
  module Events
    # This class serves as a base for all event classes. Event classes are intended to
    # add more logic to a `Decidim::Notification` and are used to render them in the
    # notifications dashboard and to generate other notifications (emails, for example).
    class BaseEvent
      # Public: Stores all the notification types this event can create. Please, do not
      # overwrite this method, consider it final. Instead, add values to the array via
      # modules, take the `NotificationEvent` module as an example:
      #
      # Example:
      #
      #   module WebPushNotificationEvent
      #     extend ActiveSupport::Concern
      #
      #     included do
      #       types << :web_push_notifications
      #     end
      #   end
      #
      #   class MyEvent < Decidim::Events::BaseEvent
      #     include WebPushNotificationEvent
      #   end
      #
      #   MyEvent.types # => [:web_push_notifications]
      def self.types
        @types ||= []
      end

      # Initializes the class.
      #
      # event_name - a String with the name of the event.
      # resource - the resource that received the event
      # user - the User that receives the event
      # extra - a Hash with extra information of the event.
      def initialize(resource:, event_name:, user:, extra:)
        @event_name = event_name
        @resource = resource
        @user = user
        @extra = extra.with_indifferent_access
      end

      # Caches the locator for the given resource, so that
      # we can find the resource URL.
      def resource_locator
        @resource_locator ||= Decidim::ResourceLocatorPresenter.new(resource)
      end

      # Caches the path for the given resource.
      def resource_path
        @resource_path ||= resource_locator.path
      end

      # Caches the URL for the given resource.
      def resource_url
        @resource_url ||= resource_locator.url
      end

      # Whether this event should be notified or not. Useful when you want the
      # event to decide based on the params.
      #
      # It returns false when the resource or any element in the chain is a
      # `Decidim::Publicable` and it isn't published.
      def notifiable?
        return false if resource.is_a?(Decidim::Publicable) && !resource.published?
        return false if participatory_space.is_a?(Decidim::Publicable) && !participatory_space&.published?
        return false unless feature&.published?

        true
      end

      private

      attr_reader :event_name, :resource, :user, :extra

      def feature
        return resource.feature if resource.is_a?(Decidim::HasFeature)
        return resource if resource.is_a?(Decidim::Feature)
      end

      def participatory_space
        return feature.participatory_space if feature
      end

      def resource_title
        resource.title.is_a?(Hash) ? resource.title[I18n.locale.to_s] : resource.title
      end
    end
  end
end
