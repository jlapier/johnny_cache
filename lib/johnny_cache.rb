module ActionView::Helpers::CacheHelper
  # cache helper with optional options hash
  def cache(name = {}, options = nil, &block)
    @controller.cache_erb_fragment(block, name, options)
  end
end

      
module ActionController::Caching::Fragments
  def cache_erb_fragment(block, name = {}, options = nil)
    unless perform_caching then block.call; return end
    
    cache = get_johnny_cache(name)
    buffer = eval(ActionView::Base.erb_variable, block.binding)

    if cache
      buffer.concat(cache)
    else
      pos = buffer.length
      buffer.concat("<!-- EXPIRE CACHE: #{Time.now.to_i + options[:time_to_live]} -->\n") if options and options[:time_to_live]
      block.call
      write_fragment(name, buffer[pos..-1], options)
    end
  end
  
  # returns cache if still 'fresh', otherwise expires any existing cache and returns nil
  def get_johnny_cache(name)
    cache = read_fragment(name)
    
    if cache #and options and options[:time_to_live]
      m = cache.match( /(<!-- EXPIRE CACHE: )(\d+)( -->)/ )
      if m.nil? or (m[2].to_i < Time.now.to_i)
        expire_fragment(name)
        cache = nil
      end
    end
    cache
  end
end
