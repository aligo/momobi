module ActionController
  module Momobi
    # These are various strings that can be found in mobile devices. Please feel free
    # to add on to this list.
    MOBILE_USER_AGENTS = 'palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|' +
                          'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|' +
                          'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|' +
                          'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' +
                          'webos|amoi|novarra|cdm|alcatel|pocket|ipad|iphone|mobileexplorer|' +
                          'mobile'
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      
      # Add this to one of your controllers to use Momobi.
      #
      # class ApplicationController < ActionController::Base
      # has_momobi
      # end
      #
      # You can also force mobile mode by passing in 'true'
      #
      # class ApplicationController < ActionController::Base
      # has_momobi(true)
      # end
        
      def has_momobi(test_mode = false)
        include ActionController::Momobi::InstanceMethods

        if test_mode
          before_filter :force_mobile_format
        else
          before_filter :set_mobile_format
        end

        helper_method :is_mobile_device?
        helper_method :is_mobile_view?
        helper_method :is_device?
      end
      
      def is_mobile_device?
        @@is_mobile_device
      end
      
      def is_mobile_view?
        @@is_mobile_view
      end

      def is_device?(type)
        @@is_device
      end
    end
    
    module InstanceMethods
      
      def force_mobile_format
        prepend_view_path(File.join(Rails.root, "app/views/_mobi"))
        session[:mobile_view] = true if session[:mobile_view].nil?
      end
      
      def set_mobile_format
        if (params[:mobi] == 'on')
          session[:mobile_view] = true
        elsif (params[:mobi] == 'off')
          session[:mobile_view] = false
        elsif is_mobile_device? && !request.xhr?
          session[:mobile_view] = true if session[:mobile_view].nil?
        end
        if session[:mobile_view]
          prepend_view_path(File.join(Rails.root, "app/views/_mobi"))
        else
          prepend_view_path(File.join(Rails.root, "app/views/_mo"))
        end
      end
      
      def is_mobile_device?
        request.user_agent.to_s.downcase =~ Regexp.new(ActionController::Momobi::MOBILE_USER_AGENTS)
      end
      
      def is_mobile_view?
        session[:mobile_view]
      end
      
      def is_device?(type)
        request.user_agent.to_s.downcase.include?(type.to_s.downcase)
      end
    end
    
  end
  
end