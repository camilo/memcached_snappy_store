module ActiveSupport
  module Cache
    class MemcachedSnappyStore < Cache::MemCacheStore
      class UnsupportedOperation < StandardError; end

      def increment(*args)
        raise UnsupportedOperation.new("increment is not supported by: #{self.class.name}")
      end

      def decrement(*args)
        raise UnsupportedOperation.new("decrement is not supported by: #{self.class.name}")
      end

      def read_multi(*names)
        options = names.extract_options!
        options = merged_options(options)
        keys_to_names = Hash[names.map{|name| [escape_key(namespaced_key(name, options)), name]}]
        raw_values = @data.get_multi(keys_to_names.keys, :raw => true)
        values = {}
        raw_values.each do |key, compressed_value|
          value = Snappy.inflate(compressed_value)
          entry = deserialize_entry(value)
          values[keys_to_names[key]] = entry.value unless entry.expired?
        end
        values
      end

      protected

      def read_entry(key, options)
        compressed_data = @data.get(escape_key(key), true)
        data = Snappy.inflate(compressed_data)
        deserialize_entry(data)
      rescue MemCache::MemCacheError => e
        logger.error("MemCacheError (#{e}): #{e.message}") if logger
        nil
      end

      def write_entry(key, entry, options)
        # normally unless_exist would make this method use add,  add will not make sense on compressed entries
        raise UnsupportedOperation.new("unless_exist would try to use the unsupported add method") if options && options[:unless_exist]

        value = options[:raw] ? entry.value.to_s : entry
        expires_in = options[:expires_in].to_i
        if expires_in > 0 && !options[:raw]
          # Set the memcache expire a few minutes in the future to support race condition ttls on read
          expires_in += 5.minutes
        end

        serialized_value = Marshal.dump(value)
        serialized_compressed_value = Snappy.deflate(serialized_value)

        response = @data.set(escape_key(key), serialized_compressed_value, expires_in, true)
        response == Response::STORED
      rescue MemCache::MemCacheError => e
        logger.error("MemCacheError (#{e}): #{e.message}") if logger
        false
      end
    end
  end
end
