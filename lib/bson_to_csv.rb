module BsonToCsv
  class << self
    def parse(bson)
      headings = headings(bson)
      table = rows(bson, headings).unshift(headings)
      to_csv(table)
    end

    def headings(bson)
      bson.to_a.map(&:keys).flatten.uniq.reject { |k| k == '_id' }
    end

    def rows(bson, headings)
      bson.to_a.map { |h| headings.map { |k| h[k] } }
    end

    def to_csv(table)
      table.map { |r| r.join(',') }.join("\n")
    end
  end
end
