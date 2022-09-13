class ElasticQuery
  attr_accessor :query

  def initialize
    @query = {
      bool: {
        must: [],
        filter: []
      }
    }
  end

  def add_match_to_must(field, value, fuzziness = 'AUTO')
    @query[:bool][:must] = match_block(field, value, fuzziness)
  end

  def add_match_to_filter(field, value, fuzziness = 'AUTO')
    @query[:bool][:filter] = match_block(field, value, fuzziness)
  end

  def add_term_block_to_must(field, value)
    @query[:bool][:must] = term_block(field, value)
  end

  def add_term_block_to_filter(field, value)
    @query[:bool][:filter] = term_block(field, value)
  end

  private

  def match_block(field, value, fuzziness = 'AUTO')
    {
      match: {
        field => {
          query: value,
          fuzziness: fuzziness
        }
      }
    }
  end

  def term_block(field, value)
    {
      term: {
        field => value
      }
    }
  end
end
