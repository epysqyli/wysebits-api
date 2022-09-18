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

  def add_match_block_to_must(field, value, fuzziness = 'AUTO')
    @query[:bool][:must] << match_block(field, value, fuzziness)
  end

  def add_match_block_to_filter(field, value, fuzziness = 'AUTO')
    @query[:bool][:filter] << match_block(field, value, fuzziness)
  end

  def add_term_block_to_filter(field, value)
    @query[:bool][:filter] << term_block(field, value)
  end

  def build_query(search_request)
    build_match_query(search_request)
    build_term_query(search_request)
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

  def build_match_query(search_request)
    match_query = search_request[:match].presence

    must_match_query = match_query[:must].presence if match_query
    must_match_query.first.each_pair { |k, v| add_match_block_to_must(k, v) } if must_match_query.present?

    filter_match_query = match_query[:filter].presence if match_query
    filter_match_query.first.each_pair { |k, v| add_match_block_to_filter(k, v) } if filter_match_query.present?
  end

  def build_term_query(search_request)
    term_query = search_request[:term].presence
    filter_term_query = term_query[:filter].presence if term_query
    filter_term_query.first.each_pair { |k, v| add_term_block_to_filter(k, v) } if filter_term_query.present?
  end
end
