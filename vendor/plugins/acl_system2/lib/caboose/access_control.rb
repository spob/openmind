
module Caboose

  module AccessControl
    
    def self.included(subject)
      subject.extend(ClassMethods)
      if subject.respond_to? :helper_method
        subject.helper_method(:permit?)
        subject.helper_method(:restrict_to)
      end
    end
    
    module ClassMethods  
      #  access_control [:create, :edit] => 'admin & !blacklist',
      #                 :update => '(admin | moderator) & !blacklist',
      #                 :list => '(admin | moderator | user) & !blacklist'
      def access_control(actions={})
        # Add class-wide permission callback to before_filter
        defaults = {}  
        if block_given?
          yield defaults 
          default_block_given = true  
        end        
        before_filter do |c|
          c.default_access_context = defaults if default_block_given
          @access = AccessSentry.new(c, actions)
          if @access.allowed?(c.action_name)
            c.send(:permission_granted)  if c.respond_to?:permission_granted
          else    
            if c.respond_to?:permission_denied
              c.send(:permission_denied)
            else  
              host = APP_CONFIG['host']
              port = APP_CONFIG['port']
              c.send(:render, :text => "You have insufficient permissions to access #{c.controller_name}/#{c.action_name}. Return <a href='https://#{host}:#{port}'>home</a>")
            end
          end
        end
      end 
    end # ClassMethods 

    # return the active access handler, fallback to RoleHandler
    # implement #retrieve_access_handler to return non-default handler
    def access_handler
      if respond_to?(:retrieve_access_handler)
        @handler ||= retrieve_access_handler
      else
        @handler ||= RoleHandler.new
      end
    end

    # the current access context; will be created if not setup
    # will add current_user and merge any other elements of context
    def access_context(context = {})     
      default_access_context.merge(context)
    end

    def default_access_context
      @default_access_context ||= {}
      @default_access_context[:user] = send(:current_user) if respond_to?(:current_user)
      @default_access_context 
    end

    def default_access_context=(defaults)
      @default_access_context = defaults      
    end

    def permit?(logicstring, context = {})
      access_handler.process(logicstring, access_context(context))
    end
  
    # restrict_to "admin | moderator" do
    #   link_to "foo"
    # end   
    def restrict_to(logicstring, context = {})
      return false if current_user.nil?
      result = ''    
      if permit?(logicstring, context) 
        result = yield if block_given?
      end 
      result
    end    
      
    class AccessSentry
     
      def initialize(subject, actions={})
        @actions = actions.inject({}) do |auth, current|
          [current.first].flatten.each { |action| auth[action] = current.last }
          auth
        end 
        @subject = subject
      end 
     
      def allowed?(action)
        if @actions.has_key? action.to_sym
          return @subject.access_handler.process(@actions[action.to_sym].dup, @subject.access_context)
        elsif @actions.has_key? :DEFAULT
          return @subject.access_handler.process(@actions[:DEFAULT].dup, @subject.access_context) 
        else
          return true
        end  
      end
   
    end # AccessSentry
  
  end # AccessControl  
  
end # Caboose    





