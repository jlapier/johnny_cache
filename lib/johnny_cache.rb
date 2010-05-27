module ActionController::Caching::Fragments

  def fragment_for(buffer, name = {}, options = nil, &block)
    if perform_caching
      if cache = get_johnny_cache(name)
        buffer.concat(cache)
      else
        pos = buffer.length
        buffer.concat("<!-- EXPIRE CACHE: #{Time.now.utc.to_i + options[:time_to_live]} -->\n") if options and options[:time_to_live]
        block.call
        write_fragment(name, buffer[pos..-1], options)
      end
    else
      block.call
    end
  end
  
  # returns cache if still 'fresh', otherwise expires any existing cache and returns nil
  def get_johnny_cache(name)
    cache = read_fragment(name)
    
    if cache #and options and options[:time_to_live]
      m = cache.match( /(<!-- EXPIRE CACHE: )(\d+)( -->)/ )
      if m.nil? or (m[2].to_i < Time.now.utc.to_i)
        expire_fragment(name)
        cache = nil
      end
    end
    cache
  end
end
