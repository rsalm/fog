module Fog
  module Storage
    class OpenStack

      class Real

        # Get an expiring object https url from Cloud Files
        #
        # ==== Parameters
        # * container<~String> - Name of container containing object
        # * object<~String> - Name of object to get expiring url for
        # * expires<~Time> - An expiry time for this url
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~String> - url for object
        #
        # ==== See Also
        # http://docs.rackspace.com/files/api/v1/cf-devguide/content/Create_TempURL-d1a444.html
        def get_object_https_url(container, object, expires, options = {})
          if @openstack_temp_url_key.nil?
            raise ArgumentError, "Storage must my instantiated with the :openstack_temp_url_key option"
          end

          method         = 'GET'
          expires        = expires.to_i
          object_path_escaped   = "#{@path}/#{Fog::OpenStack.escape(container)}/#{Fog::OpenStack.escape(object,"/")}"
          object_path_unescaped = "#{@path}/#{Fog::OpenStack.escape(container)}/#{object}"
          string_to_sign = "#{method}\n#{expires}\n#{object_path_unescaped}"

          hmac = Fog::HMAC.new('sha1', @openstack_temp_url_key)
          sig  = sig_to_hex(hmac.sign(string_to_sign))

          "https://#{@host}#{object_path_escaped}?temp_url_sig=#{sig}&temp_url_expires=#{expires}"
        end

        private

        def sig_to_hex(str)
          str.unpack("C*").map { |c|
            c.to_s(16)
          }.map { |h|
            h.size == 1 ? "0#{h}" : h
          }.join
        end

      end

    end
  end
end
