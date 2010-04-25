require 'active_support/notifications/fanout'

# This has been merged to rails HEAD after the 3.0.0.beta.3 release (see
# https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/4433).
# Once 3.0.0.rc.1 comes out, we can remove it.
class ActiveSupport::Notifications::Fanout
  def unsubscribe(subscriber_or_name)
    @listeners_for.clear
    @subscribers.reject! do |s|
      s.instance_eval do
        case subscriber_or_name
        when String
          @pattern && @pattern =~ subscriber_or_name
        when self
          true
        end
      end
    end
  end
end
