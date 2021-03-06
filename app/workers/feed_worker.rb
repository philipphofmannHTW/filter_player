class FeedWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :feeds_queue, :backtrace => true
  
  def perform(feed_id)
    feed = Feed.find(feed_id)
    # get the embeded content and create tracks       
    feed_parser = FeedParser.new(feed)
    feed_parser.parse
    Rails.logger.debug"called parse on feed #{feed.id}"
  end
end