require 'mongo'

Mongo::Logger.logger.level = Logger::WARN

class SimpleDatabase
  def initialize(url)
    @db_client = Mongo::Client.new(url)
    fail(DatabaseNotFound) unless database_exists?
  end

  attr_reader :db_client

  def create_or_replace(collection, query, value)
    document = db_client[collection].find(query)
    if document.first
      document.replace_one(value)
    else
      db_client[collection].insert_one(value)
    end
  end

  def get_all(collection)
    db_client[collection].find
  end

  def clear(collection)
    db_client[collection].find.delete_many
  end

  private

  def database_exists?
    !db_client.cluster.servers.empty?
  end
end

class DatabaseNotFound < StandardError; end
