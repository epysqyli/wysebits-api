module RedisService
  private

  def redis
    @redis ||= Redis.new
  end

  def cache(key, value)
    redis.set(key, JSON.dump(value))
  end
end
